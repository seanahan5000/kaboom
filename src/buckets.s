splash_top_line0   =   hiresLine133
splash_top_line1   =   hiresLine134
splash_top_line2   =   hiresLine135
splash_top_line3   =   hiresLine136
splash_top_line4   =   hiresLine137
splash_top_line5   =   hiresLine138
splash_top_line6   =   hiresLine139
splash_top_line7   =   hiresLine140

bucket_top_line0   =   hiresLine141
bucket_top_line1   =   hiresLine142
bucket_top_line2   =   hiresLine143
bucket_top_line3   =   hiresLine144
bucket_top_line4   =   hiresLine145
bucket_top_line5   =   hiresLine146
bucket_top_line6   =   hiresLine147
bucket_top_line7   =   hiresLine148

splash_mid_line0   =   hiresLine149
splash_mid_line1   =   hiresLine150
splash_mid_line2   =   hiresLine151
splash_mid_line3   =   hiresLine152
splash_mid_line4   =   hiresLine153
splash_mid_line5   =   hiresLine154
splash_mid_line6   =   hiresLine155
splash_mid_line7   =   hiresLine156

bucket_mid_line0   =   hiresLine157
bucket_mid_line1   =   hiresLine158
bucket_mid_line2   =   hiresLine159
bucket_mid_line3   =   hiresLine160
bucket_mid_line4   =   hiresLine161
bucket_mid_line5   =   hiresLine162
bucket_mid_line6   =   hiresLine163
bucket_mid_line7   =   hiresLine164

splash_bot_line0   =   hiresLine165
splash_bot_line1   =   hiresLine166
splash_bot_line2   =   hiresLine167
splash_bot_line3   =   hiresLine168
splash_bot_line4   =   hiresLine169
splash_bot_line5   =   hiresLine170
splash_bot_line6   =   hiresLine171
splash_bot_line7   =   hiresLine172

bucket_bot_line0   =   hiresLine173
bucket_bot_line1   =   hiresLine174
bucket_bot_line2   =   hiresLine175
bucket_bot_line3   =   hiresLine176
bucket_bot_line4   =   hiresLine177
bucket_bot_line5   =   hiresLine178
bucket_bot_line6   =   hiresLine179
bucket_bot_line7   =   hiresLine180

;
; On entry:
;   bucket_xcol and bucket_xshift setup based on buckets_x * 2
;
draw_buckets    ldy splash_bucket
                ldx splash_frame
                beq @1
                dex
                stx splash_frame
@1              txa
                bne @2
                ldy #1                  ; force middle bucket on splash_frame == 0
@2              txa
                ; 4 repeats per frame
                ; TODO: tie this to wave/speed?
                lsr
                lsr
                sta temp
                tya
                asl
                asl
;               clc
                adc temp
                asl
                tay

                lda splash_procs+0,y
                sta @mod1+1
                lda splash_procs+1,y
                sta @mod1+2
                ldy bucket_xshift
                ldx splash_offsets,y
                ldy bucket_xcol
                sty prev_bucket_xcol
                tya
                clc
                adc #bucketByteWidth-1
@mod1           jsr $ffff

                ldy bucket_count
                beq @3
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
@3              rts

bucket_procs_lo .byte <draw_1bucket
                .byte <draw_2buckets
                .byte <draw_3buckets

bucket_procs_hi .byte >draw_1bucket
                .byte >draw_2buckets
                .byte >draw_3buckets

draw_3buckets   sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket_top_line0,y
                sta bucket_mid_line0,y
                sta bucket_bot_line0,y
                inx
                lda bucket_bits,x
                sta bucket_top_line2,y
                sta bucket_mid_line2,y
                sta bucket_bot_line2,y
                sta bucket_top_line3,y
                sta bucket_mid_line3,y
                sta bucket_bot_line3,y
                sta bucket_top_line4,y
                sta bucket_mid_line4,y
                sta bucket_bot_line4,y
                sta bucket_top_line5,y
                sta bucket_mid_line5,y
                sta bucket_bot_line5,y
                sta bucket_top_line6,y
                sta bucket_mid_line6,y
                sta bucket_bot_line6,y
                inx
                lda bucket_bits,x
                sta bucket_top_line7,y
                sta bucket_mid_line7,y
                sta bucket_bot_line7,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket_top_line0,y
                sta bucket_top_line0,y
                lda bucket_bits,x
                eor bucket_mid_line0,y
                sta bucket_mid_line0,y
                lda bucket_bits,x
                eor bucket_bot_line0,y
                sta bucket_bot_line0,y
                inx
                txa
                pha
                lda bucket_bits,x
                tax
;               txa
                eor bucket_top_line2,y
                sta bucket_top_line2,y
                txa
                eor bucket_mid_line2,y
                sta bucket_mid_line2,y
                txa
                eor bucket_bot_line2,y
                sta bucket_bot_line2,y
                txa
                eor bucket_top_line3,y
                sta bucket_top_line3,y
                txa
                eor bucket_mid_line3,y
                sta bucket_mid_line3,y
                txa
                eor bucket_bot_line3,y
                sta bucket_bot_line3,y
                txa
                eor bucket_top_line4,y
                sta bucket_top_line4,y
                txa
                eor bucket_mid_line4,y
                sta bucket_mid_line4,y
                txa
                eor bucket_bot_line4,y
                sta bucket_bot_line4,y
                txa
                eor bucket_top_line5,y
                sta bucket_top_line5,y
                txa
                eor bucket_mid_line5,y
                sta bucket_mid_line5,y
                txa
                eor bucket_bot_line5,y
                sta bucket_bot_line5,y
                txa
                eor bucket_top_line6,y
                sta bucket_top_line6,y
                txa
                eor bucket_mid_line6,y
                sta bucket_mid_line6,y
                txa
                eor bucket_bot_line6,y
                sta bucket_bot_line6,y
                pla
                tax
                inx
                lda bucket_bits,x
                eor bucket_top_line7,y
                sta bucket_top_line7,y
                lda bucket_bits,x
                eor bucket_mid_line7,y
                sta bucket_mid_line7,y
                lda bucket_bits,x
                eor bucket_bot_line7,y
                sta bucket_bot_line7,y
                inx
                iny
                rts

draw_2buckets   sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket_top_line0,y
                sta bucket_mid_line0,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket_top_line2,y
                sta bucket_mid_line2,y
                sta clip_buffer,y
                sta bucket_top_line3,y
                sta bucket_mid_line3,y
                sta clip_buffer,y
                sta bucket_top_line4,y
                sta bucket_mid_line4,y
                sta clip_buffer,y
                sta bucket_top_line5,y
                sta bucket_mid_line5,y
                sta clip_buffer,y
                sta bucket_top_line6,y
                sta bucket_mid_line6,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket_top_line7,y
                sta bucket_mid_line7,y
                sta clip_buffer,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket_top_line0,y
                sta bucket_top_line0,y
                lda bucket_bits,x
                eor bucket_mid_line0,y
                sta bucket_mid_line0,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                txa
                pha
                lda bucket_bits,x
                tax
;               txa
                eor bucket_top_line2,y
                sta bucket_top_line2,y
                txa
                eor bucket_mid_line2,y
                sta bucket_mid_line2,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line3,y
                sta bucket_top_line3,y
                txa
                eor bucket_mid_line3,y
                sta bucket_mid_line3,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line4,y
                sta bucket_top_line4,y
                txa
                eor bucket_mid_line4,y
                sta bucket_mid_line4,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line5,y
                sta bucket_top_line5,y
                txa
                eor bucket_mid_line5,y
                sta bucket_mid_line5,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line6,y
                sta bucket_top_line6,y
                txa
                eor bucket_mid_line6,y
                sta bucket_mid_line6,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                pla
                tax
                inx
                lda bucket_bits,x
                eor bucket_top_line7,y
                sta bucket_top_line7,y
                lda bucket_bits,x
                eor bucket_mid_line7,y
                sta bucket_mid_line7,y
                lda bucket_bits,x
                eor clip_buffer,y
                sta clip_buffer,y
                inx
                iny
                rts

draw_1bucket    sta @mod+1
                ; set_page
@1              lda bucket_bits,x
                sta bucket_top_line0,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket_top_line2,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket_top_line3,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket_top_line4,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket_top_line5,y
                sta clip_buffer,y
                sta clip_buffer,y
                sta bucket_top_line6,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                lda bucket_bits,x
                sta bucket_top_line7,y
                sta clip_buffer,y
                sta clip_buffer,y
                inx
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page

                lda bucket_bits,x
                eor bucket_top_line0,y
                sta bucket_top_line0,y
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
                eor bucket_top_line2,y
                sta bucket_top_line2,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line3,y
                sta bucket_top_line3,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line4,y
                sta bucket_top_line4,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line5,y
                sta bucket_top_line5,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor clip_buffer,y
                sta clip_buffer,y
                txa
                eor bucket_top_line6,y
                sta bucket_top_line6,y
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
                eor bucket_top_line7,y
                sta bucket_top_line7,y
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

prev_bucket_xcol .byte 0

erase_buckets   ldy prev_bucket_xcol
                ldx #6
                tya
                lsr
                lda #$2a
                bcc @1
                lda #$55
                ; set_page
@1              sta bucket_top_line0,y
                sta bucket_mid_line0,y
                sta bucket_bot_line0,y
                sta bucket_top_line1,y
                sta bucket_mid_line1,y
                sta bucket_bot_line1,y
                sta bucket_top_line2,y
                sta bucket_mid_line2,y
                sta bucket_bot_line2,y
                sta bucket_top_line3,y
                sta bucket_mid_line3,y
                sta bucket_bot_line3,y
                sta bucket_top_line4,y
                sta bucket_mid_line4,y
                sta bucket_bot_line4,y
                sta bucket_top_line5,y
                sta bucket_mid_line5,y
                sta bucket_bot_line5,y
                sta bucket_top_line6,y
                sta bucket_mid_line6,y
                sta bucket_bot_line6,y
                sta bucket_top_line7,y
                sta bucket_mid_line7,y
                sta bucket_bot_line7,y
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
                ldx #5
                tya
                lsr
                lda #$2a
                bcc @1
                lda #$55
@1              lsr temp
                bne erase_splash_bot_cols
                bcs erase_splash_mid_cols
                ; fall through

erase_splash_top_cols
                ; set_page
@1              sta splash_top_line1,y
                sta splash_top_line2,y
                sta splash_top_line3,y
                sta splash_top_line4,y
                sta splash_top_line5,y
                sta splash_top_line6,y
                sta splash_top_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                rts

erase_splash_mid_cols
                ; set_page
@1              sta splash_mid_line1,y
                sta splash_mid_line2,y
                sta splash_mid_line3,y
                sta splash_mid_line4,y
                sta splash_mid_line5,y
                sta splash_mid_line6,y
                sta splash_mid_line7,y
                eor #$7f
                iny
                dex
                bne @1
                ; check_page
                rts

erase_splash_bot_cols
                ; set_page
@1              sta splash_bot_line1,y
                sta splash_bot_line2,y
                sta splash_bot_line3,y
                sta splash_bot_line4,y
                sta splash_bot_line5,y
                sta splash_bot_line6,y
                sta splash_bot_line7,y
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
                sta splash_top_line1,y
                lda _bits+1,x
                sta splash_top_line2,y
                lda _bits+2,x
                sta splash_top_line3,y
                lda _bits+3,x
                sta splash_top_line4,y
                lda _bits+4,x
                sta splash_top_line5,y
                lda _bits+5,x
                sta splash_top_line6,y
                lda _bits+6,x
                sta splash_top_line7,y
                txa
;               clc
                adc #7
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
                sta splash_mid_line1,y
                lda _bits+1,x
                sta splash_mid_line2,y
                lda _bits+2,x
                sta splash_mid_line3,y
                lda _bits+3,x
                sta splash_mid_line4,y
                lda _bits+4,x
                sta splash_mid_line5,y
                lda _bits+5,x
                sta splash_mid_line6,y
                lda _bits+6,x
                sta splash_mid_line7,y
                txa
;               clc
                adc #7
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
                sta splash_bot_line1,y
                lda _bits+1,x
                sta splash_bot_line2,y
                lda _bits+2,x
                sta splash_bot_line3,y
                lda _bits+3,x
                sta splash_bot_line4,y
                lda _bits+4,x
                sta splash_bot_line5,y
                lda _bits+5,x
                sta splash_bot_line6,y
                lda _bits+6,x
                sta splash_bot_line7,y
                txa
;               clc
                adc #7
                tax
                iny
@mod            cpy #$ff
                bcc @1
                ; check_page
                rts
.endmacro

splash_procs    .word draw_splash_top_f0
                .word draw_splash_top_f1
                .word draw_splash_top_f2
                .word draw_splash_top_f3

                .word draw_splash_mid_f0
                .word draw_splash_mid_f1
                .word draw_splash_mid_f2
                .word draw_splash_mid_f3

                .word draw_splash_bot_f0
                .word draw_splash_bot_f1
                .word draw_splash_bot_f2
                .word draw_splash_bot_f3

draw_splash_top_f0  splash_top splash_f0
draw_splash_top_f1  splash_top splash_f1
draw_splash_top_f2  splash_top splash_f2
draw_splash_top_f3  splash_top splash_f3

draw_splash_mid_f0  splash_mid splash_f0
draw_splash_mid_f1  splash_mid splash_f1
draw_splash_mid_f2  splash_mid splash_f2
draw_splash_mid_f3  splash_mid splash_f3

draw_splash_bot_f0  splash_bot splash_f0
draw_splash_bot_f1  splash_bot splash_f1
draw_splash_bot_f2  splash_bot splash_f2
draw_splash_bot_f3  splash_bot splash_f3

splash_offsets  .byte 0*35,1*35,2*35,3*35,4*35,5*35,6*35

                .align 256
splash_f0
splash_f0_0     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f0_1     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55

splash_f0_2     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f0_3     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55

splash_f0_4     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a

splash_f0_5     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55

splash_f0_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a

                .align 256
splash_f1
splash_f1_0     .byte $2a,$2a,$7a,$2a,$2a,$2a,$7a
                .byte $55,$7d,$55,$55,$7d,$55,$55
                .byte $2a,$6a,$2a,$2e,$7f,$2a,$2e
                .byte $55,$57,$75,$55,$57,$55,$75
                .byte $2a,$2a,$2b,$2a,$2a,$2a,$2b

splash_f1_1     .byte $55,$55,$75,$55,$55,$55,$75
                .byte $2a,$7a,$2b,$2a,$7a,$2a,$2b
                .byte $55,$55,$55,$5d,$7f,$55,$5d
                .byte $2a,$2f,$6a,$2a,$2f,$2a,$6a
                .byte $55,$55,$57,$55,$55,$55,$57

splash_f1_2     .byte $2a,$2a,$6a,$2a,$2a,$2a,$6a
                .byte $55,$75,$57,$55,$75,$55,$57
                .byte $2a,$2b,$2a,$3a,$7f,$2a,$3a
                .byte $55,$5f,$55,$55,$5f,$55,$55
                .byte $2a,$2a,$2f,$2a,$2a,$2a,$2f

splash_f1_3     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$6a,$2f,$2a,$6a,$2a,$2f
                .byte $55,$57,$55,$75,$7f,$55,$75
                .byte $2a,$3e,$2a,$2a,$3f,$2a,$2a
                .byte $55,$55,$5f,$55,$55,$55,$5f

splash_f1_4     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$5f,$55,$55,$55,$5f
                .byte $2a,$2f,$2a,$6a,$7f,$2a,$6a
                .byte $55,$7d,$55,$55,$7f,$55,$55
                .byte $2a,$2a,$3e,$2a,$2a,$2a,$3e

splash_f1_5     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$3e,$2a,$2a,$2a,$3e
                .byte $55,$5f,$55,$55,$7f,$55,$55
                .byte $2a,$7a,$2a,$2b,$7f,$2a,$2b
                .byte $55,$55,$7d,$55,$55,$55,$7d

splash_f1_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$7d,$55,$55,$55,$7d
                .byte $2a,$3e,$2a,$2a,$7e,$2a,$2a
                .byte $55,$75,$55,$57,$7f,$55,$57
                .byte $2a,$2b,$7a,$2a,$2b,$2a,$7a

                .align 256
splash_f2
splash_f2_0     .byte $2a,$2a,$2a,$7a,$2a,$2a,$2a
                .byte $7d,$55,$55,$55,$5d,$55,$55
                .byte $6a,$2a,$2e,$2e,$2a,$2e,$2e
                .byte $57,$55,$55,$75,$57,$55,$55
                .byte $2a,$2a,$2a,$2b,$2a,$2a,$2a

splash_f2_1     .byte $55,$55,$55,$7d,$55,$55,$55
                .byte $7a,$2a,$2a,$2a,$3a,$2a,$2a
                .byte $55,$55,$5d,$5d,$55,$5d,$5d
                .byte $2f,$2a,$2a,$6a,$2e,$2a,$2a
                .byte $55,$55,$55,$57,$55,$55,$55

splash_f2_2     .byte $2a,$2a,$2a,$6a,$2a,$2a,$2a
                .byte $75,$55,$55,$57,$75,$55,$55
                .byte $2b,$2a,$3a,$3a,$2a,$3a,$3a
                .byte $5f,$55,$55,$55,$5d,$55,$55
                .byte $2a,$2a,$2a,$2f,$2a,$2a,$2a

splash_f2_3     .byte $55,$55,$55,$75,$55,$55,$55
                .byte $6a,$2a,$2a,$2b,$6a,$2a,$2a
                .byte $57,$55,$75,$55,$55,$75,$75
                .byte $3e,$2a,$2a,$2a,$3a,$2a,$2a
                .byte $55,$55,$55,$5f,$55,$55,$55

splash_f2_4     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$5f,$55,$55,$55
                .byte $2f,$2a,$6a,$6a,$2b,$6a,$6a
                .byte $7d,$55,$55,$55,$75,$55,$55
                .byte $2a,$2a,$2a,$3e,$2a,$2a,$2a

splash_f2_5     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2a,$2f,$2a,$2a,$2a
                .byte $5f,$55,$55,$55,$57,$55,$55
                .byte $7a,$2a,$2b,$2b,$6a,$2b,$2b
                .byte $55,$55,$55,$7d,$55,$55,$55

splash_f2_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$55,$7d,$55,$55,$55
                .byte $3e,$2a,$2a,$2a,$2e,$2a,$2a
                .byte $75,$55,$57,$57,$55,$57,$57
                .byte $2b,$2a,$2a,$7a,$2b,$2a,$2a

                .align 256
splash_f3
splash_f3_0     .byte $2a,$7a,$2a,$2a,$2a,$7a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2e,$2a,$2e,$2e,$2a
                .byte $55,$75,$55,$55,$55,$75,$55
                .byte $2a,$2b,$2a,$2a,$2a,$2b,$2a

splash_f3_1     .byte $55,$75,$55,$55,$55,$75,$55
                .byte $2a,$2b,$2a,$2a,$2a,$2b,$2a
                .byte $55,$55,$5d,$55,$5d,$5d,$55
                .byte $2a,$6a,$2a,$2a,$2a,$6a,$2a
                .byte $55,$57,$55,$55,$55,$57,$55

splash_f3_2     .byte $2a,$6a,$2a,$2a,$2a,$6a,$2a
                .byte $55,$57,$55,$55,$55,$57,$55
                .byte $2a,$2a,$3a,$2a,$3a,$3a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2f,$2a,$2a,$2a,$2f,$2a

splash_f3_3     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2f,$2a,$2a,$2a,$2f,$2a
                .byte $55,$55,$75,$55,$75,$75,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$5f,$55,$55,$55,$5f,$55

splash_f3_4     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$5f,$55,$55,$55,$5f,$55
                .byte $2a,$2a,$6a,$2a,$6a,$6a,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$3e,$2a,$2a,$2a,$3e,$2a

splash_f3_5     .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$3e,$2a,$2a,$2a,$3e,$2a
                .byte $55,$55,$55,$55,$55,$55,$55
                .byte $2a,$2a,$2b,$2a,$2b,$2b,$2a
                .byte $55,$7d,$55,$55,$55,$7d,$55

splash_f3_6     .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$7d,$55,$55,$55,$7d,$55
                .byte $2a,$2a,$2a,$2a,$2a,$2a,$2a
                .byte $55,$55,$57,$55,$57,$57,$55
                .byte $2a,$7a,$2a,$2a,$2a,$7a,$2a

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
