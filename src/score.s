
scoreLine0      =   hiresLine1
scoreLine1      =   hiresLine2
scoreLine2      =   hiresLine3
scoreLine3      =   hiresLine4
scoreLine4      =   hiresLine5
scoreLine5      =   hiresLine6
scoreLine6      =   hiresLine7
scoreLine7      =   hiresLine8

digit_x         .byte 0*18+scoreLeft
                .byte 1*18+scoreLeft
                .byte 2*18+scoreLeft
                .byte 3*18+scoreLeft
                .byte 4*18+scoreLeft
                .byte 5*18+scoreLeft

draw_score
; expand score into new_digits buffer
                ldx #0
                ldy #0
@1              lda player_score,y
                iny
                pha
                lsr
                lsr
                lsr
                lsr
                sta new_digits,x
                inx
                pla
                and #$0f
                sta new_digits,x
                inx
                cpx #6
                bne @1

; clear leading zeroes
                ldx #0
                lda #$0a
@2              ldy new_digits,x
                bne @3
                sta new_digits,x
                inx
                cpx #5
                bne @2
@3
; draw first changed digit, but always draw something
                ldx #$ff
@4              inx
                lda new_digits,x
                cmp cur_digits,x
                bne @5
                cpx #5
                bne @4

@5              sta cur_digits,x
                asl
                asl
                asl                     ; clc
                sta temp                ; temp = digit * 8
                ldy digit_x,x           ; y = actual x coordinate
                lda player_num
                beq @6
                iny                     ; shift right 1 pixel for player 2
@6              ldx mod7,y              ; x = shift
                lda digit_lmasks,x
                sta lmask
                lda digit_rmasks,x
                sta rmask
                txa
;               clc
                adc temp                ; shift + digit * 8
                tax
                lda digits_lo,x
                sta data_ptr
                lda digits_hi,x
                sta data_ptr_h
                ldx div7,y              ; x = column
                ldy #0

                lda scoreLine0+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine0+0,x
                iny
                lda (data_ptr),y
                sta scoreLine0+1,x
                iny
                lda scoreLine0+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine0+2,x
                iny

                lda scoreLine1+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine1+0,x
                iny
                lda (data_ptr),y
                sta scoreLine1+1,x
                iny
                lda scoreLine1+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine1+2,x
                iny

                lda scoreLine2+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine2+0,x
                iny
                lda (data_ptr),y
                sta scoreLine2+1,x
                iny
                lda scoreLine2+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine2+2,x
                iny

                lda scoreLine3+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine3+0,x
                iny
                lda (data_ptr),y
                sta scoreLine3+1,x
                iny
                lda scoreLine3+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine3+2,x
                iny

                lda scoreLine4+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine4+0,x
                iny
                lda (data_ptr),y
                sta scoreLine4+1,x
                iny
                lda scoreLine4+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine4+2,x
                iny

                lda scoreLine5+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine5+0,x
                iny
                lda (data_ptr),y
                sta scoreLine5+1,x
                iny
                lda scoreLine5+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine5+2,x
                iny

                lda scoreLine6+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine6+0,x
                iny
                lda (data_ptr),y
                sta scoreLine6+1,x
                iny
                lda scoreLine6+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine6+2,x
                iny

                lda scoreLine7+0,x
                and lmask
                ora (data_ptr),y
                sta scoreLine7+0,x
                iny
                lda (data_ptr),y
                sta scoreLine7+1,x
                iny
                lda scoreLine7+2,x
                and rmask
                ora (data_ptr),y
                sta scoreLine7+2,x
                rts

digit_lmasks    .byte %00000000
                .byte %00000001
                .byte %00000011
                .byte %00000111
                .byte %00001111
                .byte %00011111
                .byte %00111111

digit_rmasks    .byte %01111110
                .byte %01111100
                .byte %01111000
                .byte %01110000
                .byte %01100000
                .byte %01000000
                .byte %00000000

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

digits0_0       .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81

digits0_1       .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83

digits0_2       .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87

digits0_3       .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f

digits0_4       .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e

digits0_5       .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd

digits0_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits1_0       .byte $af,$fd,$81
                .byte $ab,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $ab,$f5,$81

digits1_1       .byte $de,$fa,$83
                .byte $d6,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $d6,$ea,$83

digits1_2       .byte $bc,$f5,$87
                .byte $ac,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $ac,$d5,$87

digits1_3       .byte $f8,$ea,$8f
                .byte $d8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $d8,$aa,$8f

digits1_4       .byte $f0,$d5,$9f
                .byte $b0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $b0,$d5,$9e

digits1_5       .byte $e0,$ab,$bf
                .byte $e0,$aa,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$aa,$bd

digits1_6       .byte $c0,$d7,$fe
                .byte $c0,$d5,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d5,$fa

digits2_0       .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ff,$d5,$81
                .byte $ff,$d5,$81
                .byte $ab,$f5,$81
                .byte $ea,$ff,$81
                .byte $ea,$ff,$81
                .byte $aa,$d5,$81

digits2_1       .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $fe,$ab,$83
                .byte $fe,$ab,$83
                .byte $d6,$ea,$83
                .byte $d4,$ff,$83
                .byte $d4,$ff,$83
                .byte $d4,$aa,$83

digits2_2       .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $fc,$d7,$86
                .byte $fc,$d7,$86
                .byte $ac,$d5,$87
                .byte $a8,$ff,$87
                .byte $a8,$ff,$87
                .byte $a8,$d5,$86

digits2_3       .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $f8,$af,$8d
                .byte $f8,$af,$8d
                .byte $d8,$aa,$8f
                .byte $d0,$fe,$8f
                .byte $d0,$fe,$8f
                .byte $d0,$aa,$8d

digits2_4       .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $f0,$df,$9a
                .byte $f0,$df,$9a
                .byte $b0,$d5,$9e
                .byte $a0,$fd,$9f
                .byte $a0,$fd,$9f
                .byte $a0,$d5,$9a

digits2_5       .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $e0,$bf,$b5
                .byte $e0,$bf,$b5
                .byte $e0,$aa,$bd
                .byte $c0,$fa,$bf
                .byte $c0,$fa,$bf
                .byte $c0,$aa,$b5

digits2_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$d5,$fa
                .byte $80,$f5,$ff
                .byte $80,$f5,$ff
                .byte $80,$d5,$ea

digits3_0       .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ff,$d5,$81
                .byte $bf,$d5,$81
                .byte $bf,$f5,$81
                .byte $ff,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81

digits3_1       .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $fe,$ab,$83
                .byte $fe,$aa,$83
                .byte $fe,$ea,$83
                .byte $fe,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83

digits3_2       .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $fc,$d7,$86
                .byte $fc,$d5,$86
                .byte $fc,$d5,$87
                .byte $fc,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87

digits3_3       .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $f8,$af,$8d
                .byte $f8,$ab,$8d
                .byte $f8,$ab,$8f
                .byte $f8,$af,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f

digits3_4       .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $f0,$df,$9a
                .byte $f0,$d7,$9a
                .byte $f0,$d7,$9e
                .byte $f0,$df,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e

digits3_5       .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $e0,$bf,$b5
                .byte $e0,$af,$b5
                .byte $e0,$af,$bd
                .byte $e0,$bf,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd

digits3_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$df,$ea
                .byte $c0,$df,$fa
                .byte $c0,$ff,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits4_0       .byte $bf,$d5,$81
                .byte $af,$d5,$81
                .byte $eb,$d5,$81
                .byte $fa,$d5,$81
                .byte $aa,$d5,$80
                .byte $ff,$d5,$81
                .byte $ff,$d5,$81
                .byte $ff,$d5,$81

digits4_1       .byte $fe,$aa,$83
                .byte $de,$aa,$83
                .byte $d6,$ab,$83
                .byte $f4,$ab,$83
                .byte $d4,$aa,$81
                .byte $fe,$ab,$83
                .byte $fe,$ab,$83
                .byte $fe,$ab,$83

digits4_2       .byte $fc,$d5,$86
                .byte $bc,$d5,$86
                .byte $ac,$d7,$86
                .byte $e8,$d7,$86
                .byte $a8,$d5,$82
                .byte $fc,$d7,$86
                .byte $fc,$d7,$86
                .byte $fc,$d7,$86

digits4_3       .byte $f8,$ab,$8d
                .byte $f8,$aa,$8d
                .byte $d8,$ae,$8d
                .byte $d0,$af,$8d
                .byte $d0,$aa,$85
                .byte $f8,$af,$8d
                .byte $f8,$af,$8d
                .byte $f8,$af,$8d

digits4_4       .byte $f0,$d7,$9a
                .byte $f0,$d5,$9a
                .byte $b0,$dd,$9a
                .byte $a0,$df,$9a
                .byte $a0,$d5,$8a
                .byte $f0,$df,$9a
                .byte $f0,$df,$9a
                .byte $f0,$df,$9a

digits4_5       .byte $e0,$af,$b5
                .byte $e0,$ab,$b5
                .byte $e0,$ba,$b5
                .byte $c0,$be,$b5
                .byte $c0,$aa,$95
                .byte $e0,$bf,$b5
                .byte $e0,$bf,$b5
                .byte $e0,$bf,$b5

digits4_6       .byte $c0,$df,$ea
                .byte $c0,$d7,$ea
                .byte $c0,$f5,$ea
                .byte $80,$fd,$ea
                .byte $80,$d5,$aa
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea

digits5_0       .byte $aa,$d5,$81
                .byte $ea,$ff,$81
                .byte $ea,$ff,$81
                .byte $aa,$f5,$81
                .byte $ff,$d5,$81
                .byte $ff,$d5,$81
                .byte $fa,$d5,$81
                .byte $aa,$f5,$81

digits5_1       .byte $d4,$aa,$83
                .byte $d4,$ff,$83
                .byte $d4,$ff,$83
                .byte $d4,$ea,$83
                .byte $fe,$ab,$83
                .byte $fe,$ab,$83
                .byte $f4,$ab,$83
                .byte $d4,$ea,$83

digits5_2       .byte $a8,$d5,$86
                .byte $a8,$ff,$87
                .byte $a8,$ff,$87
                .byte $a8,$d5,$87
                .byte $fc,$d7,$86
                .byte $fc,$d7,$86
                .byte $e8,$d7,$86
                .byte $a8,$d5,$87

digits5_3       .byte $d0,$aa,$8d
                .byte $d0,$fe,$8f
                .byte $d0,$fe,$8f
                .byte $d0,$aa,$8f
                .byte $f8,$af,$8d
                .byte $f8,$af,$8d
                .byte $d0,$af,$8d
                .byte $d0,$aa,$8f

digits5_4       .byte $a0,$d5,$9a
                .byte $a0,$fd,$9f
                .byte $a0,$fd,$9f
                .byte $a0,$d5,$9e
                .byte $f0,$df,$9a
                .byte $f0,$df,$9a
                .byte $a0,$df,$9a
                .byte $a0,$d5,$9e

digits5_5       .byte $c0,$aa,$b5
                .byte $c0,$fa,$bf
                .byte $c0,$fa,$bf
                .byte $c0,$aa,$bd
                .byte $e0,$bf,$b5
                .byte $e0,$bf,$b5
                .byte $c0,$be,$b5
                .byte $c0,$aa,$bd

digits5_6       .byte $80,$d5,$ea
                .byte $80,$f5,$ff
                .byte $80,$f5,$ff
                .byte $80,$d5,$fa
                .byte $c0,$ff,$ea
                .byte $c0,$ff,$ea
                .byte $80,$fd,$ea
                .byte $80,$d5,$fa

digits6_0       .byte $ab,$f5,$81
                .byte $ea,$d7,$81
                .byte $ea,$ff,$81
                .byte $aa,$f5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81

digits6_1       .byte $d6,$ea,$83
                .byte $d4,$af,$83
                .byte $d4,$ff,$83
                .byte $d4,$ea,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83

digits6_2       .byte $ac,$d5,$87
                .byte $a8,$df,$86
                .byte $a8,$ff,$87
                .byte $a8,$d5,$87
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87

digits6_3       .byte $d8,$aa,$8f
                .byte $d0,$be,$8d
                .byte $d0,$fe,$8f
                .byte $d0,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f

digits6_4       .byte $b0,$d5,$9e
                .byte $a0,$fd,$9a
                .byte $a0,$fd,$9f
                .byte $a0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e

digits6_5       .byte $e0,$aa,$bd
                .byte $c0,$fa,$b5
                .byte $c0,$fa,$bf
                .byte $c0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd

digits6_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$eb
                .byte $80,$f5,$ff
                .byte $80,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits7_0       .byte $aa,$d5,$81
                .byte $fa,$d7,$81
                .byte $ff,$d5,$81
                .byte $bf,$f5,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81
                .byte $af,$fd,$81

digits7_1       .byte $d4,$aa,$83
                .byte $f4,$af,$83
                .byte $fe,$ab,$83
                .byte $fe,$ea,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83
                .byte $de,$fa,$83

digits7_2       .byte $a8,$d5,$86
                .byte $e8,$df,$86
                .byte $fc,$d7,$86
                .byte $fc,$d5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87
                .byte $bc,$f5,$87

digits7_3       .byte $d0,$aa,$8d
                .byte $d0,$bf,$8d
                .byte $f8,$af,$8d
                .byte $f8,$ab,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f
                .byte $f8,$ea,$8f

digits7_4       .byte $a0,$d5,$9a
                .byte $a0,$ff,$9a
                .byte $f0,$df,$9a
                .byte $f0,$d7,$9e
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f
                .byte $f0,$d5,$9f

digits7_5       .byte $c0,$aa,$b5
                .byte $c0,$fe,$b5
                .byte $e0,$bf,$b5
                .byte $e0,$af,$bd
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf
                .byte $e0,$ab,$bf

digits7_6       .byte $80,$d5,$ea
                .byte $80,$fd,$eb
                .byte $c0,$ff,$ea
                .byte $c0,$df,$fa
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe
                .byte $c0,$d7,$fe

digits8_0       .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81
                .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81

digits8_1       .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83
                .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83

digits8_2       .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87
                .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87

digits8_3       .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f
                .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f

digits8_4       .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e
                .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e

digits8_5       .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd
                .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd

digits8_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa
                .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digits9_0       .byte $ab,$f5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$d5,$81
                .byte $ff,$d5,$81
                .byte $ea,$d5,$81
                .byte $ab,$f5,$81

digits9_1       .byte $d6,$ea,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$aa,$83
                .byte $fe,$ab,$83
                .byte $d4,$ab,$83
                .byte $d6,$ea,$83

digits9_2       .byte $ac,$d5,$87
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$86
                .byte $fc,$d7,$86
                .byte $a8,$d7,$86
                .byte $ac,$d5,$87

digits9_3       .byte $d8,$aa,$8f
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8d
                .byte $f8,$af,$8d
                .byte $d0,$ae,$8d
                .byte $d8,$aa,$8f

digits9_4       .byte $b0,$d5,$9e
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9a
                .byte $f0,$df,$9a
                .byte $a0,$dd,$9a
                .byte $b0,$d5,$9e

digits9_5       .byte $e0,$aa,$bd
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$b5
                .byte $e0,$bf,$b5
                .byte $c0,$ba,$b5
                .byte $e0,$aa,$bd

digits9_6       .byte $c0,$d5,$fa
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$ea
                .byte $c0,$ff,$ea
                .byte $80,$f5,$ea
                .byte $c0,$d5,$fa

digitsX_0       .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81
                .byte $ff,$ff,$81

digitsX_1       .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83
                .byte $fe,$ff,$83

digitsX_2       .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87
                .byte $fc,$ff,$87

digitsX_3       .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f
                .byte $f8,$ff,$8f

digitsX_4       .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f
                .byte $f0,$ff,$9f

digitsX_5       .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf
                .byte $e0,$ff,$bf

digitsX_6       .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff
                .byte $c0,$ff,$ff

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
                ; .byte %....########################....		; two

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
                ; .byte %....########################....
                ; .byte %................########........
                ; .byte %................########........
                ; .byte %................########........		; four

                ; .byte %....########################....
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

                ; .byte %....########################....
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
