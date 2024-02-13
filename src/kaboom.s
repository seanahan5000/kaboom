
.feature labels_without_colons
; .feature bracket_as_indirect

.macro set_page
set page = * / 256
.endmacro

.macro same_page
; ***
.endmacro

; TODO (general)
; - Beyond syntax: ca65, need way to turn options on/of
;   (turn off colons required on labels, for example)
; - .include file name must be quoted
; - Use hex or .bytes in copy/paste based on syntax?
; - Auto-complete gets confused by ":"
; X Test renumbering with @ cheap locals
; X make sure renumber locals works with trailing ":"
; - maybe separate syntax source file for CA65?
; - think more broadly about generalization
;   - could variations be more generalized?
;   - ':' on labels, for example
;   - hypothetically, how would 1000 different assemblers be handled?
; - auto-complete is weird when:
;   when tabbing in the middle of .byte$00 -- $ goes away

; TODO (game)
; - rotate logo versus copyright

; 1023000 cycles / 60fps = 17050 cycles/frame

PREAD           =   $FB1E

;  40  (80/2) top lines
; 142 (284/2) center lines
;  10  (20/2) bottom lines

topHeight       =   40                  ; ***  41
centerHeight    =   142                 ; *** 137
bottomHeight    =   10                  ; ***  14

bomberMinX      =   5
bomberMaxX      =   125                 ; inclusive

bucketsMinX     =   3
bucketsMaxX     =   121                 ; inclusive

bucketByteWidth =   6

offset          :=  $00
linenum         :=  $01

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

                .org $6000

kaboom
                lda #0                  ;***
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

                sta primary
                sta fullscreen
                sta hires
                sta graphics

game_loop
                jsr draw_bombs

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

buckets
; TODO: think about making PREAD time consistent (don't use ROM?)
                ldx #0
                jsr PREAD               ; read paddle 0 value
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
random          LSR random_seed
                ROL A
                EOR random_seed
                LSR A
                LDA random_seed
                BCS @1
                ORA #$40
                STA random_seed
@1              RTS


; not actually used
clear1          ldx #0
                txa
                ldy #$20
:               sty :+ + 2
:               sta $2000,x             ; modified
                inx
                bne :-
                iny
                cpy #$40
                bne :--
                rts

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
                .include "tables.s"
