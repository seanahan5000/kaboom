
;
; On entry:
;   A: X position (0-139) *** minus width?
;
;   draw at X * 2
;
move_buckets_left
                jsr get_buckets_x
                sty hold_col
                ; stx hold_shift

                jsr draw_buckets

                lda hold_col
                clc
                adc #bucketByteWidth
                cmp prev_start_col
                bcc @1
                sta prev_start_col
                cmp prev_end_col        ;***
                beq @2                  ;*** force erase instead
@1              jsr erase_bucket_cols
@2                                      ;***
                lda hold_col
                sta prev_start_col
                clc
                adc #bucketByteWidth
                sta prev_end_col
                rts

move_buckets_right
                jsr get_buckets_x
                sty hold_col
                stx hold_shift

                cpy prev_end_col
                bcs @1
                sty prev_end_col
                cpy prev_start_col      ;***
                beq @2                  ;*** force erase instead
@1              jsr erase_bucket_cols
@2                                      ;***
                ldy hold_col
                ldx hold_shift

                sty prev_start_col
                tya
                clc
                adc #6
                sta prev_end_col

                ; fall through

draw_buckets    txa
                asl a
                asl a
;               clc
                adc bucket_count
                tax
                lda draw_buckets_lo,x
                sta @mod+1
                lda draw_buckets_hi,x
                sta @mod+2
                tya
                clc
                adc #bucketByteWidth
                                        ;*** clip right edge?
                                        ;*** or assume clamping?
@mod            jmp $ffff

;
; On entry:
;   A: X position (0-139)   *** capped ***
;
;   draw at X * 2
;
; On exit:
;   X: position mod 7
;   Y: position div 7
;
get_buckets_x   asl a
                tax
                ldy div7,x
                lda mod7,x
                tax
                rts

draw_buckets_lo .byte 0
                .byte <draw_buckets1_0
                .byte <draw_buckets2_0
                .byte <draw_buckets3_0
                .byte 0
                .byte <draw_buckets1_1
                .byte <draw_buckets2_1
                .byte <draw_buckets3_1
                .byte 0
                .byte <draw_buckets1_2
                .byte <draw_buckets2_2
                .byte <draw_buckets3_2
                .byte 0
                .byte <draw_buckets1_3
                .byte <draw_buckets2_3
                .byte <draw_buckets3_3
                .byte 0
                .byte <draw_buckets1_4
                .byte <draw_buckets2_4
                .byte <draw_buckets3_4
                .byte 0
                .byte <draw_buckets1_5
                .byte <draw_buckets2_5
                .byte <draw_buckets3_5
                .byte 0
                .byte <draw_buckets1_6
                .byte <draw_buckets2_6
                .byte <draw_buckets3_6

draw_buckets_hi .byte 0
                .byte >draw_buckets1_0
                .byte >draw_buckets2_0
                .byte >draw_buckets3_0
                .byte 0
                .byte >draw_buckets1_1
                .byte >draw_buckets2_1
                .byte >draw_buckets3_1
                .byte 0
                .byte >draw_buckets1_2
                .byte >draw_buckets2_2
                .byte >draw_buckets3_2
                .byte 0
                .byte >draw_buckets1_3
                .byte >draw_buckets2_3
                .byte >draw_buckets3_3
                .byte 0
                .byte >draw_buckets1_4
                .byte >draw_buckets2_4
                .byte >draw_buckets3_4
                .byte 0
                .byte >draw_buckets1_5
                .byte >draw_buckets2_5
                .byte >draw_buckets3_5
                .byte 0
                .byte >draw_buckets1_6
                .byte >draw_buckets2_6
                .byte >draw_buckets3_6

splash0_line0   =   $2050               ;128
splash0_line1   =   $2450
splash0_line2   =   $2850
splash0_line3   =   $2C50
splash0_line4   =   $3050
splash0_line5   =   $3450
splash0_line6   =   $3850
splash0_line7   =   $3C50

bucket0_line0   =   $20D0               ;136
bucket0_line1   =   $24D0
bucket0_line2   =   $28D0
bucket0_line3   =   $2CD0
bucket0_line4   =   $30D0
bucket0_line5   =   $34D0
bucket0_line6   =   $38D0
bucket0_line7   =   $3CD0

splash1_line0   =   $2150               ;144
splash1_line1   =   $2550
splash1_line2   =   $2950
splash1_line3   =   $2D50
splash1_line4   =   $3150
splash1_line5   =   $3550
splash1_line6   =   $3950
splash1_line7   =   $3D50

bucket1_line0   =   $21D0               ;152
bucket1_line1   =   $25D0
bucket1_line2   =   $29D0
bucket1_line3   =   $2DD0
bucket1_line4   =   $31D0
bucket1_line5   =   $35D0
bucket1_line6   =   $39D0
bucket1_line7   =   $3DD0

splash2_line0   =   $2250               ;160
splash2_line1   =   $2650
splash2_line2   =   $2A50
splash2_line3   =   $2E50
splash2_line4   =   $3250
splash2_line5   =   $3650
splash2_line6   =   $3A50
splash2_line7   =   $3E50

bucket2_line0   =   $22D0               ;168
bucket2_line1   =   $26D0
bucket2_line2   =   $2AD0
bucket2_line3   =   $2ED0
bucket2_line4   =   $32D0
bucket2_line5   =   $36D0
bucket2_line6   =   $3AD0
bucket2_line7   =   $3ED0

.macro buckets3 bits
                sta @mod+1
                ldx #0
@1              lda bits,x
                sta bucket0_line0,y     ;136
                sta bucket1_line0,y     ;152
                sta bucket2_line0,y     ;168
                inx
                lda bits,x
                sta bucket0_line1,y
                sta bucket1_line1,y
                sta bucket2_line1,y
                inx
                lda bits,x
                sta bucket0_line2,y
                sta bucket1_line2,y
                sta bucket2_line2,y
                inx
                lda bits,x
                sta bucket0_line3,y
                sta bucket1_line3,y
                sta bucket2_line3,y
                inx
                lda bits,x
                sta bucket0_line4,y
                sta bucket1_line4,y
                sta bucket2_line4,y
                inx
                lda bits,x
                sta bucket0_line5,y
                sta bucket1_line5,y
                sta bucket2_line5,y
                inx
                lda bits,x
                sta bucket0_line6,y
                sta bucket1_line6,y
                sta bucket2_line6,y
                inx
                lda bits,x
                sta bucket0_line7,y     ;143
                sta bucket1_line7,y     ;159
                sta bucket2_line7,y     ;175
                inx
                iny
@mod            cpy #$ff
                bne @1
                rts
.endmacro

; repeat writes here and in buckets1 so that timing doesn't
;   change based on the number of buckets
.macro buckets2 bits
                sta @mod+1
                ldx #0
@1              lda bits,x
                sta bucket1_line0,y     ;152
                sta bucket2_line0,y     ;168
                sta bucket2_line0,y     ;168
                inx
                lda bits,x
                sta bucket1_line1,y
                sta bucket2_line1,y
                sta bucket2_line1,y
                inx
                lda bits,x
                sta bucket1_line2,y
                sta bucket2_line2,y
                sta bucket2_line2,y
                inx
                lda bits,x
                sta bucket1_line3,y
                sta bucket2_line3,y
                sta bucket2_line3,y
                inx
                lda bits,x
                sta bucket1_line4,y
                sta bucket2_line4,y
                sta bucket2_line4,y
                inx
                lda bits,x
                sta bucket1_line5,y
                sta bucket2_line5,y
                sta bucket2_line5,y
                inx
                lda bits,x
                sta bucket1_line6,y
                sta bucket2_line6,y
                sta bucket2_line6,y
                inx
                lda bits,x
                sta bucket1_line7,y     ;159
                sta bucket2_line7,y     ;175
                sta bucket2_line7,y     ;175
                inx
                iny
@mod            cpy #$ff
                bne @1
                rts
.endmacro

; repeat writes here and in buckets2 so that timing doesn't
;   change based on the number of buckets
.macro buckets1 bits
                sta @mod+1
                ldx #0
@1              lda bits,x
                sta bucket2_line0,y     ;168
                sta bucket2_line0,y     ;168
                sta bucket2_line0,y     ;168
                inx
                lda bits,x
                sta bucket2_line1,y
                sta bucket2_line1,y
                sta bucket2_line1,y
                inx
                lda bits,x
                sta bucket2_line2,y
                sta bucket2_line2,y
                sta bucket2_line2,y
                inx
                lda bits,x
                sta bucket2_line3,y
                sta bucket2_line3,y
                sta bucket2_line3,y
                inx
                lda bits,x
                sta bucket2_line4,y
                sta bucket2_line4,y
                sta bucket2_line4,y
                inx
                lda bits,x
                sta bucket2_line5,y
                sta bucket2_line5,y
                sta bucket2_line5,y
                inx
                lda bits,x
                sta bucket2_line6,y
                sta bucket2_line6,y
                sta bucket2_line6,y
                inx
                lda bits,x
                sta bucket2_line7,y     ;175
                sta bucket2_line7,y     ;175
                sta bucket2_line7,y     ;175
                inx
                iny
@mod            cpy #$ff
                bne @1
                rts
.endmacro


; ***
; ~900 cycles (+ erase columns)
; DX max of 160, 80, 40, 20, 10, 5, 2, 1 (of 160)
; (subtract out width of buckets?)
; ***
; splashes are extra

draw_buckets3_0 buckets3 bucket_0
draw_buckets3_1 buckets3 bucket_1
draw_buckets3_2 buckets3 bucket_2
draw_buckets3_3 buckets3 bucket_3
draw_buckets3_4 buckets3 bucket_4
draw_buckets3_5 buckets3 bucket_5
draw_buckets3_6 buckets3 bucket_6

draw_buckets2_0 buckets2 bucket_0
draw_buckets2_1 buckets2 bucket_1
draw_buckets2_2 buckets2 bucket_2
draw_buckets2_3 buckets2 bucket_3
draw_buckets2_4 buckets2 bucket_4
draw_buckets2_5 buckets2 bucket_5
draw_buckets2_6 buckets2 bucket_6

draw_buckets1_0 buckets1 bucket_0
draw_buckets1_1 buckets1 bucket_1
draw_buckets1_2 buckets1 bucket_2
draw_buckets1_3 buckets1 bucket_3
draw_buckets1_4 buckets1 bucket_4
draw_buckets1_5 buckets1 bucket_5
draw_buckets1_6 buckets1 bucket_6

; *** may need to clip these if overlapping new buckets ***
; always write the same number of bytes, even with overlap
erase_bucket_cols
                ldy prev_start_col
                ldx #6
                tya
                lsr a
                lda #$2a
                bcc @2
                lda #$55
                bcs @2                  ; always
@1              eor #$7f
@2              sta bucket0_line0,y     ;136
                sta bucket1_line0,y     ;152
                sta bucket2_line0,y     ;168
                sta bucket0_line1,y
                sta bucket1_line1,y
                sta bucket2_line1,y
                sta bucket0_line2,y
                sta bucket1_line2,y
                sta bucket2_line2,y
                sta bucket0_line3,y
                sta bucket1_line3,y
                sta bucket2_line3,y
                sta bucket0_line4,y
                sta bucket1_line4,y
                sta bucket2_line4,y
                sta bucket0_line5,y
                sta bucket1_line5,y
                sta bucket2_line5,y
                sta bucket0_line6,y
                sta bucket1_line6,y
                sta bucket2_line6,y
                sta bucket0_line7,y     ;143
                sta bucket1_line7,y     ;159
                sta bucket2_line7,y     ;175
                dex
                beq @3
                iny
                cpy prev_end_col
                bcc @1
                dey
                bcs @2                  ; always
                ; *** check for page cross ***
@3              rts

                .align 256

bucket_0        .byte $56,$2a,$25,$25,$25,$25,$25,$55
                .byte $2a,$55,$29,$29,$29,$29,$29,$2a
                .byte $55,$2a,$4a,$4a,$4a,$4a,$4a,$55
                .byte $2a,$55,$52,$52,$52,$52,$52,$2a
                .byte $2d,$2a,$34,$34,$34,$34,$34,$35
                .byte $55,$55,$55,$55,$55,$55,$55,$55

bucket_1        .byte $2d,$55,$4b,$4b,$4b,$4b,$4b,$2b
                .byte $55,$2a,$52,$52,$52,$52,$52,$55
                .byte $2a,$55,$14,$14,$14,$14,$14,$2a
                .byte $55,$2a,$25,$25,$25,$25,$25,$55
                .byte $5a,$55,$69,$69,$69,$69,$69,$6a
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

bucket_2        .byte $5a,$2a,$16,$16,$16,$16,$16,$56
                .byte $2a,$55,$25,$25,$25,$25,$25,$2a
                .byte $55,$2a,$29,$29,$29,$29,$29,$55
                .byte $2a,$55,$4a,$4a,$4a,$4a,$4a,$2a
                .byte $35,$2a,$52,$52,$52,$52,$52,$55
                .byte $55,$55,$55,$55,$55,$55,$55,$55

bucket_3        .byte $35,$55,$2d,$2d,$2d,$2d,$2d,$2d
                .byte $55,$2a,$4a,$4a,$4a,$4a,$4a,$55
                .byte $2a,$55,$52,$52,$52,$52,$52,$2a
                .byte $55,$2a,$14,$14,$14,$14,$14,$55
                .byte $6a,$55,$25,$25,$25,$25,$25,$2a
                .byte $2a,$2a,$2b,$2b,$2b,$2b,$2b,$2b

bucket_4        .byte $6a,$2a,$5a,$5a,$5a,$5a,$5a,$5a
                .byte $2a,$55,$14,$14,$14,$14,$14,$2a
                .byte $55,$2a,$25,$25,$25,$25,$25,$55
                .byte $2a,$55,$29,$29,$29,$29,$29,$2a
                .byte $55,$2a,$4a,$4a,$4a,$4a,$4a,$55
                .byte $55,$55,$56,$56,$56,$56,$56,$56

                .align 256

bucket_5        .byte $55,$55,$35,$35,$35,$35,$35,$35
                .byte $55,$2a,$29,$29,$29,$29,$29,$55
                .byte $2a,$55,$4a,$4a,$4a,$4a,$4a,$2a
                .byte $55,$2a,$52,$52,$52,$52,$52,$55
                .byte $2a,$55,$14,$14,$14,$14,$14,$2a
                .byte $2b,$2a,$2d,$2d,$2d,$2d,$2d,$2d

bucket_6        .byte $2a,$2a,$6a,$6a,$6a,$6a,$6a,$6a
                .byte $2b,$55,$52,$52,$52,$52,$52,$2a
                .byte $55,$2a,$14,$14,$14,$14,$14,$55
                .byte $2a,$55,$25,$25,$25,$25,$25,$2a
                .byte $55,$2a,$29,$29,$29,$29,$29,$55
                .byte $56,$55,$5a,$5a,$5a,$5a,$5a,$5a


splash_bits
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000		; no splash

                .byte %00000000
                .byte %00000000
                .byte %00101000
                .byte %10000010
                .byte %00010000
                .byte %00111000
                .byte %00000000
                .byte %10010010		; splash 1

                .byte %00000000
                .byte %01000100
                .byte %00000000
                .byte %00010000
                .byte %10010010
                .byte %01000100
                .byte %00010000
                .byte %00010000		; splash 2

                .byte %00000000
                .byte %00000000
                .byte %10000010
                .byte %00010000
                .byte %00000000
                .byte %00010000
                .byte %10010010
                .byte %00000000		; splash 3


                ; .byte %................................
                ; .byte %................................
                ; .byte %........####....####............
                ; .byte %####....................####....
                ; .byte %............####................
                ; .byte %........############............
                ; .byte %................................
                ; .byte %####........####........####....		; splash 1

                ; .byte %................................
                ; .byte %....####............####........
                ; .byte %................................
                ; .byte %............####................
                ; .byte %####........####........####....
                ; .byte %....####............####........
                ; .byte %............####................
                ; .byte %............####................		; splash 2

                ; .byte %................................
                ; .byte %................................
                ; .byte %####....................####....
                ; .byte %............####................
                ; .byte %................................
                ; .byte %............####................
                ; .byte %####........####........####....
                ; .byte %................................		; splash 3

                ; .byte %....####################........
                ; .byte %....################............
                ; .byte %####....####....####....####....
                ; .byte %####....####....####....####....
                ; .byte %####....####....####....####....
                ; .byte %####....####....####....####....
                ; .byte %####....####....####....####....
                ; .byte %############################....
