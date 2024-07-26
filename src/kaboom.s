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

;   Update score      794
;   Erase bomber      543
;   Erase top bomb    277
;   Draw bomber      1099
;   Update bombs     6316
;  (Draw top bomb     928)
;  (Erase buckets    1048)
;   Draw buckets     1463
;   Read paddle      3105
;   ---------------------
;   Total cycles   ~13600 (~14350 measured)

; TODO
; - test flash tearing in AppleWin etc.
; ? add white to explosion flash sequence
;   - (more code, flip eor or not)
; ? instruction screen - S: Select, R: Reset
; ? consider moving bomb code guts into main loop
; ? always add something to score for constant timing
; ? always do full bomb/bucket hit test for constant timing

.feature labels_without_colons
; .feature bracket_as_indirect

.macro same_page_as arg
    .if ((* - 1) / 256) <> (arg / 256)
        .error .sprintf("### page crossing detected at $%0.4x -> $%0.4x", arg, *)
    .endif
.endmacro

scoreHeight     =   9                   ; blank line + digits
topHeight       =   scoreHeight + 31
centerHeight    =   142
bottomHeight    =   10

scoreLeft       =   75

bomb0Top        =   29
bombPhaseDy     =   18
bombsTop        =   bomb0Top+bombPhaseDy
bombsBottom     =   topHeight+centerHeight
bombMaxDy       =   4

bomberMinX      =   7                   ; inclusive
                                        ;   must be X * 2 div 7 == 2
                                        ;           X * 2 mod 7 == 0
bomberMaxX      =   126                 ; inclusive
                                        ;   must be X * 2 div 7 == 36
                                        ;           X * 2 mod 7 == 0
bucketsMinX     =   3                   ; inclusive
bucketsMaxX     =   121                 ; inclusive

bucketTopY      =   141
bucketMidY      =   157
bucketBotY      =   173
bucketHeight    =   8

bucketByteWidth =   6

logoLeft        =   12
logoByteWidth   =   16
logoHeight      =   16

vaporlockBlack  =   $80

gameWaveMax     =   7

temp            :=  $00
offset          :=  $01
linenum         :=  $02
column          :=  $03
ptr             :=  $04
ptr_h           :=  $05
;
;
bucket_xcol     :=  $08
bucket_xshift   :=  $09
hit_xcol        :=  $0a
hit_xshift      :=  $0b
logo_offset     :=  $0c
;
screenl         :=  $0e
screenh         :=  $0f

; init_bombs uses $50-$58

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
cur_digits      :=  $74                 ; $74,$75,$76,$77,$78,$79
new_digits      :=  $7a                 ; $7a,$7b,$7c,$7d,$7e,$7f

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
player_buckets  :=  $a1
player_wave     :=  $a2
player_score    :=  $a3                 ; $a3,$a4,$a5

other_state     :=  $a6
other_buckets   :=  $a6
other_wave      :=  $a7
other_score     :=  $a8                 ; $a8,$a9,$aa

bombs_dropped   :=  $ab
exp_bomb_index  :=  $ac
game_state      :=  $ad
exp_bomb_frame  :=  $ae
splash_frame    :=  $af

bonus_sound     :=  $b0
bomb_vphase     :=  $b1
;
bomb_frames     :=  $b3                 ; $b3-$ba
bomb_columns    :=  $bb                 ; $bb-$c2
                                        ; (end of reset clear)
                                        ; (end of init clear)

; pointers to bomb blitting code
table_buffer0_lo =  $1000
table_buffer1_lo =  $1100
table_buffer2_lo =  $1200
table_buffer3_lo =  $1300
table_buffer0_hi =  $1400
table_buffer1_hi =  $1500
table_buffer2_hi =  $1600
table_buffer3_hi =  $1700

; bomb and bucket clipping buffer
clip_buffer     =   $1800

; sound pattern buffers
tone6_buffer    =   $1900
noise9_buffer   =   $1A00

; bomb blitting code
code_buffer0    =   $4000
code_buffer1    =   $4800
code_buffer2    =   $5000
code_buffer3    =   $5800

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
; clear all variables
                lda #0
                ldx #$42
@1              sta game_select,x
                dex
                bpl @1

; invalidate current logo offset
                lda #$ff
                sta logo_offset

; center bomber instead of on left like original game
                lda #70
                sta bomber_x

                jsr init_bombs
;               jsr init_sound
                jsr init_screen
                jmp start_game

game_loop       lda exp_bomb_frame
                beq @1
                cmp #$20-1              ; -1 for erase frame
                bcs @1
                jsr flash_screen
                jmp cont_explode

@1              jsr draw_score
                jsr erase_bomber
                jsr erase_top_bomb
                jsr draw_bomber
                jsr draw_bombs
                jsr draw_buckets
                jsr draw_logo

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

                inc vblank_count

; check for reset and select
check_keys      lda keyboard
                bpl keys_checked
                bit unstrobe
                and #%01011111          ; force upper case
                cmp #'S'
                beq @select
                cmp #'R'
                beq reset
                bne keys_checked        ; always

@select         inc game_select
start_game      jsr clear_screen
                jsr clear_vars
                lda game_select
                and #$01
                sta game_select
                tay
                iny
                sty player_score+2

                sta primary
                sta fullscreen
                sta hires
                sta graphics
                jmp keys_checked

reset           jsr clear_screen
                jsr clear_vars
                ldx #$ff
                stx game_state
                asl game_select
                sec
                ror game_select
                lda #3
                sta player_buckets
                sta other_buckets

keys_checked    bit game_select
                bpl @1
                lda player_buckets
                bne @2
; no buckets so idle
                lda vblank_count
                and #$7F
                beq swap_player
@1              jmp finish_field

; handle exploding bomb animation
@2              lda exp_bomb_frame
                beq no_explode
                cmp #$20-1              ; -1 for erase frame
                bcc cont_explode
                beq @3
                dec exp_bomb_frame
                jmp finish_field

; clear bomb that has finished exploding
@3              ldx exp_bomb_index
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

; no more bombs to explode
                lda #$20-1              ; -1 for erase frame
                sta exp_bomb_frame
cont_explode    dec exp_bomb_frame
                beq @1
                jmp finish_field

@1              lda bonus_sound
                bne @2
; take away a bucket
                dec player_buckets
@2
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

                jsr clear_score

; toggle player number
                lda player_num
                eor #$01
                sta player_num

; decrement wave when player restarts
next_wave       ldx player_wave
                txa
                beq @1
; give them half as many bombs to catch
; (set bombCount to half already caught)
                dex
                stx player_wave
                lda bombs_per_wave,x
                lsr
                clc
                adc #1
@1              sta bombs_dropped
                ldx #$FF
                stx game_state
                jmp finish_field

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
                lda #0
                jmp start_wave

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
                lda player_wave
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
                bvc @move
; align after bomber has stopped moving
                jsr align_bomber
                jmp @still

@move           ldy bomb_vphase         ; not if just before/after bomb will drop
                cpy #17
                bcs @still
                cpy #2
                bcc @still
                stx bomber_dir
                sta bomber_x
@still

; check for bomb missed
check_bomb_missed
                lda bomb_frames+7
                beq @8
                ldx bomb_vphase
                cpx #12
                bcc @8
; align before explosions start and bomber stops moving
                jsr align_bomber
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
                ldy player_wave
                lda bomb_vphase
                clc
                adc wave_bomb_dy,y
                sta bomb_vphase
                sec
                sbc #bombPhaseDy
                bcc no_new_bomb
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

                ldx player_wave
                bit game_state
                bvc @4
                lda active_bombs
                ora splash_frame
                bne no_new_bomb
                asl game_state
                ldx player_wave
                cpx #gameWaveMax
                bcs @4
                inx
                stx player_wave
@4              txa
                lsr
                bcs @5
; drop bombs less frequently on even waves
                lda bomb_frames+1
                bne no_new_bomb
@5              inc bombs_dropped
                lda bombs_dropped
                cmp bombs_per_wave,x
                bcc @6
                lda #0
                sta bombs_dropped
; if all bombs caught, change game state
                lda #$7F
                sta game_state
@6
; use random seed & 0x08 to flip bomb horizontally, move to low bit
                lda random_seed
start_wave      lsr
                lsr
                lsr
                lsr
                php

; bomber always holds bomb with unlit fuse
                lda #1
                sta bomb_frames+0

; pick new bomb position
                lda bomber_x
                asl
;               clc
                adc #3                  ; bomberMaxX * 2 + 3 == 255
                tax
                lda div7,x
                plp
                rol                     ; apply hflip flag
                sta bomb_columns+0
no_new_bomb

finish_field
;               jsr update_sound

; choose smile/frown for bomber
update_mouth    lda player_score+0             ; frown if score >= 10000
                bne @1
                lda exp_bomb_frame      ; smile if bombs exploding
                bne @2
                lda player_buckets      ; smile if out of buckets
                beq @2
@1              jsr apply_frown
                jmp @3
@2              jsr apply_smile
@3
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

; Move bomber to a location that matches up
;   with the two possible bomb locations.

align_bomber    lda bomber_x
                asl
                tax
                ldy mod7,x
                lda @align_table,y
                clc
                adc bomber_x
                cmp #bomberMinX+1
                bcs @1
                lda #bomberMinX
@1              cmp #bomberMaxX
                bcc @2
                lda #bomberMaxX
@2              sta bomber_x
                rts

                ;       0   1   2   3   4   5   6
@align_table    .byte $00,$ff,$ff,$fe,$01,$01,$00
                ;       0   6   0   6   6   0   6

;---------------------------------------

clear_vars      lda #0
                ldx #$1f
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

init_screen
; fill solid white #$FF lines for score, except for
;   first and last column to avoid color artifacts
                ldx #0
@1              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #39
                lda #$7f
                sta (screenl),y
                dey
                lda #$ff
@2              sta (screenl),y
                dey
                bne @2
                lda #$7e
                sta (screenl),y
                inx
                cpx #scoreHeight
                bne @1

; fill solid white #$7F lines below score
@3              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #39
                lda #$7f
@4              sta (screenl),y
                dey
                bne @4
                lda #$7e
                sta (screenl),y
                inx
                cpx #topHeight
                bne @3

; fill solid green lines
@5              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #39
                lda #$55
@6              sta (screenl),y
                eor #$7f
                dey
                bpl @6
                inx
                cpx #topHeight+centerHeight
                bne @5

; fill the first line with $80 black for "vaporlock" detection,
;   and the rest with $00 black
                lda #vaporlockBlack
@7              ldy hires_table_lo,x
                sty screenl
                ldy hires_table_hi,x
                sty screenh
                ldy #39
@8              sta (screenl),y
                dey
                bpl @8
                lda #$00                ; normal black
                inx
                cpx #topHeight+centerHeight+bottomHeight
                bne @7
                jsr draw_logo
                jmp clear_digits

; remove everything on the screen related to the current game
clear_screen    jsr sync
                lda player_num
                bne @1
                lda #0
                sta player_score+0
                sta player_score+1
                sta player_score+2
                jsr draw_score
@1              jsr erase_bomber
                jsr erase_top_bomb

                jsr align_bomber
                jsr draw_bomber

                lda #$20
                cmp exp_bomb_frame
                bcs @2
                sta exp_bomb_frame
@2
                ldx #0
                txa
                ldy bomb_vphase
                bne @3
                ldy exp_bomb_frame
                bne @3
; skip clearing first bomb if it's in the bomber's hands
                inx
@3              sta bomb_frames,x
                inx
                cpx #8
                bne @3

                jsr draw_bombs
                lda #0
                sta splash_frame
                lda player_buckets
                beq @4
                lda #3
                sta player_buckets
@4              jsr draw_buckets

                lda player_num
                beq @5
                jsr clear_score
@5              rts

clear_score     ldx #1
@1              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #scoreLeft/7
                lda #$ff
@2              sta (screenl),y
                iny
                cpy #scoreLeft/7+19
                bne @2
                inx
                cpx #scoreHeight
                bne @1
                ; fall through

; intialize digits buffer to "no digits"
clear_digits    ldx #5
                lda #$0A
@1              sta cur_digits,x
                dex
                bpl @1
                rts

;---------------------------------------

draw_logo       ldy #128
                lda player_buckets
                bne @1
                lda vblank_count
                lsr
                lsr
                lsr
                cmp #$10
                bcs @1
                ldy #0
;               sec
                sbc #$08-1
                bcc @1
                asl
                asl
                asl
                asl
                tay
@1              cpy logo_offset
                beq @4
                sty logo_offset
                sty offset
                ldx #topHeight+centerHeight+1
@2              stx linenum
                lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #logoLeft
                ldx offset
@3              lda logo_graphic,x
                sta (screenl),y
                inx
                iny
                cpy #logoLeft+logoByteWidth
                bne @3
                stx offset
                ldx linenum
                inx
                cpx #topHeight+centerHeight+1+7
                bne @2
@4              rts

logo_graphic    .byte $00,$00,$fe,$80,$00,$00,$00,$b0,$80,$8c,$98,$f0,$e7,$cf,$9f,$b3 ; copyright 2024
                .byte $00,$00,$86,$80,$00,$00,$00,$80,$80,$8c,$fe,$80,$e6,$8c,$98,$b3
                .byte $00,$00,$86,$fc,$f9,$b3,$e6,$b3,$fe,$fc,$99,$f0,$e7,$cc,$9f,$bf
                .byte $00,$00,$86,$cc,$99,$b3,$e6,$b0,$e6,$cc,$99,$b0,$e0,$cc,$81,$b0
                .byte $00,$00,$fe,$fc,$f9,$f3,$e7,$b0,$fe,$cc,$99,$f0,$e7,$cf,$9f,$b0
                .byte $00,$00,$80,$80,$98,$80,$86,$80,$e0,$80,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$80,$80,$98,$f0,$87,$80,$fe,$80,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

                .byte $2a,$55,$2a,$55,$ff,$83,$80,$fc,$ff,$ff,$81,$fc,$ff,$83,$00,$00 ; callavision
                .byte $aa,$d5,$aa,$d5,$83,$80,$80,$80,$80,$c0,$81,$8f,$80,$80,$00,$00
                .byte $aa,$d5,$aa,$f5,$81,$fc,$99,$b0,$e0,$cf,$e1,$c3,$9f,$f3,$e7,$b0
                .byte $54,$2a,$55,$6a,$80,$cc,$99,$b0,$e0,$cc,$f9,$cc,$81,$b3,$e6,$b3
                .byte $aa,$d5,$aa,$b5,$80,$fc,$99,$b0,$e0,$cf,$9f,$cc,$9f,$b3,$e6,$bf
                .byte $aa,$d5,$aa,$9d,$80,$cc,$99,$b0,$e0,$cc,$87,$8c,$98,$b3,$e6,$bc
                .byte $d5,$aa,$d5,$fe,$bf,$cc,$f9,$f3,$e7,$cc,$81,$cc,$9f,$f3,$e7,$b0
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

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

;---------------------------------------
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
                .include "flash.s"
                .include "tables.s"
                .include "sound.s"
