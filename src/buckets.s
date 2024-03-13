
; NOTE: Buckets can move +/- 80 pixels, so fully erasing and
;   then redrawing buckets is the same as worst case delta update.

;
; On entry:
;   A: X position (0-139) *** minus width?
;
;   draw at X * 2
;
draw_buckets    lda buckets_x
                asl
                tax
                lda div7,x
                sta bucket_xcol
                lda mod7,x
                sta bucket_xshift

                lda splash_bucket
                asl
                asl
;               clc
                adc splash_frame
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

                lda bucket_count
                asl
                asl
                asl
;               clc
                adc bucket_xshift
                tay
                ; -8 to compensate for 1-based bucket_count
                lda bucket_procs_lo-8,y
                sta @mod2+1
                lda bucket_procs_hi-8,y
                sta @mod2+2
                ldx bucket_offsets-8,y
                ldy bucket_xcol
                tya
                clc
                adc #bucketByteWidth
@mod2           jmp $ffff

erase_buckets   ldy bucket_xcol
                ldx #6
                tya
                lsr
                lda #$2a
                bcc @1
                lda #$55
                ; set_page
@1              sta bucket0_line0,y     ;136
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
                eor #$7f
                iny
                dex
                bne @1
                ; check_page

erase_splash_cols
                lda splash_bucket
                sta temp
                ldy bucket_xcol
                ldx #6
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

.macro buckets3 _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta bucket0_line0,y     ;136
                sta bucket1_line0,y     ;152
                sta bucket2_line0,y     ;168
                lda _bits+1,x
                sta bucket0_line1,y
                sta bucket1_line1,y
                sta bucket2_line1,y
                lda _bits+2,x
                sta bucket0_line2,y
                sta bucket1_line2,y
                sta bucket2_line2,y
                lda _bits+3,x
                sta bucket0_line3,y
                sta bucket1_line3,y
                sta bucket2_line3,y
                lda _bits+4,x
                sta bucket0_line4,y
                sta bucket1_line4,y
                sta bucket2_line4,y
                lda _bits+5,x
                sta bucket0_line5,y
                sta bucket1_line5,y
                sta bucket2_line5,y
                lda _bits+6,x
                sta bucket0_line6,y
                sta bucket1_line6,y
                sta bucket2_line6,y
                lda _bits+7,x
                sta bucket0_line7,y     ;143
                sta bucket1_line7,y     ;159
                sta bucket2_line7,y     ;175
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

.macro buckets2 _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta bucket0_line0,y     ;136
                sta bucket1_line0,y     ;152
                sta bucket1_line0,y     ;152
                lda _bits+1,x
                sta bucket0_line1,y
                sta bucket1_line1,y
                sta bucket1_line1,y
                lda _bits+2,x
                sta bucket0_line2,y
                sta bucket1_line2,y
                sta bucket1_line2,y
                lda _bits+3,x
                sta bucket0_line3,y
                sta bucket1_line3,y
                sta bucket1_line3,y
                lda _bits+4,x
                sta bucket0_line4,y
                sta bucket1_line4,y
                sta bucket1_line4,y
                lda _bits+5,x
                sta bucket0_line5,y
                sta bucket1_line5,y
                sta bucket1_line5,y
                lda _bits+6,x
                sta bucket0_line6,y
                sta bucket1_line6,y
                sta bucket1_line6,y
                lda _bits+7,x
                sta bucket0_line7,y     ;143
                sta bucket1_line7,y     ;159
                sta bucket1_line7,y     ;159
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

.macro buckets1 _bits
                sta @mod+1
                ; set_page
                clc
@1              lda _bits+0,x
                sta bucket0_line0,y     ;136
                sta bucket0_line0,y     ;136
                sta bucket0_line0,y     ;136
                lda _bits+1,x
                sta bucket0_line1,y
                sta bucket0_line1,y
                sta bucket0_line1,y
                lda _bits+2,x
                sta bucket0_line2,y
                sta bucket0_line2,y
                sta bucket0_line2,y
                lda _bits+3,x
                sta bucket0_line3,y
                sta bucket0_line3,y
                sta bucket0_line3,y
                lda _bits+4,x
                sta bucket0_line4,y
                sta bucket0_line4,y
                sta bucket0_line4,y
                lda _bits+5,x
                sta bucket0_line5,y
                sta bucket0_line5,y
                sta bucket0_line5,y
                lda _bits+6,x
                sta bucket0_line6,y
                sta bucket0_line6,y
                sta bucket0_line6,y
                lda _bits+7,x
                sta bucket0_line7,y     ;143
                sta bucket0_line7,y     ;143
                sta bucket0_line7,y     ;143
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

bucket_procs_lo .byte <draw_buckets1_a  ; buckets1_0
                .byte <draw_buckets1_a  ; buckets1_1
                .byte <draw_buckets1_a  ; buckets1_2
                .byte <draw_buckets1_a  ; buckets1_3
                .byte <draw_buckets1_a  ; buckets1_4
                .byte <draw_buckets1_b  ; buckets1_5
                .byte <draw_buckets1_b  ; buckets1_6
                .byte 0
                .byte <draw_buckets2_a  ; buckets2_0
                .byte <draw_buckets2_a  ; buckets2_1
                .byte <draw_buckets2_a  ; buckets2_2
                .byte <draw_buckets2_a  ; buckets2_3
                .byte <draw_buckets2_a  ; buckets2_4
                .byte <draw_buckets2_b  ; buckets2_5
                .byte <draw_buckets2_b  ; buckets2_6
                .byte 0
                .byte <draw_buckets3_a  ; buckets3_0
                .byte <draw_buckets3_a  ; buckets3_1
                .byte <draw_buckets3_a  ; buckets3_2
                .byte <draw_buckets3_a  ; buckets3_3
                .byte <draw_buckets3_a  ; buckets3_4
                .byte <draw_buckets3_b  ; buckets3_5
                .byte <draw_buckets3_b  ; buckets3_6
;               .byte 0

bucket_procs_hi .byte >draw_buckets1_a  ; buckets1_0
                .byte >draw_buckets1_a  ; buckets1_1
                .byte >draw_buckets1_a  ; buckets1_2
                .byte >draw_buckets1_a  ; buckets1_3
                .byte >draw_buckets1_a  ; buckets1_4
                .byte >draw_buckets1_b  ; buckets1_5
                .byte >draw_buckets1_b  ; buckets1_6
                .byte 0
                .byte >draw_buckets2_a  ; buckets2_0
                .byte >draw_buckets2_a  ; buckets2_1
                .byte >draw_buckets2_a  ; buckets2_2
                .byte >draw_buckets2_a  ; buckets2_3
                .byte >draw_buckets2_a  ; buckets2_4
                .byte >draw_buckets2_b  ; buckets2_5
                .byte >draw_buckets2_b  ; buckets2_6
                .byte 0
                .byte >draw_buckets3_a  ; buckets3_0
                .byte >draw_buckets3_a  ; buckets3_1
                .byte >draw_buckets3_a  ; buckets3_2
                .byte >draw_buckets3_a  ; buckets3_3
                .byte >draw_buckets3_a  ; buckets3_4
                .byte >draw_buckets3_b  ; buckets3_5
                .byte >draw_buckets3_b  ; buckets3_6
;               .byte 0

bucket_offsets  .byte 0*48,1*48,2*48,3*48,4*48,0*48,1*48,0
                .byte 0*48,1*48,2*48,3*48,4*48,0*48,1*48,0
                .byte 0*48,1*48,2*48,3*48,4*48,0*48,1*48,0

draw_buckets3_a buckets3 bucket_set_a
draw_buckets3_b buckets3 bucket_set_b
draw_buckets2_a buckets2 bucket_set_a
draw_buckets2_b buckets2 bucket_set_b
draw_buckets1_a buckets1 bucket_set_a
draw_buckets1_b buckets1 bucket_set_b

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
bucket_set_a
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
bucket_set_b
splash_set_a    ; *** split/move this ***
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
