
scoreLine0      =   hiresLine1
scoreLine1      =   hiresLine2
scoreLine2      =   hiresLine3
scoreLine3      =   hiresLine4
scoreLine4      =   hiresLine5
scoreLine5      =   hiresLine6
scoreLine6      =   hiresLine7
scoreLine7      =   hiresLine8

digit_x         .byte 0*18+77
                .byte 1*18+77
                .byte 2*18+77
                .byte 3*18+77
                .byte 4*18+77
                .byte 5*18+77

; 2737 cycles

draw_score      ldy #0
                sty saw_digit
                sty digit_index
@1              tya
                lsr
                tax
                lda score,x
                pha
                lsr
                lsr
                lsr
                lsr
                jsr @sub
                pla
                ldy digit_index
                and #$0F
                jsr @sub
                ldy digit_index
                cpy #6
                bne @1
                rts

@sub            bne @2
                bit saw_digit
                bmi @3
                cpy #5
                beq @3
                lda #10
                bne @3                  ; always
@2              dec saw_digit
@3              inc digit_index
                ldx digit_x,y
                ; fall through
;
; On entry:
;   A: digit
;   X: position
;
draw_digit      asl
                asl
                asl
                pha
                ldy mod7,x
                lda digit_masks,y
                sta mask
                sty temp
                pla
;               clc
                adc temp
                tay
                lda digits_lo,y
                sta data_ptr
                lda digits_hi,y
                sta data_ptr_h
                lda div7,x
                tax
                ldy #0

                lda scoreLine0+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine0+0,x
                iny
                lda (data_ptr),y
                sta scoreLine0+1,x
                iny
                lda (data_ptr),y
                sta scoreLine0+2,x
                iny

                lda scoreLine1+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine1+0,x
                iny
                lda (data_ptr),y
                sta scoreLine1+1,x
                iny
                lda (data_ptr),y
                sta scoreLine1+2,x
                iny

                lda scoreLine2+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine2+0,x
                iny
                lda (data_ptr),y
                sta scoreLine2+1,x
                iny
                lda (data_ptr),y
                sta scoreLine2+2,x
                iny

                lda scoreLine3+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine3+0,x
                iny
                lda (data_ptr),y
                sta scoreLine3+1,x
                iny
                lda (data_ptr),y
                sta scoreLine3+2,x
                iny

                lda scoreLine4+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine4+0,x
                iny
                lda (data_ptr),y
                sta scoreLine4+1,x
                iny
                lda (data_ptr),y
                sta scoreLine4+2,x
                iny

                lda scoreLine5+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine5+0,x
                iny
                lda (data_ptr),y
                sta scoreLine5+1,x
                iny
                lda (data_ptr),y
                sta scoreLine5+2,x
                iny

                lda scoreLine6+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine6+0,x
                iny
                lda (data_ptr),y
                sta scoreLine6+1,x
                iny
                lda (data_ptr),y
                sta scoreLine6+2,x
                iny

                lda scoreLine7+0,x
                and mask
                ora (data_ptr),y
                sta scoreLine7+0,x
                iny
                lda (data_ptr),y
                sta scoreLine7+1,x
                iny
                lda (data_ptr),y
                sta scoreLine7+2,x
                rts

digit_masks     .byte $80
                .byte $81
                .byte $83
                .byte $87
                .byte $8f
                .byte $9f
                .byte $bf

digits_lo       .byte <digits0_0
                .byte <digits0_1
                .byte <digits0_2
                .byte <digits0_3
                .byte <digits0_4
                .byte <digits0_5
                .byte <digits0_6
                .byte 0

                .byte <digits1_0
                .byte <digits1_1
                .byte <digits1_2
                .byte <digits1_3
                .byte <digits1_4
                .byte <digits1_5
                .byte <digits1_6
                .byte 0

                .byte <digits2_0
                .byte <digits2_1
                .byte <digits2_2
                .byte <digits2_3
                .byte <digits2_4
                .byte <digits2_5
                .byte <digits2_6
                .byte 0

                .byte <digits3_0
                .byte <digits3_1
                .byte <digits3_2
                .byte <digits3_3
                .byte <digits3_4
                .byte <digits3_5
                .byte <digits3_6
                .byte 0

                .byte <digits4_0
                .byte <digits4_1
                .byte <digits4_2
                .byte <digits4_3
                .byte <digits4_4
                .byte <digits4_5
                .byte <digits4_6
                .byte 0

                .byte <digits5_0
                .byte <digits5_1
                .byte <digits5_2
                .byte <digits5_3
                .byte <digits5_4
                .byte <digits5_5
                .byte <digits5_6
                .byte 0

                .byte <digits6_0
                .byte <digits6_1
                .byte <digits6_2
                .byte <digits6_3
                .byte <digits6_4
                .byte <digits6_5
                .byte <digits6_6
                .byte 0

                .byte <digits7_0
                .byte <digits7_1
                .byte <digits7_2
                .byte <digits7_3
                .byte <digits7_4
                .byte <digits7_5
                .byte <digits7_6
                .byte 0

                .byte <digits8_0
                .byte <digits8_1
                .byte <digits8_2
                .byte <digits8_3
                .byte <digits8_4
                .byte <digits8_5
                .byte <digits8_6
                .byte 0

                .byte <digits9_0
                .byte <digits9_1
                .byte <digits9_2
                .byte <digits9_3
                .byte <digits9_4
                .byte <digits9_5
                .byte <digits9_6
                .byte 0

                .byte <digitsX_0
                .byte <digitsX_1
                .byte <digitsX_2
                .byte <digitsX_3
                .byte <digitsX_4
                .byte <digitsX_5
                .byte <digitsX_6
;               .byte 0

digits_hi       .byte >digits0_0
                .byte >digits0_1
                .byte >digits0_2
                .byte >digits0_3
                .byte >digits0_4
                .byte >digits0_5
                .byte >digits0_6
                .byte 0

                .byte >digits1_0
                .byte >digits1_1
                .byte >digits1_2
                .byte >digits1_3
                .byte >digits1_4
                .byte >digits1_5
                .byte >digits1_6
                .byte 0

                .byte >digits2_0
                .byte >digits2_1
                .byte >digits2_2
                .byte >digits2_3
                .byte >digits2_4
                .byte >digits2_5
                .byte >digits2_6
                .byte 0

                .byte >digits3_0
                .byte >digits3_1
                .byte >digits3_2
                .byte >digits3_3
                .byte >digits3_4
                .byte >digits3_5
                .byte >digits3_6
                .byte 0

                .byte >digits4_0
                .byte >digits4_1
                .byte >digits4_2
                .byte >digits4_3
                .byte >digits4_4
                .byte >digits4_5
                .byte >digits4_6
                .byte 0

                .byte >digits5_0
                .byte >digits5_1
                .byte >digits5_2
                .byte >digits5_3
                .byte >digits5_4
                .byte >digits5_5
                .byte >digits5_6
                .byte 0

                .byte >digits6_0
                .byte >digits6_1
                .byte >digits6_2
                .byte >digits6_3
                .byte >digits6_4
                .byte >digits6_5
                .byte >digits6_6
                .byte 0

                .byte >digits7_0
                .byte >digits7_1
                .byte >digits7_2
                .byte >digits7_3
                .byte >digits7_4
                .byte >digits7_5
                .byte >digits7_6
                .byte 0

                .byte >digits8_0
                .byte >digits8_1
                .byte >digits8_2
                .byte >digits8_3
                .byte >digits8_4
                .byte >digits8_5
                .byte >digits8_6
                .byte 0

                .byte >digits9_0
                .byte >digits9_1
                .byte >digits9_2
                .byte >digits9_3
                .byte >digits9_4
                .byte >digits9_5
                .byte >digits9_6
                .byte 0

                .byte >digitsX_0
                .byte >digitsX_1
                .byte >digitsX_2
                .byte >digitsX_3
                .byte >digitsX_4
                .byte >digitsX_5
                .byte >digitsX_6
;               .byte 0

digits0_0       .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff

digits0_1       .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff

digits0_2       .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff

digits0_3       .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff

digits0_4       .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe

digits0_5       .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd

digits0_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits1_0       .byte $af,$fd,$ff
                .byte $ab,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $ab,$f5,$ff

digits1_1       .byte $de,$fa,$ff
                .byte $d6,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $d6,$ea,$ff

digits1_2       .byte $bc,$f5,$ff
                .byte $ac,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $ac,$d5,$ff

digits1_3       .byte $f8,$ea,$ff
                .byte $d8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $d8,$aa,$ff

digits1_4       .byte $f0,$d5,$ff
                .byte $b0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $b0,$d5,$fe

digits1_5       .byte $e0,$ab,$ff
                .byte $e0,$aa,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$aa,$fd

digits1_6       .byte $c0,$d7,$fe
                .byte $c0,$d5,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d5,$fa

digits2_0       .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ab,$f5,$ff
                .byte $ea,$ff,$ff
                .byte $ea,$ff,$ff
                .byte $aa,$d5,$ff

digits2_1       .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$ab,$ff
                .byte $d6,$ea,$ff
                .byte $d4,$ff,$ff
                .byte $d4,$ff,$ff
                .byte $d4,$aa,$ff

digits2_2       .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $fc,$d7,$fe
                .byte $fc,$d7,$fe
                .byte $ac,$d5,$ff
                .byte $a8,$ff,$ff
                .byte $a8,$ff,$ff
                .byte $a8,$d5,$fe

digits2_3       .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $f8,$af,$fd
                .byte $f8,$af,$fd
                .byte $d8,$aa,$ff
                .byte $d0,$fe,$ff
                .byte $d0,$fe,$ff
                .byte $d0,$aa,$fd

digits2_4       .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $f0,$df,$fa
                .byte $f0,$df,$fa
                .byte $b0,$d5,$fe
                .byte $a0,$fd,$ff
                .byte $a0,$fd,$ff
                .byte $a0,$d5,$fa

digits2_5       .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$aa,$fd
                .byte $c0,$fa,$ff
                .byte $c0,$fa,$ff
                .byte $c0,$aa,$f5

digits2_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$d5,$fa
                .byte $80,$f5,$ff
                .byte $80,$f5,$ff
                .byte $80,$d5,$ea

digits3_0       .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $bf,$d5,$ff
                .byte $bf,$f5,$ff
                .byte $ff,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff

digits3_1       .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$aa,$ff
                .byte $fe,$ea,$ff
                .byte $fe,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff

digits3_2       .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $fc,$d7,$fe
                .byte $fc,$d5,$fe
                .byte $fc,$d5,$ff
                .byte $fc,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff

digits3_3       .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $f8,$af,$fd
                .byte $f8,$ab,$fd
                .byte $f8,$ab,$ff
                .byte $f8,$af,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff

digits3_4       .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $f0,$df,$fa
                .byte $f0,$d7,$fa
                .byte $f0,$d7,$fe
                .byte $f0,$df,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe

digits3_5       .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$af,$f5
                .byte $e0,$af,$fd
                .byte $e0,$bf,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd

digits3_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$df,$ea
                .byte $c0,$df,$fa
                .byte $c0,$ff,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits4_0       .byte $bf,$d5,$ff
                .byte $af,$d5,$ff
                .byte $eb,$d5,$ff
                .byte $fa,$d5,$ff
                .byte $aa,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ff,$d5,$ff

digits4_1       .byte $fe,$aa,$ff
                .byte $de,$aa,$ff
                .byte $d6,$ab,$ff
                .byte $f4,$ab,$ff
                .byte $d4,$aa,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$ab,$ff

digits4_2       .byte $fc,$d5,$fe
                .byte $bc,$d5,$fe
                .byte $ac,$d7,$fe
                .byte $e8,$d7,$fe
                .byte $a8,$d5,$fe
                .byte $fc,$d7,$fe
                .byte $fc,$d7,$fe
                .byte $fc,$d7,$fe

digits4_3       .byte $f8,$ab,$fd
                .byte $f8,$aa,$fd
                .byte $d8,$ae,$fd
                .byte $d0,$af,$fd
                .byte $d0,$aa,$fd
                .byte $f8,$af,$fd
                .byte $f8,$af,$fd
                .byte $f8,$af,$fd

digits4_4       .byte $f0,$d7,$fa
                .byte $f0,$d5,$fa
                .byte $b0,$dd,$fa
                .byte $a0,$df,$fa
                .byte $a0,$d5,$fa
                .byte $f0,$df,$fa
                .byte $f0,$df,$fa
                .byte $f0,$df,$fa

digits4_5       .byte $e0,$af,$f5
                .byte $e0,$ab,$f5
                .byte $e0,$ba,$f5
                .byte $c0,$be,$f5
                .byte $c0,$aa,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$bf,$f5

digits4_6       .byte $c0,$df,$ea
                .byte $c0,$d7,$ea
                .byte $c0,$f5,$ea
                .byte $80,$fd,$ea
                .byte $80,$d5,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea

digits5_0       .byte $aa,$d5,$ff
                .byte $ea,$ff,$ff
                .byte $ea,$ff,$ff
                .byte $aa,$f5,$ff
                .byte $ff,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $aa,$f5,$ff

digits5_1       .byte $d4,$aa,$ff
                .byte $d4,$ff,$ff
                .byte $d4,$ff,$ff
                .byte $d4,$ea,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ea,$ff

digits5_2       .byte $a8,$d5,$fe
                .byte $a8,$ff,$ff
                .byte $a8,$ff,$ff
                .byte $a8,$d5,$ff
                .byte $fc,$d7,$fe
                .byte $fc,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d5,$ff

digits5_3       .byte $d0,$aa,$fd
                .byte $d0,$fe,$ff
                .byte $d0,$fe,$ff
                .byte $d0,$aa,$ff
                .byte $f8,$af,$fd
                .byte $f8,$af,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$aa,$ff

digits5_4       .byte $a0,$d5,$fa
                .byte $a0,$fd,$ff
                .byte $a0,$fd,$ff
                .byte $a0,$d5,$fe
                .byte $f0,$df,$fa
                .byte $f0,$df,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$d5,$fe

digits5_5       .byte $c0,$aa,$f5
                .byte $c0,$fa,$ff
                .byte $c0,$fa,$ff
                .byte $c0,$aa,$fd
                .byte $e0,$bf,$f5
                .byte $e0,$bf,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$aa,$fd

digits5_6       .byte $80,$d5,$ea
                .byte $80,$f5,$ff
                .byte $80,$f5,$ff
                .byte $80,$d5,$fa
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $80,$f5,$ea
                .byte $80,$d5,$fa

digits6_0       .byte $ab,$f5,$ff
                .byte $ea,$d7,$ff
                .byte $ea,$ff,$ff
                .byte $aa,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff

digits6_1       .byte $d6,$ea,$ff
                .byte $d4,$af,$ff
                .byte $d4,$ff,$ff
                .byte $d4,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff

digits6_2       .byte $ac,$d5,$ff
                .byte $a8,$df,$fe
                .byte $a8,$ff,$ff
                .byte $a8,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff

digits6_3       .byte $d8,$aa,$ff
                .byte $d0,$be,$fd
                .byte $d0,$fe,$ff
                .byte $d0,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff

digits6_4       .byte $b0,$d5,$fe
                .byte $a0,$fd,$fa
                .byte $a0,$fd,$ff
                .byte $a0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe

digits6_5       .byte $e0,$aa,$fd
                .byte $c0,$fa,$f5
                .byte $c0,$fa,$ff
                .byte $c0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd

digits6_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$eb
                .byte $80,$f5,$ff
                .byte $80,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits7_0       .byte $aa,$f5,$ff
                .byte $ea,$d7,$ff
                .byte $ff,$d5,$ff
                .byte $bf,$f5,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff
                .byte $af,$fd,$ff

digits7_1       .byte $d4,$ea,$ff
                .byte $d4,$af,$ff
                .byte $fe,$ab,$ff
                .byte $fe,$ea,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff
                .byte $de,$fa,$ff

digits7_2       .byte $a8,$d5,$ff
                .byte $a8,$df,$fe
                .byte $fc,$d7,$fe
                .byte $fc,$d5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff
                .byte $bc,$f5,$ff

digits7_3       .byte $d0,$aa,$ff
                .byte $d0,$be,$fd
                .byte $f8,$af,$fd
                .byte $f8,$ab,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff
                .byte $f8,$ea,$ff

digits7_4       .byte $a0,$d5,$fe
                .byte $a0,$fd,$fa
                .byte $f0,$df,$fa
                .byte $f0,$d7,$fe
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff
                .byte $f0,$d5,$ff

digits7_5       .byte $c0,$aa,$fd
                .byte $c0,$fa,$f5
                .byte $e0,$bf,$f5
                .byte $e0,$af,$fd
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff
                .byte $e0,$ab,$ff

digits7_6       .byte $80,$d5,$fa
                .byte $80,$f5,$eb
                .byte $c0,$ff,$ea
                .byte $c0,$df,$fa
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe

digits8_0       .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff
                .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff

digits8_1       .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff
                .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff

digits8_2       .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff
                .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff

digits8_3       .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff
                .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff

digits8_4       .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe
                .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe

digits8_5       .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd
                .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd

digits8_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa
                .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits9_0       .byte $ab,$f5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$d5,$ff
                .byte $ff,$d5,$ff
                .byte $ea,$d5,$ff
                .byte $ab,$f5,$ff

digits9_1       .byte $d6,$ea,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$aa,$ff
                .byte $fe,$ab,$ff
                .byte $d4,$ab,$ff
                .byte $d6,$ea,$ff

digits9_2       .byte $ac,$d5,$ff
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$fe
                .byte $fc,$d7,$fe
                .byte $a8,$d7,$fe
                .byte $ac,$d5,$ff

digits9_3       .byte $d8,$aa,$ff
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$fd
                .byte $f8,$af,$fd
                .byte $d0,$ae,$fd
                .byte $d8,$aa,$ff

digits9_4       .byte $b0,$d5,$fe
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fa
                .byte $f0,$df,$fa
                .byte $a0,$dd,$fa
                .byte $b0,$d5,$fe

digits9_5       .byte $e0,$aa,$fd
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$f5
                .byte $e0,$bf,$f5
                .byte $c0,$ba,$f5
                .byte $e0,$aa,$fd

digits9_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$ea
                .byte $c0,$ff,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digitsX_0       .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff
                .byte $ff,$ff,$ff

digitsX_1       .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff
                .byte $fe,$ff,$ff

digitsX_2       .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff
                .byte $fc,$ff,$ff

digitsX_3       .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff
                .byte $f8,$ff,$ff

digitsX_4       .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff
                .byte $f0,$ff,$ff

digitsX_5       .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff
                .byte $e0,$ff,$ff

digitsX_6       .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff


; digit_bits
;                 .byte %00111100
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %00111100		; zero

;                 .byte %00011000
;                 .byte %00111000
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00111100		; one

;                 .byte %00111100
;                 .byte %01000110
;                 .byte %00000110
;                 .byte %00000110
;                 .byte %00111100
;                 .byte %01100000
;                 .byte %01100000
;                 .byte %01111100		; two

;                 .byte %00111100
;                 .byte %01000110
;                 .byte %00000110
;                 .byte %00001100
;                 .byte %00001100
;                 .byte %00000110
;                 .byte %01000110
;                 .byte %00111100		; three

;                 .byte %00001100
;                 .byte %00011100
;                 .byte %00101100
;                 .byte %01001100
;                 .byte %01111100
;                 .byte %00001100
;                 .byte %00001100
;                 .byte %00001100		; four

;                 .byte %01111100
;                 .byte %01100000
;                 .byte %01100000
;                 .byte %01111100
;                 .byte %00000110
;                 .byte %00000110
;                 .byte %01000110
;                 .byte %01111100		; five

;                 .byte %00111100
;                 .byte %01100010
;                 .byte %01100000
;                 .byte %01111100
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %00111100		; six

;                 .byte %01111100
;                 .byte %01000010
;                 .byte %00000110
;                 .byte %00001100
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00011000
;                 .byte %00011000		; seven

;                 .byte %00111100
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %00111100
;                 .byte %00111100
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %00111100		; eight

;                 .byte %00111100
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %01100110
;                 .byte %00111110
;                 .byte %00000110
;                 .byte %01000110
;                 .byte %00111100		; nine


                ; .byte %........################........
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %........################........		; zero

                ; .byte %............########............
                ; .byte %........############............
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %........################........		; one

                ; .byte %........################........
                ; .byte %....####............########....
                ; .byte %....................########....
                ; .byte %....................########....
                ; .byte %........################........
                ; .byte %....########....................
                ; .byte %....########....................
                ; .byte %....####################........		; two

                ; .byte %........################........
                ; .byte %....####............########....
                ; .byte %....................########....
                ; .byte %................########........
                ; .byte %................########........
                ; .byte %....................########....
                ; .byte %....####............########....
                ; .byte %........################........		; three

                ; .byte %................########........
                ; .byte %............############........
                ; .byte %........####....########........
                ; .byte %....####........########........
                ; .byte %....####################........
                ; .byte %................########........
                ; .byte %................########........
                ; .byte %................########........		; four

                ; .byte %....####################........
                ; .byte %....########....................
                ; .byte %....########....................
                ; .byte %....####################........
                ; .byte %....................########....
                ; .byte %....................########....
                ; .byte %....####............########....
                ; .byte %....####################........		; five

                ; .byte %........################........
                ; .byte %....########............####....
                ; .byte %....########....................
                ; .byte %....####################........
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %........################........		; six

                ; .byte %....####################........
                ; .byte %....####................####....
                ; .byte %....................########....
                ; .byte %................########........
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %............########............
                ; .byte %............########............		; seven

                ; .byte %........################........
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %........################........
                ; .byte %........################........
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %........################........		; eight

                ; .byte %........################........
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %....########........########....
                ; .byte %........####################....
                ; .byte %....................########....
                ; .byte %....####............########....
                ; .byte %........################........		; nine
