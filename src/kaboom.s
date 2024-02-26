
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

; TODO
; - rotate logo versus copyright

; 1023000 cycles / 60fps = 17050 cycles/frame

topHeight       =   40
centerHeight    =   142
bottomHeight    =   10

bombsTop        =   topHeight
bombsBottom     =   bombsTop+centerHeight

bomberMinX      =   5
bomberMaxX      =   125                 ; inclusive

bucketsMinX     =   3
bucketsMaxX     =   121                 ; inclusive

bucketByteWidth =   6

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

; *** clean up
prev_start_col  :=  $17
prev_end_col    :=  $18
hold_col        :=  $1E
hold_shift      :=  $1F

screenl         :=  $24
screenh         :=  $25

; score variables
mask            :=  $80
data_ptr        :=  $81
data_ptr_h      :=  $82

; bombs variables
bomb_phase      :=  $90
bomb_dy         :=  $91
bomb_index      :=  $92                 ;*** temp counter
start_line      :=  $93
end_line        :=  $94
temp_ptr        :=  $95
temp_ptr_h      :=  $96

; score variables
score           =   $a0                 ; $a0,$a1,$a2
digit_index     =   $a3
saw_digit       =   $a4

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

                sta prev_start_col
                lda #1
                sta prev_end_col

                jsr init_screen

                lda #$00
                sta score+0
                sta score+1
                sta score+2

                sta primary
                sta fullscreen
                sta hires
                sta graphics

                jsr draw_score
                ; jsr draw_score

                jsr init_bombs          ;***

                lda game_wave
                lsr a
                clc
                adc #1
                sta bomb_dy

                lda #0
                sta bomb_phase
game_loop
                jsr draw_bombs
                jsr update_bombs        ;*** move later

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

buckets_right   lsr a
                clc
                adc buckets_x
                cmp #bucketsMaxX
                bcc @1
                lda #bucketsMaxX
@1              sta buckets_x
                jsr move_buckets_right
                inc vblank_count
                jmp game_loop

buckets_left    sec
                ror a
                clc
                adc buckets_x
                cmp #bucketsMinX
                bcs @1
                lda #bucketsMinX
@1              sta buckets_x
                jsr move_buckets_left
                inc vblank_count
                jmp game_loop
;
; pseudo random number generator,
;   taken verbatim from Kaboom VCS
;
; On exit:
;   A: random_seed value
;   C: bottom random_seed bit
;
random          lsr random_seed
                rol a
                eor random_seed
                lsr a
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

; not actually used
; clear1          ldx #0
;                 txa
;                 ldy #$20
; :               sty :+ + 2
; :               sta $2000,x             ; modified
;                 inx
;                 bne :-
;                 iny
;                 cpy #$40
;                 bne :--
;                 rts

init_screen
;
; fill solid white lines
;
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
;
; fill solid green lines
;
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
;
; fill solid black lines
;
@5              lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #0
                tya
@6              sta (screenl),y
                iny
                cpy #40
                bne @6
                inx
                cpx #topHeight+centerHeight+bottomHeight
                bne @5
;
; draw callavision graphic
;
                lda #0
                sta offset
                ldx #topHeight+centerHeight+1
@7              stx linenum
                lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldy #14
                ldx offset
@8              lda callavision,x
                sta (screenl),y
                inx
                iny
                cpy #26
                bne @8
                stx offset
                ldx linenum
                inx
                cpx #topHeight+centerHeight+1+7
                bne @7
                rts

callavision     .byte $80,$80,$80,$a8,$d5,$aa,$81,$a8,$d5,$82,$80,$80
                .byte $80,$80,$80,$80,$80,$80,$81,$8a,$80,$80,$80,$80
                .byte $d4,$a8,$91,$a0,$c0,$8a,$c1,$82,$95,$a2,$c5,$a0
                .byte $84,$88,$91,$a0,$c0,$88,$d1,$88,$81,$a2,$c4,$a2
                .byte $84,$a8,$91,$a0,$c0,$8a,$95,$88,$95,$a2,$c4,$aa
                .byte $84,$88,$91,$a0,$c0,$88,$85,$88,$90,$a2,$c4,$a8
                .byte $d4,$88,$d1,$a2,$c5,$88,$81,$88,$95,$a2,$c5,$a0

; *** add copyright image ***

copyright_2024
                ;{"x":91,"y":159,"width":105,"height":8}
                .byte $a8,$81,$80,$80,$80,$c0,$80,$90,$a0,$c0,$8a,$95,$aa,$c4,$80
                .byte $88,$80,$80,$80,$80,$80,$80,$90,$a8,$81,$88,$91,$a0,$c4,$80
                .byte $88,$d0,$a2,$c5,$88,$c5,$a8,$d1,$a2,$c0,$8a,$91,$aa,$d4,$80
                .byte $88,$90,$a2,$c4,$88,$c1,$88,$91,$a2,$c0,$80,$91,$82,$c0,$80
                .byte $a8,$d1,$a2,$c5,$8a,$c1,$a8,$91,$a2,$c0,$8a,$95,$aa,$c0,$80
                .byte $80,$80,$a0,$80,$88,$80,$80,$81,$80,$80,$80,$80,$80,$80,$80
                .byte $80,$80,$a0,$c0,$8a,$80,$a8,$81,$80,$80,$80,$80,$80,$80,$80
                .byte $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80

                .include "bomber.s"
                .include "bombs.s"
                .include "buckets.s"
                .include "score.s"
                .include "tables.s"
