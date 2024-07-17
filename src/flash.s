
; NOTE: This may seem like overkill for just a screen flash
;   but I really wanted to approximate the speed of the original
;   flash and not watch the screen slowly paint from top to bottom.
;   Good thing I'm not limited to a 2K cartridge!

;---------------------------------------

; 5680 bytes for center area (142 * 40)
; 5 cycles per sta $9999,x
; 28400 cycles for complete fill

; 8 line by 40 column bucket line fill
; 18 chunks of 8 (6) lines
;
; 8 line by 40 column fill
; 40 * 47 = 1880 cycles

left            =   temp
right           =   offset
eor_value       =   linenum

; NOTE: exp_bomb_frame decreases from $1E down to $01

flash_screen    ldx bucket_xcol
                txa
                and #$fe
                sta left
                txa
                sec                     ; +1
                adc #6
                and #$fe
                cmp #40
                bcc @1
                lda #40
@1              sta right
                dec right

                lda exp_bomb_frame
                tax
                sec
                sbc #1
@2              tay
                sbc #12
                bcs @2
                lda flash_eor,y
                cpx #$1C
                bcc @3
                lda #$ff
@3              sta eor_value
                lda flash_color,y
                ldx flash_phase,y
                dex
                beq flash_phase1
                bpl flash_phase2

flash_phase0    jsr flash_40
                jsr flash_64
                jsr flash_88
                jsr flash_112
                jsr flash_136
                jmp flash_middle_bucket_157

flash_phase1    jsr flash_48
                jsr flash_72
                jsr flash_96
                jsr flash_120
                jsr flash_top_bucket_141
                jmp flash_165

flash_phase2    jsr flash_56
                jsr flash_80
                jsr flash_104
                jsr flash_128
                jsr flash_149
                jmp flash_bottom_bucket_173

; TODO: add whites to cycle
flash_color     .byte $2a,$2a,$2a
                .byte $d5,$d5,$d5
                .byte $55,$55,$55
                .byte $aa,$aa,$aa

flash_eor       .byte $ff,$ff,$ff
                .byte $80,$80,$80
                .byte $ff,$ff,$ff
                .byte $80,$80,$80

flash_phase     .byte 2,1,0
                .byte 2,1,0
                .byte 2,1,0
                .byte 2,1,0

flash_40        ldy #39
@1              eor #$7f
                sta hiresLine40,y
                sta hiresLine41,y
                sta hiresLine42,y
                sta hiresLine43,y
                sta hiresLine44,y
                sta hiresLine45,y
                sta hiresLine46,y
                sta hiresLine47,y
                dey
                bpl @1
                rts

flash_48        ldy #39
@1              eor #$7f
                sta hiresLine48,y
                sta hiresLine49,y
                sta hiresLine50,y
                sta hiresLine51,y
                sta hiresLine52,y
                sta hiresLine53,y
                sta hiresLine54,y
                sta hiresLine55,y
                dey
                bpl @1
                rts

flash_56        ldy #39
@1              eor #$7f
                sta hiresLine56,y
                sta hiresLine57,y
                sta hiresLine58,y
                sta hiresLine59,y
                sta hiresLine60,y
                sta hiresLine61,y
                sta hiresLine62,y
                sta hiresLine63,y
                dey
                bpl @1
                rts

flash_64        ldy #39
@1              eor #$7f
                sta hiresLine64,y
                sta hiresLine65,y
                sta hiresLine66,y
                sta hiresLine67,y
                sta hiresLine68,y
                sta hiresLine69,y
                sta hiresLine70,y
                sta hiresLine71,y
                dey
                bpl @1
                rts

flash_72        ldy #39
@1              eor #$7f
                sta hiresLine72,y
                sta hiresLine73,y
                sta hiresLine74,y
                sta hiresLine75,y
                sta hiresLine76,y
                sta hiresLine77,y
                sta hiresLine78,y
                sta hiresLine79,y
                dey
                bpl @1
                rts

flash_80        ldy #39
@1              eor #$7f
                sta hiresLine80,y
                sta hiresLine81,y
                sta hiresLine82,y
                sta hiresLine83,y
                sta hiresLine84,y
                sta hiresLine85,y
                sta hiresLine86,y
                sta hiresLine87,y
                dey
                bpl @1
                rts

flash_88        ldy #39
@1              eor #$7f
                sta hiresLine88,y
                sta hiresLine89,y
                sta hiresLine90,y
                sta hiresLine91,y
                sta hiresLine92,y
                sta hiresLine93,y
                sta hiresLine94,y
                sta hiresLine95,y
                dey
                bpl @1
                rts

flash_96        ldy #39
@1              eor #$7f
                sta hiresLine96,y
                sta hiresLine97,y
                sta hiresLine98,y
                sta hiresLine99,y
                sta hiresLine100,y
                sta hiresLine101,y
                sta hiresLine102,y
                sta hiresLine103,y
                dey
                bpl @1
                rts

flash_104       ldy #39
@1              eor #$7f
                sta hiresLine104,y
                sta hiresLine105,y
                sta hiresLine106,y
                sta hiresLine107,y
                sta hiresLine108,y
                sta hiresLine109,y
                sta hiresLine110,y
                sta hiresLine111,y
                dey
                bpl @1
                rts

flash_112       ldy #39
@1              eor #$7f
                sta hiresLine112,y
                sta hiresLine113,y
                sta hiresLine114,y
                sta hiresLine115,y
                sta hiresLine116,y
                sta hiresLine117,y
                sta hiresLine118,y
                sta hiresLine119,y
                dey
                bpl @1
                rts

flash_120       ldy #39
@1              eor #$7f
                sta hiresLine120,y
                sta hiresLine121,y
                sta hiresLine122,y
                sta hiresLine123,y
                sta hiresLine124,y
                sta hiresLine125,y
                sta hiresLine126,y
                sta hiresLine127,y
                dey
                bpl @1
                rts

flash_128       ldy #39
@1              eor #$7f
                sta hiresLine128,y
                sta hiresLine129,y
                sta hiresLine130,y
                sta hiresLine131,y
                sta hiresLine132,y
                sta hiresLine133,y
                sta hiresLine134,y
                sta hiresLine135,y
                dey
                bpl @1
                rts

flash_136       ldy #39
@1              eor #$7f
                sta hiresLine136,y      ; 5 lines
                sta hiresLine137,y
                sta hiresLine138,y
                sta hiresLine139,y
                sta hiresLine140,y
                ;
                sta hiresLine181,y      ; 1 line
                dey
                bpl @1
                rts

flash_149       ldy #39
@1              eor #$7f
                sta hiresLine149,y
                sta hiresLine150,y
                sta hiresLine151,y
                sta hiresLine152,y
                sta hiresLine153,y
                sta hiresLine154,y
                sta hiresLine155,y
                sta hiresLine156,y
                dey
                bpl @1
                rts

flash_165       ldy #39
@1              eor #$7f
                sta hiresLine165,y
                sta hiresLine166,y
                sta hiresLine167,y
                sta hiresLine168,y
                sta hiresLine169,y
                sta hiresLine170,y
                sta hiresLine171,y
                sta hiresLine172,y
                dey
                bpl @1
                rts

flash_top_bucket_141
                ldy #39
                cpy right
                beq @2
@1              eor #$7f
                sta hiresLine141,y
                sta hiresLine142,y
                sta hiresLine143,y
                sta hiresLine144,y
                sta hiresLine145,y
                sta hiresLine146,y
                sta hiresLine147,y
                sta hiresLine148,y
                dey
                bmi @5
                cpy right
                bne @1
@2              tax
@3              lda eor_value
                eor hiresLine141,y
                sta hiresLine141,y
                lda eor_value
                eor hiresLine142,y
                sta hiresLine142,y
                lda eor_value
                eor hiresLine143,y
                sta hiresLine143,y
                lda eor_value
                eor hiresLine144,y
                sta hiresLine144,y
                lda eor_value
                eor hiresLine145,y
                sta hiresLine145,y
                lda eor_value
                eor hiresLine146,y
                sta hiresLine146,y
                lda eor_value
                eor hiresLine147,y
                sta hiresLine147,y
                lda eor_value
                eor hiresLine148,y
                sta hiresLine148,y
                dey
                bmi @4
                cpy left
                bcs @3
                txa
                bne @1                  ; always
@4              txa
@5              rts

flash_middle_bucket_157
                ldy #39
                cpy right
                beq @2
@1              eor #$7f
                sta hiresLine157,y
                sta hiresLine158,y
                sta hiresLine159,y
                sta hiresLine160,y
                sta hiresLine161,y
                sta hiresLine162,y
                sta hiresLine163,y
                sta hiresLine164,y
                dey
                bmi @5
                cpy right
                bne @1
@2              ldx bucket_count
                cpx #2
                bcc @1
                tax
@3              lda eor_value
                eor hiresLine157,y
                sta hiresLine157,y
                lda eor_value
                eor hiresLine158,y
                sta hiresLine158,y
                lda eor_value
                eor hiresLine159,y
                sta hiresLine159,y
                lda eor_value
                eor hiresLine160,y
                sta hiresLine160,y
                lda eor_value
                eor hiresLine161,y
                sta hiresLine161,y
                lda eor_value
                eor hiresLine162,y
                sta hiresLine162,y
                lda eor_value
                eor hiresLine163,y
                sta hiresLine163,y
                lda eor_value
                eor hiresLine164,y
                sta hiresLine164,y
                dey
                bmi @4
                cpy left
                bcs @3
                txa
                bne @1                  ; always
@4              txa
@5              rts

flash_bottom_bucket_173
                ldy #39
                cpy right
                beq @2
@1              eor #$7f
                sta hiresLine173,y
                sta hiresLine174,y
                sta hiresLine175,y
                sta hiresLine176,y
                sta hiresLine177,y
                sta hiresLine178,y
                sta hiresLine179,y
                sta hiresLine180,y
                dey
                bmi @5
                cpy right
                bne @1
@2              ldx bucket_count
                cpx #3
                bcc @1
                tax
@3              lda eor_value
                eor hiresLine173,y
                sta hiresLine173,y
                lda eor_value
                eor hiresLine174,y
                sta hiresLine174,y
                lda eor_value
                eor hiresLine175,y
                sta hiresLine175,y
                lda eor_value
                eor hiresLine176,y
                sta hiresLine176,y
                lda eor_value
                eor hiresLine177,y
                sta hiresLine177,y
                lda eor_value
                eor hiresLine178,y
                sta hiresLine178,y
                lda eor_value
                eor hiresLine179,y
                sta hiresLine179,y
                lda eor_value
                eor hiresLine180,y
                sta hiresLine180,y
                dey
                bmi @4
                cpy left
                bcs @3
                txa
                bne @1                  ; always
@4              txa
@5              rts
