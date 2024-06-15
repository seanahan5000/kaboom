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
;   - bomb exposion sequence
;   - bomber smile/frown
;   - logo/copyright animation

; *** bomb not dropping in right-most column

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

bomb0Top        =   28
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

vblank_count    :=  $10
game_wave       :=  $11
bucket_count    :=  $12
buckets_x       :=  $13
bomber_x        :=  $14
bomber_dir      :=  $15
random_seed     :=  $16
score           :=  $17                 ; $17,$18,$19

bucket_xcol     :=  $1A
bucket_xshift   :=  $1B
hit_xcol        :=  $1C
hit_xshift      :=  $1D
logo_offset     :=  $1E
game_state      :=  $1F
active_bombs    :=  $20
bombs_dropped   :=  $21

screenl         :=  $24
screenh         :=  $25

splash_bucket   :=  $75
splash_frame    :=  $76

; score variables
lmask           :=  $80
rmask           :=  $81
data_ptr        :=  $82
data_ptr_h      :=  $83

; *** move to "permanent" zpage
cur_digits      :=  $84                 ; $84,$85,$86,$87,$88,$89
; *** temporary buffer
new_digits      :=  $8a                 ; $8a,$8b,$8c,$8d,$8e,$8f

; bombs variables
bomb_phase      :=  $90
bomb_dy         :=  $91
bomb_index      :=  $92
start_line      :=  $93
end_line        :=  $94
bomb_ptr        :=  $95
bomb_ptr_h      :=  $96

player_num      :=  $a0

; bomb code generation $a0-$a8

bomb_frames     :=  $b0                 ; $b0-$b7
bomb_columns    :=  $b8                 ; $b8-$bf

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
                sta game_wave
                lda #3
                sta bucket_count
                lda #80
                sta buckets_x
                lda #70
                sta bomber_x
                lda #0
                sta bomber_dir
                sta vblank_count
                sta random_seed
                sta logo_offset
                sta bucket_xcol
                sta bucket_xshift

                jsr fill_screen
                jsr draw_logo

                lda #$00
                sta score+0
                sta score+1
                sta score+2

                sta primary
                sta fullscreen
                sta hires
                sta graphics

                jsr init_bombs          ;***

                lda #0
                tax
@0              sta bomb_frames,x
                sta bomb_columns,x
                inx
                cpx #8
                bne @0

                lda #1                  ;***
                sta bomb_frames+0
                lda #20
                sta bomb_columns+0

                lda #0
                sta player_num

                ; *** move to reset ***
                lda #$ff
                sta game_state
                lda #0
                sta bombs_dropped

; intialize digits buffer to "no digits"
                ldx #5
                lda #$0A
@1              sta cur_digits,x
                dex
                bpl @1

                ;*** common wave-begin code ***
                lda game_wave
                lsr
                clc
                adc #1
                sta bomb_dy

                lda #bombPhaseDy
                sec
                sbc bomb_dy
                sta bomb_phase

                lda #0
                sta splash_bucket
                sta splash_frame

game_loop
; *** check keys? ***

                jsr draw_score

                jsr erase_bomber
                jsr erase_top_bomb

                ; jsr advance_logo        ;***
                ; *** pause on logo_offset == 0 and (logoHeight/2)*logoWidth

                bit game_state
                bpl @running
                ldy #0
                ldx player_num
                lda pbutton0,x
                bpl @0
                ; wave is now in progress
                sty game_state
@0              sty bomb_phase          ;***???
                jmp bomber_still

@running
                ; periodically/randomly change bomber's direction
                lda vblank_count
                and #$0f
                bne @1
                jsr random
                bcs @1
                lda bomber_dir
                eor #$ff
                sta bomber_dir
@1
                ; move bomber by +/- game_wave+1
                sec
                lda game_wave
                ldx bomber_dir
                bpl bomber_right
bomber_left     eor #$ff
                clc
                adc bomber_x
                cmp #bomberMinX+1
                bcc @1
                cmp #$f0
                bcc bomber_cmn
@1              ldx #$00
                lda #bomberMinX
                bpl bomber_cmn          ; always

bomber_right    adc bomber_x
                cmp #bomberMaxX
                bcc bomber_cmn
                ldx #$ff
                lda #bomberMaxX
bomber_cmn      bit game_state          ; not if waiting to start or already ended
                bvs bomber_still
                ldy bomb_phase          ; not if just before/after bomb will drop
                cpy #17
                bcs bomber_still
                cpy #2
                bcc bomber_still
                stx bomber_dir
                sta bomber_x
bomber_still    jsr draw_bomber

update_bombs
; randomize bomb frame and count active bombs
                lda #0
                sta active_bombs
                ldx #7                  ;*** original uses 8!
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
                lda bomb_phase
                clc
                adc bomb_dy
                sta bomb_phase          ;***
                tax
                sec
                sbc #bombPhaseDy
                bcc @no_new_bomb
                sta bomb_phase

; shift bomb buffers to make room for new bomb
                ldx #6                  ;*** original uses 7
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
; *** do this in some common area?
                txa
                lsr
                clc
                adc #1
                sta bomb_dy
                ; *** just use lookup? ***
@4              txa
                lsr
                bcs @5
; *** every other wave, do something differently
                lda bomb_frames+1
                bne @no_new_bomb
@5              inc bombs_dropped
                lda bombs_dropped
                cmp bombs_per_wave,x
                bcc @6
                lda #0
                sta bombs_dropped
                lda #$7f
                sta game_state
                ; ***
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

;*** where should this be done?
                ldx bomb_phase
                ;*** phase w/bomb 1 line from bottom
                cpx #14
                bcc @8
                lda #0
                sta bomb_frames+7
                ; *** not getting erased ***
@8

                ; lda bomb_frames+0
                ; beq @9                  ; *** fix this
                jsr draw_top_bomb
; @9
                jsr draw_bombs
                jsr draw_buckets

; TODO: should paddle range be centered on screen?
; TODO: can read_paddle be faster if end of range never needed?
buckets         ldx player_num
                jsr read_paddle
                tya
                sec
                sbc buckets_x
                bcc buckets_left
buckets_right   lsr
                clc
                adc buckets_x
                cmp #bucketsMaxX
                bcc buckets_cmn
                lda #bucketsMaxX
                bcs buckets_cmn         ; always

buckets_left    sec
                ror
                clc
                adc buckets_x
                cmp #bucketsMinX
                bcs buckets_cmn
                lda #bucketsMinX
buckets_cmn     sta buckets_x
                inc vblank_count

; Sync to line just before CallaVision logo using
;   vaporlock method.  Note that 5 matches of magic
;   value must be seen in order to distinguish active
;   scan matches from hsync and vsync.
                lda #vaporlockBlack
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
