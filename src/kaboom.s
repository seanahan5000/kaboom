;
; Design notes:
;   - Algorithms taken from disassembled VCS Kaboom!
;   - Graphics taken from VCS and made to match as closely as possible
;   - Goal is to run at a solid 60fps (1023000 / 60 = 17050 cycles per frame)
;   - All drawing should be as fast a possible but limited to worst case
;       - Want frame rate to be stable
;

; Timing:
;   Paddle          2850
;   Score            775
;   Bomber          2020
;   Bombs           4270
;   Bucket Erase    1100
;   Bucket Draw     1655
;   --------------------
;   Total          12670

; TODO
;   * fix bomb phase 0 cycle spike
;       * add extra clipping
;   - flipped bombs
;   - bucket splash animation
;   - bucket/bomb hit detection
;   - bomb exposion sequence
;   - bomber holding bomb
;   - bomber smile/frown
;   - logo/copyright animation
;   - "vaporlock" sync
;   ? small/difficult buckets/splashes (unlikely)

; *** narrower bomber?
; *** reduce bomber erase by wave
; *** reduce bomb overdraw by wave
; *** match bomber start position to VCS
; *** figure out bomb dx spacing
    ; *** update bombs top to bottom, if possible
; *** add white hilite in buckets
; *** shorten bucket top line
; *** splash could be trimmed down to 42 bytes (6*7)
; *** could score shift6 be removed?
; *** make logo/copyright white? add rainbow?

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

bombsTop        =   topHeight
bombsBottom     =   bombsTop+centerHeight

bomberMinX      =   5
bomberMaxX      =   125                 ; inclusive

bucketsMinX     =   3
bucketsMaxX     =   121                 ; inclusive

bucketByteWidth =   6

logoLeft        =   13
logoWidth       =   15
logoHeight      =   16

temp            :=  $00
offset          :=  $01
linenum         :=  $02
temp_xcol       :=  $03
temp_xshift     :=  $04

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
logo_offset     :=  $1C

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
bomb_index      :=  $92                 ;*** temp counter
start_line      :=  $93
end_line        :=  $94
temp_ptr        :=  $95
temp_ptr_h      :=  $96

; bomb code generation $a0-$a8

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
                lda #80
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

; intialize digits buffer to "no digits"
                ldx #5
                lda #$0A
@1              sta cur_digits,x
                dex
                bpl @1

                lda game_wave
                lsr
                clc
                adc #1
                sta bomb_dy

                lda #0
                sta bomb_phase

                lda #0                  ;***
                sta splash_bucket
                lda #0                  ;***
                sta splash_frame

game_loop       jsr draw_score
                ; jsr erase_buckets     ;***
                jsr draw_bombs
                jsr update_bombs        ;*** move later

                ; jsr advance_logo        ;***
                ; *** pause on logo_offset == 0 and (logoHeight/2)*logoWidth

                ; randomly change bomber's direction
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
                bit bomber_dir
                bpl bomber_right

bomber_left     eor #$ff
                clc
                adc bomber_x
                cmp #bomberMinX+1
                bcc @1
                cmp #$f0
                bcc @2
@1              ldx #$00
                stx bomber_dir
                lda #bomberMinX
@2              sta bomber_x
                jsr move_bomber_left
                jmp buckets

bomber_right    adc bomber_x
                cmp #bomberMaxX
                bcc @1
                ldx #$ff
                stx bomber_dir
                lda #bomberMaxX
@1              sta bomber_x
                jsr move_bomber_right

buckets         ldx #0
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
                jsr erase_buckets       ;***
                jsr draw_buckets
                inc vblank_count

; TODO: "vaporlock" sync here

                jmp game_loop

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
                lda #$80                ; "vaporlock" black
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
                bpl @4                  ; 2    12 usec [actually 11]
                iny                     ; 2
                bne @1                  ; 3  exit at 255 max
                dey
                rts
@4              sty temp                ; 3
@3              lda $c064,x             ; 4
                nop                     ; 2 bpl not taken
                iny                     ; 2
                bne @3                  ; 3/2
@5              ldy temp                ; 3
                rts

;---------------------------------------

                .include "bomber.s"
                .include "bombs.s"
                .include "buckets.s"
                .include "score.s"
                .include "tables.s"
