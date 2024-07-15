;
; Design notes:
;   - Algorithms taken from disassembled VCS Kaboom!
;   - Graphics taken from VCS and made to match as closely as possible
;   - Goal is to run at a solid 60fps (1023000 / 60 ~= 17050 cycles per frame)
;   - All drawing should be as fast a possible but limited to worst case
;       - Want frame rate to be stable
;       - Exceptions are calls to random, to keep patterns correct
;

; Timing:

;   VBlank           4550 ( 70 * 65)
;
;   Active Top       2600 ( 40 * 65)
;   Active Center    9230 (142 * 65)
;   Active Bottom     650 ( 10 * 65)
;
;   VBlank+Bottom    5200 ((70 + 10) * 65)
;
;   Frame Total     17030 (262 * 65)

;   Update score      775
;   Erase bomber      574
;   Erase top bomb    270
;   Draw bomber      1088
;   Draw top bomb     890
;   Update bombs     4080
;   Erase buckets    1052
;   Draw buckets     1435
;   Read paddle      2850
;   ---------------------
;   Total           13014 (13500 measured)

; TODO
;   - flipped bombs
;   - bomber smile/frown
;   - logo/copyright animation

; *** bomb not dropping in right-most column
; *** top bomb doesn't explode
; *** BOMBS.PIC is out of date (bad saves?)
; *** player 2 score not different color

; *** match bomber start position to VCS
; *** add white hilite in buckets?
;   *** (requires drawing change/cycles)
; *** could score shift6 be removed?
; *** make logo/copyright white? add rainbow?

; *** bomb hits bucket +0
; *** bomb hidden      +1
; *** splash frame 3   +2
; *** splash frame 3   +3
; *** splash frame 3   +4
; *** splash frame 3   +5
; *** splash frame 2   +6
; *** splash frame 2   +7
; *** splash frame 2   +8
; *** splash frame 2   +9
; *** splash frame 1   +10
; *** splash frame 1   +11
; *** splash frame 1   +12
; *** splash frame 1   +13 ?

; *** pre-wave shows bomber holding bomb

; *** bombs visible 2 empty lines below it
; *** next frame, explosion starts
; *** small, medium, large explosion
; *** 4 frames of color cycle, before next frame
; *** no delay from explosion to explosion
; *** 2 frames of each screen color cycle
; *** 16 cycles (32 frames)

; *** fuse hit counts as bucket hit
; *** buckets move during bomb explosions
; *** bomber only smiles during explosion/flashing
; *** bombs drop smoothly from bomber's hands
; *** bomb not in his hands until ready to drop
; *** bomb is misaligned left/right half the time
; *** every other wave, bombs fall half as often
    ; *** (will throw off fixed cycle timing)
    ; *** (maybe just hide every other bomb?)
; *** splash *does* count as bomb hit!

.feature labels_without_colons
; .feature bracket_as_indirect

.macro set_page
    page .set *
.endmacro

.macro check_page
    .if ((* - 1) / 256) <> (page / 256)
        .error .sprintf("### page crossing detected at $%0.4x -> $%0.4x", page, *)
    .endif
.endmacro

topHeight       =   40
centerHeight    =   142
bottomHeight    =   10

; NOTE: This value is chosen so that the last score digit does not
;   have a shift of 6, avoiding artifacts on right edge of digit "4"
; *** won't be needed if background filled with $FF ***
scoreLeft       =   75

bomb0Top        =   29
bombPhaseDy     =   18
bombsTop        =   bomb0Top+bombPhaseDy
bombsBottom     =   topHeight+centerHeight
bombMaxDy       =   4

bomberMinX      =   7
bomberMaxX      =   125                 ; inclusive

bucketsMinX     =   3
bucketsMaxX     =   121                 ; inclusive

bucketTopY      =   141
bucketMidY      =   157
bucketBotY      =   173
bucketHeight    =   8

bucketByteWidth =   6

logoLeft        =   13
logoWidth       =   15
logoHeight      =   16

vaporlockBlack  =   $80

gameWaveMax     =   7

temp            :=  $00
offset          :=  $01
linenum         :=  $02

bucket_xcol     :=  $1A                 ;*** don't save?
bucket_xshift   :=  $1B                 ;*** don't save?
hit_xcol        :=  $1C
hit_xshift      :=  $1D
logo_offset     :=  $1E

screenl         :=  $24
screenh         :=  $25

; bombs variables
;
bomb_dy         :=  $61
bomb_index      :=  $62
start_line      :=  $63
end_line        :=  $64
bomb_ptr        :=  $65
bomb_ptr_h      :=  $66

; score variables
lmask           :=  $70
rmask           :=  $71
data_ptr        :=  $72
data_ptr_h      :=  $73

; *** move to "permanent" zpage
cur_digits      :=  $74                 ; $74,$75,$76,$77,$78,$79
; *** temporary buffer
new_digits      :=  $7a                 ; $7a,$7b,$7c,$7d,$7e,$7f

; *** bomb code generation $50-$58

                                        ; (start of init clear)
game_select     :=  $80
vblank_count    :=  $81
random_seed     :=  $82
;
active_bombs    :=  $88
;
bomber_x        :=  $9a
bomber_dir      :=  $9b
splash_bucket   :=  $9c
buckets_x       :=  $9d
;

                                        ; (start of reset clear)
player_num      :=  $a0                 ; current player (0 or 1)

player_state    :=  $a1
bucket_count    :=  $a1
game_wave       :=  $a2                 ; *** rename just "wave"?
score           :=  $a3                 ; $a3,$a4,$a5

other_state     :=  $a6
other_buckets   :=  $a6
other_wave      :=  $a7
other_score     :=  $a8                 ; $a8,$a9,$aa

bombs_dropped   :=  $ab
exp_bomb_index  :=  $ac
game_state      :=  $ad
exp_bomb_frame  :=  $ae
splash_frame    :=  $af

;
bomb_vphase     :=  $b1
;
bomb_frames     :=  $b3                 ; $b3-$ba
                                        ; (end of reset clear)
; NOTE: don't clear bomb columns on reset
;   because they're needed to erase bombs
; *** undo if fill_screen is enough ***
bomb_columns    :=  $bb                 ; $bb-$c2
                                        ; (end of init clear)

keyboard        :=  $C000
unstrobe        :=  $C010
click           :=  $C030
graphics        :=  $C050
text            :=  $C051
fullscreen      :=  $C052
primary         :=  $C054
secondary       :=  $C055
hires           :=  $C057
pbutton0        :=  $C061

                .include "hires.s"

                .org $6000
kaboom
                lda #0
                ldx #$3f
@1              sta game_select,x
                dex
                bpl @1

                ; *** clean these up ***
                lda #80
                sta buckets_x
                lda #70
                sta bomber_x
                lda #0
                sta logo_offset
                ; sta bucket_xcol
                ; sta bucket_xshift
                ; *** clean these up ***

                jsr fill_screen
                jsr draw_logo

                sta primary
                sta fullscreen
                sta hires
                sta graphics

                jsr init_bombs          ;***

                ; lda #1                  ;***
                ; sta bomb_frames+0
                ; lda #20
                ; sta bomb_columns+0

; intialize digits buffer to "no digits"
                ldx #5
                lda #$0A
@2              sta cur_digits,x
                dex
                bpl @2

                jmp do_reset

game_loop       jsr draw_score
                jsr erase_bomber
                jsr erase_top_bomb
                jsr draw_bomber
                jsr draw_top_bomb
                jsr draw_bombs
                jsr draw_buckets

; TODO: draw/animate logo

; TODO: should paddle range be centered on screen?
; TODO: can read_paddle be faster if end of range never needed?
move_buckets    ldx player_num
                jsr read_paddle
                tya
                sec
                sbc buckets_x
                bcc @left
@right          lsr
                clc
                adc buckets_x
                cmp #bucketsMaxX
                bcc @common
                lda #bucketsMaxX
                bcs @common             ; always

@left           sec
                ror
                clc
                adc buckets_x
                cmp #bucketsMinX
                bcs @common
                lda #bucketsMinX
@common         sta buckets_x

; *** compute bucket hit testing values here ***

                inc vblank_count

; check for reset and select
check_keys      lda keyboard
                bpl keys_checked
                bit unstrobe
                and #%01011111          ; force upper case
                cmp #'S'
                beq @select
                cmp #'R'
                beq to_reset
                bne keys_checked        ; always

@select
;*** only if game currently running
                jsr fill_screen

                inc game_select
                jsr clear_vars
                lda game_select
                and #$01
                sta game_select
                tay
                iny
                sty score+2
                bne keys_checked        ; always

to_reset        jsr fill_screen
; *** fold with do_reset and make startup call this?

do_reset        jsr clear_vars
                ldx #$ff
                stx game_state
                asl game_select
                sec
                ror game_select
                lda #3
                sta bucket_count
                sta other_buckets

keys_checked    bit game_select
                bpl @0
                lda bucket_count
                bne @1
; no buckets so idle
                lda vblank_count
                and #$7F
                beq swap_player
@0              jmp update_sounds

; handle exploding bomb animation
@1              lda exp_bomb_frame
                beq no_explode
                cmp #$20-1              ; -1 for erase frame
                bcc cont_explode
                beq @2
                dec exp_bomb_frame
                jmp update_sounds

; clear bomb that has finished exploding
@2              ldx exp_bomb_index
                lda #$00
                sta bomb_frames,x

; explode first/next bomb
explode_next    lda #$2B+1              ; +1 for immediate dec below
                sta exp_bomb_frame
                ldx #7                  ; versus #8 in original
                lda bombs_dropped
                beq @1
                dec bombs_dropped
@1              stx exp_bomb_index
                lda bomb_frames,x
                bne cont_explode
                dex
                bpl @1

                ; lda #0                  ;***
                ; sta bomb_frames+7       ;***

; no more bombs to explode
                lda #$20-1              ; -1 for erase frame
                sta exp_bomb_frame
cont_explode    dec exp_bomb_frame
                beq @1
                jmp update_sounds

; take away a bucket
@1              dec bucket_count

; does other player still have buckets?
                lda other_buckets
                beq next_wave

swap_player     lda game_select         ; two players?
                lsr
                bcc next_wave

; swap player states
                ldx #4
@1              ldy player_state,x
                lda other_state,x
                sta player_state,x
                sty other_state,x
                dex
                bpl @1

; toggle player number
                lda player_num
                eor #$01
                sta player_num

; decrement wave when player restarts
next_wave       ldx game_wave
                txa
                beq @1
; give them half as many bombs to catch
; (set bombCount to half already caught)
                dex
                stx game_wave
                lda bombs_per_wave,x
                lsr
                clc
                adc #1
@1              sta bombs_dropped
                ldx #$FF
                stx game_state
                jmp update_sounds

; no exploding bombs in progress
no_explode      bit game_state
                bpl move_bomber

; read paddle button push to start wave
                ldy #0
                ldx player_num
                lda pbutton0,x
                bpl @3
; wave is now in progress
                sty game_state
@3              sty bomb_vphase
                jmp update_sounds

; periodically/randomly change bomber's direction
;
; NOTE: Not always calling random here in order to keep
;   patterns similar to original game, even though it
;   doesn't maintain consistent timing.

move_bomber     ldx bomber_dir
                lda vblank_count
                and #$0f
                bne @1
                jsr random
                bcs @1
                txa
                eor #$ff
                tax
@1
; move bomber by +/- game_wave+1
;
; NOTE: Do all the work of computing new position and
;   then only commit to it at the end, all in order
;   to keep consistent timing.
                txa
                asl
                lda game_wave
                bcc @right
@left           eor #$ff
                clc
                adc bomber_x
                cmp #bomberMinX+1
                bcc @2
                cmp #$f0
                bcc @common
@2              ldx #$00                ; reverse
                lda #bomberMinX
                bpl @common             ; always

@right          sec
                adc bomber_x
                cmp #bomberMaxX
                bcc @common
                ldx #$ff                ; reverse
                lda #bomberMaxX
@common         bit game_state          ; not if waiting to start or already ended
                bvs @still
                ldy bomb_vphase         ; not if just before/after bomb will drop
                cpy #17
                bcs @still
                cpy #2
                bcc @still
                stx bomber_dir
                sta bomber_x
@still

;*** check for bomb being caught

; check for bomb missed
check_bomb_missed
                lda bomb_frames+7
                beq @8
                ldx bomb_vphase
                cpx #12
                bcc @8
                jmp explode_next
@8

update_bombs
; randomize bomb frame and count active bombs
                lda #0
                sta active_bombs
                ldx #7                  ; versus 8 in original
@1              lda bomb_frames,x
                beq @2
                dec active_bombs
                jsr random
                eor vblank_count
                and #$03
                clc
                adc #1
                ldy bomb_frames,x
                beq @2
                sta bomb_frames,x
@2              dex
                bpl @1

; adjust bomb_phase by dy
                ldy game_wave
                lda bomb_vphase
                clc
                adc wave_bomb_dy,y
                sta bomb_vphase
                sec
                sbc #bombPhaseDy
                bcc @no_new_bomb
                sta bomb_vphase

; shift bomb buffers to make room for new bomb
                ldx #6                  ; versus 7 in original
@3              lda bomb_columns,x
                sta bomb_columns+1,x
                lda bomb_frames,x
                sta bomb_frames+1,x
                dex
                bpl @3
                lda #0
                sta bomb_frames+0

                ldx game_wave
                bit game_state
                bvc @4
                lda active_bombs
                ora splash_frame
                bne @no_new_bomb
                asl game_state
                ldx game_wave
                cpx #gameWaveMax
                bcs @4
                inx
                stx game_wave
@4              txa
                lsr
                bcs @5
; drop bombs less frequently on even waves
                lda bomb_frames+1
                bne @no_new_bomb
@5              inc bombs_dropped
                lda bombs_dropped
                cmp bombs_per_wave,x
                bcc @6
                lda #0
                sta bombs_dropped
; if all bombs caught, change game state
                lda #$7F
                sta game_state
@6              lda random_seed
                and #$08
; *** use random seed & 0x08 to flip bomb horizontally
                lda #1
                sta bomb_frames+0

;*** pick new position, etc.
;*** bad alignment -- center on bomber after move ***
                lda bomber_x
                asl
                tax
                lda div7,x
                and #$FE
                bne @7
                lda #2                  ;*** fix with bomber instead
@7              sta bomb_columns+0
                ; *** also clamp to right side? ***
@no_new_bomb

update_sounds
; *** update splash frame

                jsr sync
                jmp game_loop

bombs_per_wave  .byte 9
                .byte 20
                .byte 30
                .byte 40
                .byte 50
                .byte 75
                .byte 100
                .byte 150

;---------------------------------------

clear_vars      lda #0
                ldx #$1f-8              ; -8 to exclude bomb_columns
@1              sta player_num,x
                dex
                bpl @1
                rts

;---------------------------------------

; Sync to line just before CallaVision logo using
;   vaporlock method.  Note that 5 matches of magic
;   value must be seen in order to distinguish active
;   scan matches from hsync and vsync.
sync            lda #vaporlockBlack
@1              cmp $c050               ; 4
                bne @1                  ; 2/3
                nop                     ; 2
                cmp $c050               ; 4
                bne @1                  ; 2/3
                nop                     ; 2
                cmp $c050               ; 4
                bne @1                  ; 2/3
                nop                     ; 2
                cmp $c050               ; 4
                bne @1                  ; 2/3
                nop                     ; 2
                cmp $c050               ; 4
                bne @1                  ; 2/3
                rts

;---------------------------------------

fill_screen
; fill solid white lines
;*** set high bit for lines covered by score digits ***
                ldx #0
@1              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #0
                lda #$7e
                sta (screenl),y
                iny
                lda #$7f
@2              sta (screenl),y
                iny
                cpy #40
                bne @2
                inx
                cpx #topHeight
                bne @1

; fill solid green lines
@3              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #0
                lda #$2a
@4              sta (screenl),y
                eor #$7f
                iny
                cpy #40
                bne @4
                inx
                cpx #topHeight+centerHeight
                bne @3

; fill the first line with $80 black, for "vaporlock" detection,
;   and the rest with $00 black
                lda #vaporlockBlack
@5              ldy hires_table_lo,x
                sty screenl
                ldy hires_table_hi,x
                sty screenh
                ldy #39
@6              sta (screenl),y
                dey
                bpl @6
                lda #$00                ; normal black
                inx
                cpx #topHeight+centerHeight+bottomHeight
                bne @5
                rts

;---------------------------------------

advance_logo    lda logo_offset
                clc
                adc #logoWidth
                cmp #logoHeight*logoWidth
                bne @1
                lda #0
@1              sta logo_offset
                ; fall through

draw_logo       lda logo_offset
                sta offset
                ldx #topHeight+centerHeight+1
@1              stx linenum
                lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #logoLeft
                ldx offset
@2              lda logo_graphic,x
                sta (screenl),y
                inx
                iny
                cpy #logoLeft+logoWidth
                bne @2
                cpx #logoWidth*logoHeight
                bne @3
                ldx #0
@3              stx offset
                ldx linenum
                inx
                cpx #topHeight+centerHeight+1+7
                bne @1
                rts

logo_graphic    .byte $00,$00,$00,$00,$a8,$d5,$aa,$81,$a8,$d5,$82,$00,$00,$00,$00   ; callavision
                .byte $00,$00,$00,$00,$00,$00,$00,$81,$8a,$00,$00,$00,$00,$00,$00
                .byte $00,$d4,$a8,$91,$a0,$c0,$8a,$c1,$82,$95,$a2,$c5,$a0,$00,$00
                .byte $00,$84,$88,$91,$a0,$c0,$88,$d1,$88,$81,$a2,$c4,$a2,$00,$00
                .byte $00,$84,$a8,$91,$a0,$c0,$8a,$95,$88,$95,$a2,$c4,$aa,$00,$00
                .byte $00,$84,$88,$91,$a0,$c0,$88,$85,$88,$90,$a2,$c4,$a8,$00,$00
                .byte $00,$d4,$88,$d1,$a2,$c5,$88,$81,$88,$95,$a2,$c5,$a0,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $a8,$81,$00,$00,$00,$c0,$80,$90,$a0,$c0,$8a,$95,$aa,$c4,$80   ; copyright 2024
                .byte $88,$80,$00,$00,$00,$00,$00,$90,$a8,$81,$88,$91,$a0,$c4,$80
                .byte $88,$d0,$a2,$c5,$88,$c5,$a8,$d1,$a2,$c0,$8a,$91,$aa,$d4,$80
                .byte $88,$90,$a2,$c4,$88,$c1,$88,$91,$a2,$c0,$80,$91,$82,$c0,$80
                .byte $a8,$d1,$a2,$c5,$8a,$c1,$a8,$91,$a2,$c0,$8a,$95,$aa,$c0,$80
                .byte $00,$00,$a0,$80,$88,$00,$80,$81,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$a0,$c0,$8a,$00,$a8,$81,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;---------------------------------------

;
; pseudo random number generator,
;   taken verbatim from Kaboom VCS
;
; On exit:
;   A: random_seed value
;   C: bottom random_seed bit
;   X,Y: unchanged
;
random          lsr random_seed
                rol
                eor random_seed
                lsr
                lda random_seed
                bcs @1
                ora #$40
                sta random_seed
@1              rts
;
; Modified version of Apple II monitor ROM code.
;   This pads the cycle count so it takes the same
;   amount of time (about 2850 cycles), regardless
;   of the paddle value.
;
; On entry:
;   X: paddle to read (0-1)
;
; On exit:
;   Y: paddle value (0-255)
;
; 2834 cycles maximum
;
; TODO: maybe just select a 140 count range within 0-255
;
read_paddle     lda $c070               ; trigger paddles
                ldy #$00                ; init count
                nop                     ; compensate for 1st count
                nop
@1              lda $c064,x             ; 4  count Y-reg every
                bpl @2                  ; 2    12 usec [actually 11]
                iny                     ; 2
                bne @1                  ; 3  exit at 255 max
                dey
                rts
@2              sty temp                ; 3
@3              lda $c064,x             ; 4
                nop                     ; 2 bpl not taken
                iny                     ; 2
                bne @3                  ; 3/2
                ldy temp                ; 3
                rts

;---------------------------------------

                .include "bomber.s"
                .include "bombs.s"
                .include "buckets.s"
                .include "score.s"
                .include "tables.s"

; new Callavision graphic
                ;{"x":70,"y":183,"width":112,"height":7}
                ; hex 80502a55ff8380fcffff81fcff838080
                ; hex 80d4aad58380808080c0818f80808080
                ; hex 80d4aaf581fc99b0e0cfe1c39ff3e7b0
                ; hex 802a556a80cc99b0e0ccf9cc81b3e6b3
                ; hex 80d5aab580fc99b0e0cf9fcc9fb3e6bf
                ; hex 80d5aabd80cc99b0e0cc878c98b3e6bc
                ; hex c0aad5febfccf9f3e7cc81cc9ff3e7b0
