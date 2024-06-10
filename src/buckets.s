; **** use T,M,B ? ***

splash0_line0   =   hiresLine133
splash0_line1   =   hiresLine134
splash0_line2   =   hiresLine135
splash0_line3   =   hiresLine136
splash0_line4   =   hiresLine137
splash0_line5   =   hiresLine138
splash0_line6   =   hiresLine139
splash0_line7   =   hiresLine140

bucket0_line0   =   hiresLine141
bucket0_line1   =   hiresLine142
bucket0_line2   =   hiresLine143
bucket0_line3   =   hiresLine144
bucket0_line4   =   hiresLine145
bucket0_line5   =   hiresLine146
bucket0_line6   =   hiresLine147
bucket0_line7   =   hiresLine148

splash1_line0   =   hiresLine149
splash1_line1   =   hiresLine150
splash1_line2   =   hiresLine151
splash1_line3   =   hiresLine152
splash1_line4   =   hiresLine153
splash1_line5   =   hiresLine154
splash1_line6   =   hiresLine155
splash1_line7   =   hiresLine156

bucket1_line0   =   hiresLine157
bucket1_line1   =   hiresLine158
bucket1_line2   =   hiresLine159
bucket1_line3   =   hiresLine160
bucket1_line4   =   hiresLine161
bucket1_line5   =   hiresLine162
bucket1_line6   =   hiresLine163
bucket1_line7   =   hiresLine164

splash2_line0   =   hiresLine165
splash2_line1   =   hiresLine166
splash2_line2   =   hiresLine167
splash2_line3   =   hiresLine168
splash2_line4   =   hiresLine169
splash2_line5   =   hiresLine170
splash2_line6   =   hiresLine171
splash2_line7   =   hiresLine172

bucket2_line0   =   hiresLine173
bucket2_line1   =   hiresLine174
bucket2_line2   =   hiresLine175
bucket2_line3   =   hiresLine176
bucket2_line4   =   hiresLine177
bucket2_line5   =   hiresLine178
bucket2_line6   =   hiresLine179
bucket2_line7   =   hiresLine180

;
; On entry:
;   bucket_xcol and bucket_xshift setup based on buckets_x * 2
;
draw_buckets
                ;*** tie this to wave/speed? ***
                ;*** force bucket 1 if no splash
                ldx splash_frame
                beq @1
                dex
@1              stx splash_frame
                txa
                lsr
                lsr
                sta temp                ;***

                lda splash_bucket
                asl
                asl
;               clc
                ; adc splash_frame  ***
                adc temp                ;***
                asl
                asl
                asl
;               clc
                adc bucket_xshift
                tay
                lda splash_procs_lo,y
                sta @mod1+1
                lda splash_procs_hi,y
                sta @mod1+2
                ldx splash_offsets,y
                ldy bucket_xcol
                tya
                clc
                adc #bucketByteWidth
@mod1           jsr $ffff

                ldy bucket_count
                lda bucket_procs_lo-1,y
                sta @mod2+1
                lda bucket_procs_hi-1,y
                sta @mod2+2
                ldy bucket_xshift
                ldx bucket_offsets,y
                ldy bucket_xcol
                tya
                clc
                adc #bucketByteWidth-1
@mod2           jmp $ffff

bucket_procs_lo .byte <draw_1bucket
                .byte <draw_2buckets
                .byte <draw_3buckets

bucket_procs_hi .byte >draw_1bucket
                .byte >draw_2buckets
                .byte >draw_3buckets

draw_3buckets   sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket0_line0,y
                sta bucket1_line0,y
                sta bucket2_line0,y
                inx
                lda bucket_bits,x
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
                inx
                lda bucket_bits,x
                sta bucket0_line7,y
                sta bucket1_line7,y
                sta bucket2_line7,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket0_line0,y
                sta bucket0_line0,y
                lda bucket_bits,x
                eor bucket1_line0,y
                sta bucket1_line0,y
                lda bucket_bits,x
                eor bucket2_line0,y
                sta bucket2_line0,y
                inx
                txa
                pha
                lda bucket_bits,x
                tax
;               txa
                eor bucket0_line2,y
                sta bucket0_line2,y
                txa
                eor bucket1_line2,y
                sta bucket1_line2,y
                txa
                eor bucket2_line2,y
                sta bucket2_line2,y
                txa
                eor bucket0_line3,y
                sta bucket0_line3,y
                txa
                eor bucket1_line3,y
                sta bucket1_line3,y
                txa
                eor bucket2_line3,y
                sta bucket2_line3,y
                txa
                eor bucket0_line4,y
                sta bucket0_line4,y
                txa
                eor bucket1_line4,y
                sta bucket1_line4,y
                txa
                eor bucket2_line4,y
                sta bucket2_line4,y
                txa
                eor bucket0_line5,y
                sta bucket0_line5,y
                txa
                eor bucket1_line5,y
                sta bucket1_line5,y
                txa
                eor bucket2_line5,y
                sta bucket2_line5,y
                txa
                eor bucket0_line6,y
                sta bucket0_line6,y
                txa
                eor bucket1_line6,y
                sta bucket1_line6,y
                txa
                eor bucket2_line6,y
                sta bucket2_line6,y
                pla
                tax
                inx
                lda bucket_bits,x
                eor bucket0_line7,y
                sta bucket0_line7,y
                lda bucket_bits,x
                eor bucket1_line7,y
                sta bucket1_line7,y
                lda bucket_bits,x
                eor bucket2_line7,y
                sta bucket2_line7,y
                inx
                iny
                rts

draw_2buckets   sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket0_line0,y
                sta bucket1_line0,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket0_line2,y
                sta bucket1_line2,y
                sta clip_buffer,y
                sta bucket0_line3,y
                sta bucket1_line3,y
                sta clip_buffer,y
                sta bucket0_line4,y
                sta bucket1_line4,y
                sta clip_buffer,y
                sta bucket0_line5,y
                sta bucket1_line5,y
                sta clip_buffer,y
                sta bucket0_line6,y
                sta bucket1_line6,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket0_line7,y
                sta bucket1_line7,y
                sta clip_buffer,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket0_line0,y
                sta bucket0_line0,y
                lda bucket_bits,x
                eor bucket1_line0,y
                sta bucket1_line0,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                txa
                pha
                lda bucket_bits,x
                tax
;               txa
                eor bucket0_line2,y
                sta bucket0_line2,y
                txa
                eor bucket1_line2,y
                sta bucket1_line2,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line3,y
                sta bucket0_line3,y
                txa
                eor bucket1_line3,y
                sta bucket1_line3,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line4,y
                sta bucket0_line4,y
                txa
                eor bucket1_line4,y
                sta bucket1_line4,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line5,y
                sta bucket0_line5,y
                txa
                eor bucket1_line5,y
                sta bucket1_line5,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line6,y
                sta bucket0_line6,y
                txa
                eor bucket1_line6,y
                sta bucket1_line6,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                pla
                tax
                inx
                lda bucket_bits,x
                eor bucket0_line7,y
                sta bucket0_line7,y
                lda bucket_bits,x
                eor bucket1_line7,y
                sta bucket1_line7,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                iny
                rts

draw_1bucket    sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket0_line0,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket0_line2,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket0_line3,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket0_line4,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket0_line5,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket0_line6,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket0_line7,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket0_line0,y
                sta bucket0_line0,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                txa
                pha
                lda bucket_bits,x
                tax
;               txa
                eor bucket0_line2,y
                sta bucket0_line2,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line3,y
                sta bucket0_line3,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line4,y
                sta bucket0_line4,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line5,y
                sta bucket0_line5,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket0_line6,y
                sta bucket0_line6,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                pla
                tax
                inx
                lda bucket_bits,x
                eor bucket0_line7,y
                sta bucket0_line7,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                iny
                rts

bucket_offsets  .byte bucket_shift0-bucket_bits
                .byte bucket_shift1-bucket_bits
                .byte bucket_shift2-bucket_bits
                .byte bucket_shift3-bucket_bits
                .byte bucket_shift4-bucket_bits
                .byte bucket_shift5-bucket_bits
                .byte bucket_shift6-bucket_bits

bucket_bits
bucket_shift0   .byte $56,$25,$55
                .byte $2a,$29,$2a
                .byte $55,$4a,$55
                .byte $2a,$52,$2a
                .byte $2d,$34,$35
                .byte $00,$00,$00

bucket_shift1   .byte $2d,$4b,$2b
                .byte $55,$52,$55
                .byte $2a,$14,$2a
                .byte $55,$25,$55
                .byte $5a,$69,$6a
                .byte $00,$00,$00

bucket_shift2   .byte $5a,$16,$56
                .byte $2a,$25,$2a
                .byte $55,$29,$55
                .byte $2a,$4a,$2a
                .byte $35,$52,$55
                .byte $00,$00,$00

bucket_shift3   .byte $35,$2d,$2d
                .byte $55,$4a,$55
                .byte $2a,$52,$2a
                .byte $55,$14,$55
                .byte $6a,$25,$2a
                .byte $00,$01,$01

bucket_shift4   .byte $6a,$5a,$5a
                .byte $2a,$14,$2a
                .byte $55,$25,$55
                .byte $2a,$29,$2a
                .byte $55,$4a,$55
                .byte $00,$03,$03

bucket_shift5   .byte $55,$35,$35
                .byte $55,$29,$55
                .byte $2a,$4a,$2a
                .byte $55,$52,$55
                .byte $2a,$14,$2a
                .byte $01,$07,$07

bucket_shift6   .byte $2a,$6a,$6a
                .byte $2b,$52,$2a
                .byte $55,$14,$55
                .byte $2a,$25,$2a
                .byte $55,$29,$55
                .byte $03,$0f,$0f

erase_buckets   ldy bucket_xcol
                ldx #6
                tya
                lsr
                lda #$2a
                bcc @1
                lda #$55
                ; set_page
@1              sta bucket0_line0,y
                sta bucket1_line0,y
                sta bucket2_line0,y
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
                sta bucket0_line7,y
                sta bucket1_line7,y
                sta bucket2_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                ; fall through

erase_splash_cols
                lda splash_bucket
                sta temp
                ldy bucket_xcol
                ldx #6                  ;*** will change to 5
                tya
                lsr
                lda #$2a
                bcc @1
                lda #$55
@1              lsr temp
                bne erase_splash2_cols
                bcs erase_splash1_cols
                ; fall through

erase_splash0_cols
                ; set_page
@1              sta splash0_line0,y
                sta splash0_line1,y
                sta splash0_line2,y
                sta splash0_line3,y
                sta splash0_line4,y
                sta splash0_line5,y
                sta splash0_line6,y
                sta splash0_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                rts

erase_splash1_cols
                ; set_page
@1              sta splash1_line0,y
                sta splash1_line1,y
                sta splash1_line2,y
                sta splash1_line3,y
                sta splash1_line4,y
                sta splash1_line5,y
                sta splash1_line6,y
                sta splash1_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                rts

erase_splash2_cols
                ; set_page
@1              sta splash2_line0,y
                sta splash2_line1,y
                sta splash2_line2,y
                sta splash2_line3,y
                sta splash2_line4,y
                sta splash2_line5,y
                sta splash2_line6,y
                sta splash2_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                rts

.macro splash_top _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta splash0_line0,y
                lda _bits+1,x
                sta splash0_line1,y
                lda _bits+2,x
                sta splash0_line2,y
                lda _bits+3,x
                sta splash0_line3,y
                lda _bits+4,x
                sta splash0_line4,y
                lda _bits+5,x
                sta splash0_line5,y
                lda _bits+6,x
                sta splash0_line6,y
                lda _bits+7,x
                sta splash0_line7,y
                txa
;               clc
                adc #8
                tax
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page
                rts
.endmacro

.macro splash_mid _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta splash1_line0,y
                lda _bits+1,x
                sta splash1_line1,y
                lda _bits+2,x
                sta splash1_line2,y
                lda _bits+3,x
                sta splash1_line3,y
                lda _bits+4,x
                sta splash1_line4,y
                lda _bits+5,x
                sta splash1_line5,y
                lda _bits+6,x
                sta splash1_line6,y
                lda _bits+7,x
                sta splash1_line7,y
                txa
;               clc
                adc #8
                tax
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page
                rts
.endmacro

.macro splash_bot _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta splash2_line0,y
                lda _bits+1,x
                sta splash2_line1,y
                lda _bits+2,x
                sta splash2_line2,y
                lda _bits+3,x
                sta splash2_line3,y
                lda _bits+4,x
                sta splash2_line4,y
                lda _bits+5,x
                sta splash2_line5,y
                lda _bits+6,x
                sta splash2_line6,y
                lda _bits+7,x
                sta splash2_line7,y
                txa
;               clc
                adc #8
                tax
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page
                rts
.endmacro

splash_procs_lo .byte <draw_splash_a0   ; splash_f0_0 (top)
                .byte <draw_splash_a0   ; splash_f0_1
                .byte <draw_splash_a0   ; splash_f0_2
                .byte <draw_splash_a0   ; splash_f0_3
                .byte <draw_splash_a0   ; splash_f0_4
                .byte <draw_splash_a0   ; splash_f0_5
                .byte <draw_splash_a0   ; splash_f0_6
                .byte 0
                .byte <draw_splash_a0   ; splash_f1_0
                .byte <draw_splash_b0   ; splash_f1_1
                .byte <draw_splash_b0   ; splash_f1_2
                .byte <draw_splash_b0   ; splash_f1_3
                .byte <draw_splash_b0   ; splash_f1_4
                .byte <draw_splash_b0   ; splash_f1_5
                .byte <draw_splash_c0   ; splash_f1_6
                .byte 0
                .byte <draw_splash_c0   ; splash_f2_0
                .byte <draw_splash_c0   ; splash_f2_1
                .byte <draw_splash_c0   ; splash_f2_2
                .byte <draw_splash_c0   ; splash_f2_3
                .byte <draw_splash_d0   ; splash_f2_4
                .byte <draw_splash_d0   ; splash_f2_5
                .byte <draw_splash_d0   ; splash_f2_6
                .byte 0
                .byte <draw_splash_d0   ; splash_f3_0
                .byte <draw_splash_d0   ; splash_f3_1
                .byte <draw_splash_e0   ; splash_f3_2
                .byte <draw_splash_e0   ; splash_f3_3
                .byte <draw_splash_e0   ; splash_f3_4
                .byte <draw_splash_e0   ; splash_f3_5
                .byte <draw_splash_e0   ; splash_f3_6
                .byte 0
                .byte <draw_splash_a1   ; splash_f0_0 (mid)
                .byte <draw_splash_a1   ; splash_f0_1
                .byte <draw_splash_a1   ; splash_f0_2
                .byte <draw_splash_a1   ; splash_f0_3
                .byte <draw_splash_a1   ; splash_f0_4
                .byte <draw_splash_a1   ; splash_f0_5
                .byte <draw_splash_a1   ; splash_f0_6
                .byte 0
                .byte <draw_splash_a1   ; splash_f1_0
                .byte <draw_splash_b1   ; splash_f1_1
                .byte <draw_splash_b1   ; splash_f1_2
                .byte <draw_splash_b1   ; splash_f1_3
                .byte <draw_splash_b1   ; splash_f1_4
                .byte <draw_splash_b1   ; splash_f1_5
                .byte <draw_splash_c1   ; splash_f1_6
                .byte 0
                .byte <draw_splash_c1   ; splash_f2_0
                .byte <draw_splash_c1   ; splash_f2_1
                .byte <draw_splash_c1   ; splash_f2_2
                .byte <draw_splash_c1   ; splash_f2_3
                .byte <draw_splash_d1   ; splash_f2_4
                .byte <draw_splash_d1   ; splash_f2_5
                .byte <draw_splash_d1   ; splash_f2_6
                .byte 0
                .byte <draw_splash_d1   ; splash_f3_0
                .byte <draw_splash_d1   ; splash_f3_1
                .byte <draw_splash_e1   ; splash_f3_2
                .byte <draw_splash_e1   ; splash_f3_3
                .byte <draw_splash_e1   ; splash_f3_4
                .byte <draw_splash_e1   ; splash_f3_5
                .byte <draw_splash_e1   ; splash_f3_6
                .byte 0
                .byte <draw_splash_a2   ; splash_f0_0 (bot)
                .byte <draw_splash_a2   ; splash_f0_1
                .byte <draw_splash_a2   ; splash_f0_2
                .byte <draw_splash_a2   ; splash_f0_3
                .byte <draw_splash_a2   ; splash_f0_4
                .byte <draw_splash_a2   ; splash_f0_5
                .byte <draw_splash_a2   ; splash_f0_6
                .byte 0
                .byte <draw_splash_a2   ; splash_f1_0
                .byte <draw_splash_b2   ; splash_f1_1
                .byte <draw_splash_b2   ; splash_f1_2
                .byte <draw_splash_b2   ; splash_f1_3
                .byte <draw_splash_b2   ; splash_f1_4
                .byte <draw_splash_b2   ; splash_f1_5
                .byte <draw_splash_c2   ; splash_f1_6
                .byte 0
                .byte <draw_splash_c2   ; splash_f2_0
                .byte <draw_splash_c2   ; splash_f2_1
                .byte <draw_splash_c2   ; splash_f2_2
                .byte <draw_splash_c2   ; splash_f2_3
                .byte <draw_splash_d2   ; splash_f2_4
                .byte <draw_splash_d2   ; splash_f2_5
                .byte <draw_splash_d2   ; splash_f2_6
                .byte 0
                .byte <draw_splash_d2   ; splash_f3_0
                .byte <draw_splash_d2   ; splash_f3_1
                .byte <draw_splash_e2   ; splash_f3_2
                .byte <draw_splash_e2   ; splash_f3_3
                .byte <draw_splash_e2   ; splash_f3_4
                .byte <draw_splash_e2   ; splash_f3_5
                .byte <draw_splash_e2   ; splash_f3_6
;               .byte 0

splash_procs_hi .byte >draw_splash_a0   ; splash_f0_0 (top)
                .byte >draw_splash_a0   ; splash_f0_1
                .byte >draw_splash_a0   ; splash_f0_2
                .byte >draw_splash_a0   ; splash_f0_3
                .byte >draw_splash_a0   ; splash_f0_4
                .byte >draw_splash_a0   ; splash_f0_5
                .byte >draw_splash_a0   ; splash_f0_6
                .byte 0
                .byte >draw_splash_a0   ; splash_f1_0
                .byte >draw_splash_b0   ; splash_f1_1
                .byte >draw_splash_b0   ; splash_f1_2
                .byte >draw_splash_b0   ; splash_f1_3
                .byte >draw_splash_b0   ; splash_f1_4
                .byte >draw_splash_b0   ; splash_f1_5
                .byte >draw_splash_c0   ; splash_f1_6
                .byte 0
                .byte >draw_splash_c0   ; splash_f2_0
                .byte >draw_splash_c0   ; splash_f2_1
                .byte >draw_splash_c0   ; splash_f2_2
                .byte >draw_splash_c0   ; splash_f2_3
                .byte >draw_splash_d0   ; splash_f2_4
                .byte >draw_splash_d0   ; splash_f2_5
                .byte >draw_splash_d0   ; splash_f2_6
                .byte 0
                .byte >draw_splash_d0   ; splash_f3_0
                .byte >draw_splash_d0   ; splash_f3_1
                .byte >draw_splash_e0   ; splash_f3_2
                .byte >draw_splash_e0   ; splash_f3_3
                .byte >draw_splash_e0   ; splash_f3_4
                .byte >draw_splash_e0   ; splash_f3_5
                .byte >draw_splash_e0   ; splash_f3_6
                .byte 0
                .byte >draw_splash_a1   ; splash_f0_0 (mid)
                .byte >draw_splash_a1   ; splash_f0_1
                .byte >draw_splash_a1   ; splash_f0_2
                .byte >draw_splash_a1   ; splash_f0_3
                .byte >draw_splash_a1   ; splash_f0_4
                .byte >draw_splash_a1   ; splash_f0_5
                .byte >draw_splash_a1   ; splash_f0_6
                .byte 0
                .byte >draw_splash_a1   ; splash_f1_0
                .byte >draw_splash_b1   ; splash_f1_1
                .byte >draw_splash_b1   ; splash_f1_2
                .byte >draw_splash_b1   ; splash_f1_3
                .byte >draw_splash_b1   ; splash_f1_4
                .byte >draw_splash_b1   ; splash_f1_5
                .byte >draw_splash_c1   ; splash_f1_6
                .byte 0
                .byte >draw_splash_c1   ; splash_f2_0
                .byte >draw_splash_c1   ; splash_f2_1
                .byte >draw_splash_c1   ; splash_f2_2
                .byte >draw_splash_c1   ; splash_f2_3
                .byte >draw_splash_d1   ; splash_f2_4
                .byte >draw_splash_d1   ; splash_f2_5
                .byte >draw_splash_d1   ; splash_f2_6
                .byte 0
                .byte >draw_splash_d1   ; splash_f3_0
                .byte >draw_splash_d1   ; splash_f3_1
                .byte >draw_splash_e1   ; splash_f3_2
                .byte >draw_splash_e1   ; splash_f3_3
                .byte >draw_splash_e1   ; splash_f3_4
                .byte >draw_splash_e1   ; splash_f3_5
                .byte >draw_splash_e1   ; splash_f3_6
                .byte 0
                .byte >draw_splash_a2   ; splash_f0_0 (bot)
                .byte >draw_splash_a2   ; splash_f0_1
                .byte >draw_splash_a2   ; splash_f0_2
                .byte >draw_splash_a2   ; splash_f0_3
                .byte >draw_splash_a2   ; splash_f0_4
                .byte >draw_splash_a2   ; splash_f0_5
                .byte >draw_splash_a2   ; splash_f0_6
                .byte 0
                .byte >draw_splash_a2   ; splash_f1_0
                .byte >draw_splash_b2   ; splash_f1_1
                .byte >draw_splash_b2   ; splash_f1_2
                .byte >draw_splash_b2   ; splash_f1_3
                .byte >draw_splash_b2   ; splash_f1_4
                .byte >draw_splash_b2   ; splash_f1_5
                .byte >draw_splash_c2   ; splash_f1_6
                .byte 0
                .byte >draw_splash_c2   ; splash_f2_0
                .byte >draw_splash_c2   ; splash_f2_1
                .byte >draw_splash_c2   ; splash_f2_2
                .byte >draw_splash_c2   ; splash_f2_3
                .byte >draw_splash_d2   ; splash_f2_4
                .byte >draw_splash_d2   ; splash_f2_5
                .byte >draw_splash_d2   ; splash_f2_6
                .byte 0
                .byte >draw_splash_d2   ; splash_f3_0
                .byte >draw_splash_d2   ; splash_f3_1
                .byte >draw_splash_e2   ; splash_f3_2
                .byte >draw_splash_e2   ; splash_f3_3
                .byte >draw_splash_e2   ; splash_f3_4
                .byte >draw_splash_e2   ; splash_f3_5
                .byte >draw_splash_e2   ; splash_f3_6
;               .byte 0

splash_offsets  .byte 2*48,3*48,2*48,3*48,2*48,3*48,2*48,0   ; splash_f0_0 - 6
                .byte 4*48,0*48,1*48,2*48,3*48,4*48,0*48,0   ; splash_f1_0 - 6
                .byte 1*48,2*48,3*48,4*48,0*48,1*48,2*48,0   ; splash_f2_0 - 6
                .byte 3*48,4*48,0*48,1*48,2*48,3*48,4*48,0   ; splash_f3_0 - 6

                .byte 2*48,3*48,2*48,3*48,2*48,3*48,2*48,0   ; splash_f0_0 - 6
                .byte 4*48,0*48,1*48,2*48,3*48,4*48,0*48,0   ; splash_f1_0 - 6
                .byte 1*48,2*48,3*48,4*48,0*48,1*48,2*48,0   ; splash_f2_0 - 6
                .byte 3*48,4*48,0*48,1*48,2*48,3*48,4*48,0   ; splash_f3_0 - 6

                .byte 2*48,3*48,2*48,3*48,2*48,3*48,2*48,0   ; splash_f0_0 - 6
                .byte 4*48,0*48,1*48,2*48,3*48,4*48,0*48,0   ; splash_f1_0 - 6
                .byte 1*48,2*48,3*48,4*48,0*48,1*48,2*48,0   ; splash_f2_0 - 6
                .byte 3*48,4*48,0*48,1*48,2*48,3*48,4*48,0   ; splash_f3_0 - 6

draw_splash_a0  splash_top splash_set_a
draw_splash_b0  splash_top splash_set_b
draw_splash_c0  splash_top splash_set_c
draw_splash_d0  splash_top splash_set_d
draw_splash_e0  splash_top splash_set_e

draw_splash_a1  splash_mid splash_set_a
draw_splash_b1  splash_mid splash_set_b
draw_splash_c1  splash_mid splash_set_c
draw_splash_d1  splash_mid splash_set_d
draw_splash_e1  splash_mid splash_set_e

draw_splash_a2  splash_bot splash_set_a
draw_splash_b2  splash_bot splash_set_b
draw_splash_c2  splash_bot splash_set_c
draw_splash_d2  splash_bot splash_set_d
draw_splash_e2  splash_bot splash_set_e

                .align 256
splash_set_a    ; *** split/move this ***
xxx_bucket_5    .byte $55,$55,$35,$35,$35,$35,$35,$35 ;***
                .byte $55,$2a,$29,$29,$29,$29,$29,$55
                .byte $2a,$55,$4a,$4a,$4a,$4a,$4a,$2a
                .byte $55,$2a,$52,$52,$52,$52,$52,$55
                .byte $2a,$55,$14,$14,$14,$14,$14,$2a
                .byte $2b,$2a,$2d,$2d,$2d,$2d,$2d,$2d

xxx_bucket_6    .byte $2a,$2a,$6a,$6a,$6a,$6a,$6a,$6a ;***
                .byte $2b,$55,$52,$52,$52,$52,$52,$2a
                .byte $55,$2a,$14,$14,$14,$14,$14,$55
                .byte $2a,$55,$25,$25,$25,$25,$25,$2a
                .byte $55,$2a,$29,$29,$29,$29,$29,$55
                .byte $56,$55,$5a,$5a,$5a,$5a,$5a,$5a

splash_f0_0     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f0_1     .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f1_0     .byte $2a,$2a,$2a,$3e,$2a,$2a,$2a,$7a
                .byte $55,$55,$7d,$55,$55,$7f,$55,$55
                .byte $2a,$2a,$6a,$2a,$2e,$7f,$2a,$2e
                .byte $55,$55,$57,$55,$55,$57,$55,$75
                .byte $2a,$2a,$2a,$2f,$2a,$2a,$2a,$2b
                .byte $55,$55,$55,$55,$55,$55,$55,$55

                .align 256
splash_set_b
splash_f1_1     .byte $55,$55,$55,$7d,$55,$55,$55,$75
                .byte $2a,$2a,$7a,$2a,$2a,$7e,$2a,$2b
                .byte $55,$55,$55,$55,$5d,$7f,$55,$5d
                .byte $2a,$2a,$2f,$2a,$2a,$2f,$2a,$6a
                .byte $55,$55,$55,$5f,$55,$55,$55,$57
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f1_2     .byte $2a,$2a,$2a,$7a,$2a,$2a,$2a,$6a
                .byte $55,$55,$75,$55,$55,$7d,$55,$57
                .byte $2a,$2a,$2b,$2a,$3a,$7f,$2a,$3a
                .byte $55,$55,$5f,$55,$55,$5f,$55,$55
                .byte $2a,$2a,$2a,$3e,$2a,$2a,$2a,$2f
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f1_3     .byte $55,$55,$55,$75,$55,$55,$55,$55
                .byte $2a,$2a,$6a,$2b,$2a,$7a,$2a,$2f
                .byte $55,$55,$57,$55,$75,$7f,$55,$75
                .byte $2a,$2a,$3e,$2a,$2a,$3f,$2a,$2a
                .byte $55,$55,$55,$7d,$55,$55,$55,$5f
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f1_4     .byte $2a,$2a,$2a,$6a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$57,$55,$75,$55,$5f
                .byte $2a,$2a,$2f,$2a,$6a,$7f,$2a,$6a
                .byte $55,$55,$7d,$55,$55,$7f,$55,$55
                .byte $2a,$2a,$2a,$7a,$2a,$2a,$2a,$3e
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f1_5     .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2f,$2a,$6a,$2a,$3e
                .byte $55,$55,$5f,$55,$55,$7f,$55,$55
                .byte $2a,$2a,$7a,$2a,$2b,$7f,$2a,$2b
                .byte $55,$55,$55,$75,$55,$55,$55,$7d
                .byte $2a,$2a,$2a,$2b,$2a,$2a,$2a,$2a

                .align 256
splash_set_c
splash_f1_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$5f,$55,$55,$55,$7d
                .byte $2a,$2a,$3e,$2a,$2a,$7f,$2a,$2a
                .byte $55,$55,$75,$55,$57,$7f,$55,$57
                .byte $2a,$2a,$2b,$6a,$2a,$2b,$2a,$7a
                .byte $55,$55,$55,$57,$55,$55,$55,$55

splash_f2_0     .byte $2a,$2a,$2a,$2a,$3e,$2a,$2a,$2a
                .byte $55,$7d,$55,$55,$55,$5d,$55,$55
                .byte $2a,$6a,$2a,$2e,$2e,$2a,$2e,$2e
                .byte $55,$57,$55,$55,$55,$57,$55,$55
                .byte $2a,$2a,$2a,$2a,$2f,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f2_1     .byte $55,$55,$55,$55,$7d,$55,$55,$55
                .byte $2a,$7a,$2a,$2a,$2a,$3a,$2a,$2a
                .byte $55,$55,$55,$5d,$5d,$55,$5d,$5d
                .byte $2a,$2f,$2a,$2a,$2a,$2e,$2a,$2a
                .byte $55,$55,$55,$55,$5f,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f2_2     .byte $2a,$2a,$2a,$2a,$7a,$2a,$2a,$2a
                .byte $55,$75,$55,$55,$55,$75,$55,$55
                .byte $2a,$2b,$2a,$3a,$3a,$2a,$3a,$3a
                .byte $55,$5f,$55,$55,$55,$5d,$55,$55
                .byte $2a,$2a,$2a,$2a,$3e,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f2_3     .byte $55,$55,$55,$55,$75,$55,$55,$55
                .byte $2a,$6a,$2a,$2a,$2b,$6a,$2a,$2a
                .byte $55,$57,$55,$75,$55,$55,$75,$75
                .byte $2a,$3e,$2a,$2a,$2a,$3a,$2a,$2a
                .byte $55,$55,$55,$55,$7d,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

                .align 256
splash_set_d
splash_f2_4     .byte $2a,$2a,$2a,$2a,$6a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$57,$55,$55,$55
                .byte $2a,$2f,$2a,$6a,$6a,$2b,$6a,$6a
                .byte $55,$7d,$55,$55,$55,$75,$55,$55
                .byte $2a,$2a,$2a,$2a,$7a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f2_5     .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2f,$2a,$2a,$2a
                .byte $55,$5f,$55,$55,$55,$57,$55,$55
                .byte $2a,$7a,$2a,$2b,$2b,$6a,$2b,$2b
                .byte $55,$55,$55,$55,$75,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2b,$2a,$2a,$2a

splash_f2_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$5f,$55,$55,$55
                .byte $2a,$3e,$2a,$2a,$2a,$2e,$2a,$2a
                .byte $55,$75,$55,$57,$57,$55,$57,$57
                .byte $2a,$2b,$2a,$2a,$6a,$2b,$2a,$2a
                .byte $55,$55,$55,$55,$57,$55,$55,$55

splash_f3_0     .byte $2a,$2a,$7a,$2a,$2a,$2a,$7a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2e,$2a,$2e,$2e,$2a
                .byte $55,$55,$75,$55,$55,$55,$75,$55
                .byte $2a,$2a,$2b,$2a,$2a,$2a,$2b,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f3_1     .byte $55,$55,$75,$55,$55,$55,$75,$55
                .byte $2a,$2a,$2b,$2a,$2a,$2a,$2b,$2a
                .byte $55,$55,$55,$5d,$55,$5d,$5d,$55
                .byte $2a,$2a,$6a,$2a,$2a,$2a,$6a,$2a
                .byte $55,$55,$57,$55,$55,$55,$57,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

                .align 256
splash_set_e
splash_f3_2     .byte $2a,$2a,$6a,$2a,$2a,$2a,$6a,$2a
                .byte $55,$55,$57,$55,$55,$55,$57,$55
                .byte $2a,$2a,$2a,$3a,$2a,$3a,$3a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2f,$2a,$2a,$2a,$2f,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f3_3     .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2f,$2a,$2a,$2a,$2f,$2a
                .byte $55,$55,$55,$75,$55,$75,$75,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$5f,$55,$55,$55,$5f,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f3_4     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$5f,$55,$55,$55,$5f,$55
                .byte $2a,$2a,$2a,$6a,$2a,$6a,$6a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$3e,$2a,$2a,$2a,$3e,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

splash_f3_5     .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$3e,$2a,$2a,$2a,$3e,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2b,$2a,$2b,$2b,$2a
                .byte $55,$55,$7d,$55,$55,$55,$7d,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f3_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$7d,$55,$55,$55,$7d,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$57,$55,$57,$57,$55
                .byte $2a,$2a,$7a,$2a,$2a,$2a,$7a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55,$55

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
