;
; On entry:
;   A: X position (0-139) *** minus width?
;
;   draw at X * 2 + 1
;
; 1413 cycles (plus any erase columns added)
;   down from 2500 in simple implementation
; 1644 cycles with one erase column
; DX of 1 to 8 (of 160)
;

; TODO: figure out how to consume cycles for
;   columns not erased on left/right edges

; 2017 cycles, with 3 erase columns

move_bomber_left
                jsr get_bomber_x
                sty hold_col
                ; stx hold_shift
                jsr draw_bomber
                ; compute columns to erase
                lda hold_col
                clc
                adc #4
                tay
                ldx #0
@1              cpy #40
                beq @2
                iny
                inx
                cpx #3
                bne @1
@2              tay
                txa
                beq @3
                jmp erase_bomber_cols
@3              rts

; 2012 cycles, with 3 erase columns

move_bomber_right
                jsr get_bomber_x
                sty hold_col
                stx hold_shift
                ; compute columns to erase
                ldx #0
@1              tya
                beq @2
                dey
                inx
                cpx #3
                bne @1
@2              txa
                beq @3
                jsr erase_bomber_cols
@3              ldy hold_col
                ldx hold_shift

                ; fall through

draw_bomber     lda draw_bombers_lo,x
                sta @mod+1
                lda draw_bombers_hi,x
                sta @mod+2
                tya
                clc
                adc #4                  ;*** clip right edge?
                                        ;*** or assume clamping?
@mod            jmp $ffff
;
; On entry:
;   A: X position (0-139) *** capped
;
;   draw at X * 2 + 1
;
; On exit:
;   X: position mod 7
;   Y: position div 7
;
get_bomber_x    sec
                rol a
                tax
                ldy div7,x
                lda mod7,x
                tax
                rts

draw_bombers_lo .byte <draw_bomber_0
                .byte <draw_bomber_1
                .byte <draw_bomber_2
                .byte <draw_bomber_3
                .byte <draw_bomber_4
                .byte <draw_bomber_5
                .byte <draw_bomber_6

draw_bombers_hi .byte >draw_bomber_0
                .byte >draw_bomber_1
                .byte >draw_bomber_2
                .byte >draw_bomber_3
                .byte >draw_bomber_4
                .byte >draw_bomber_5
                .byte >draw_bomber_6

bomber_line0        :=  $3880           ;14
bomber_line1        :=  $3C80
bomber_line2        :=  $2100           ;16
bomber_line3        :=  $2500
bomber_line4        :=  $2900
bomber_line5        :=  $2D00
bomber_line6        :=  $3100
bomber_line7        :=  $3500
bomber_line8        :=  $3900
bomber_line9        :=  $3D00
bomber_line10       :=  $2180           ;24
bomber_line11       :=  $2580
bomber_line12       :=  $2980
bomber_line13       :=  $2D80
bomber_line14       :=  $3180
bomber_line15       :=  $3580
bomber_line16       :=  $3980
bomber_line17       :=  $3D80
bomber_line18       :=  $2200           ;32
bomber_line19       :=  $2600
bomber_line20       :=  $2A00
bomber_line21       :=  $2E00
bomber_line22       :=  $3200
bomber_line23       :=  $3600
bomber_line24       :=  $3A00
bomber_line25       :=  $3E00
bomber_line26       :=  $2280           ;40
bomber_line27       :=  $2680
bomber_line28       :=  $2A80
bomber_line29       :=  $2E80

; TODO (RPW65): parse macro args and
;   ignore them in the macro body
.macro bomber bits
                sta @mod+1
                ldx #0                  ; data offset
@1              lda bits,x
                sta bomber_line0,y
                inx
                lda bits,x
                sta bomber_line1,y
                inx
                lda bits,x
                sta bomber_line2,y
                inx
                lda bits,x
                sta bomber_line3,y
                inx
                lda bits,x
                sta bomber_line4,y
                inx
                lda bits,x
                sta bomber_line5,y
                inx
                lda bits,x
                sta bomber_line6,y
                inx
                lda bits,x
                sta bomber_line7,y
                inx
                lda bits,x
                sta bomber_line8,y
                inx
                lda bits,x
                sta bomber_line9,y
                inx
                lda bits,x
                sta bomber_line10,y
                inx
                lda bits,x
                sta bomber_line11,y
                inx
                lda bits,x
                sta bomber_line12,y
                inx
                lda bits,x
                sta bomber_line13,y
                inx
                lda bits,x
                sta bomber_line14,y
                inx
                lda bits,x
                sta bomber_line15,y
                inx
                lda bits,x
                sta bomber_line16,y
                inx
                lda bits,x
                sta bomber_line17,y
                inx
                lda bits,x
                sta bomber_line18,y
                inx
                lda bits,x
                sta bomber_line19,y
                inx
                lda bits,x
                sta bomber_line20,y
                inx
                lda bits,x
                sta bomber_line21,y
                inx
                lda bits,x
                sta bomber_line22,y
                inx
                lda bits,x
                sta bomber_line23,y
                inx
                lda bits,x
                sta bomber_line24,y
                inx
                lda bits,x
                sta bomber_line25,y
                inx
                lda bits,x
                sta bomber_line26,y
                inx
                lda bits,x
                sta bomber_line27,y
                inx
                lda bits,x
                sta bomber_line28,y
                inx
                lda bits,x
                sta bomber_line29,y
                inx
                iny
@mod            cpy #$ff
                beq @2
                jmp @1
@2              rts
.endmacro

draw_bomber_0   bomber bomber_0
draw_bomber_1   bomber bomber_1
draw_bomber_2   bomber bomber_2
draw_bomber_3   bomber bomber_3
draw_bomber_4   bomber bomber_4
draw_bomber_5   bomber bomber_5
draw_bomber_6   bomber bomber_6

;
; On entry:
;   Y: screen column
;   X: columns to clear
;
erase_bomber_cols
                tya
                lsr a
                lda #$2a
                bcc @1
                lda #$55
@1              sta @mod+1
                lda #$7e
                cpy #0
                beq @3
@2              lda #$7f
@3              sta bomber_line0,y
                sta bomber_line1,y
                sta bomber_line2,y
                sta bomber_line3,y
                sta bomber_line4,y
                sta bomber_line5,y
                sta bomber_line6,y
                sta bomber_line7,y
                sta bomber_line8,y
                sta bomber_line9,y
                sta bomber_line10,y
                sta bomber_line11,y
                sta bomber_line12,y
                sta bomber_line13,y
                sta bomber_line14,y
                sta bomber_line15,y
                sta bomber_line16,y
                sta bomber_line17,y
                sta bomber_line18,y
                sta bomber_line19,y
                sta bomber_line20,y
                sta bomber_line21,y
                sta bomber_line22,y
                sta bomber_line23,y
                sta bomber_line24,y
                sta bomber_line25,y
                sta bomber_line26,y
@mod            lda #$ff
                sta bomber_line27,y
                sta bomber_line28,y
                sta bomber_line29,y
                eor #$7f
                sta @mod+1
                iny
                dex
                bne @2
                rts

                .align 128

bomber_0        .byte $3f,$4f,$a7,$53,$07,$43,$01,$d5
                .byte $d3,$d7,$97,$d7,$cf,$1f,$6f,$07
                .byte $7b,$01,$7e,$00,$4e,$00,$4e,$00
                .byte $4e,$00,$4e,$41,$45,$15,$40,$2a
                .byte $d5,$2a,$00,$31,$00,$aa,$a0,$aa
                .byte $8a,$a0,$aa,$00,$7f,$00,$7f,$00
                .byte $7f,$00,$3f,$00,$3f,$00,$3f,$00
                .byte $3f,$2a,$2a,$0a,$7f,$7e,$fc,$79
                .byte $7c,$78,$70,$f5,$f9,$fd,$fd,$fd
                .byte $fe,$7f,$7e,$7c,$7b,$70,$6f,$60
                .byte $6e,$60,$6e,$60,$6e,$60,$6e,$50
                .byte $54,$55,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$2a,$2a,$2a

                .align 128

bomber_1        .byte $7f,$1f,$cf,$27,$0f,$07,$03,$ab
                .byte $a7,$af,$af,$af,$9f,$bf,$5f,$0f
                .byte $77,$03,$7d,$01,$1d,$01,$1d,$01
                .byte $1d,$01,$1d,$02,$0a,$2a,$00,$55
                .byte $aa,$55,$00,$63,$00,$d5,$c1,$d5
                .byte $94,$c1,$d5,$00,$7f,$00,$7f,$00
                .byte $7f,$00,$7f,$00,$7f,$00,$7f,$00
                .byte $7f,$55,$55,$14,$7f,$7c,$f9,$72
                .byte $78,$70,$60,$ea,$f2,$fa,$fa,$fa
                .byte $fc,$fe,$7d,$78,$77,$60,$5f,$40
                .byte $5c,$40,$5c,$40,$5c,$40,$5c,$20
                .byte $28,$2a,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$ff,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$55,$55,$55

                .align 128

bomber_2        .byte $7f,$3f,$9f,$4f,$1f,$0f,$07,$d7
                .byte $cf,$df,$df,$df,$bf,$ff,$3f,$1f
                .byte $6f,$07,$7b,$03,$3b,$03,$3b,$03
                .byte $3b,$03,$3b,$05,$15,$55,$01,$2a
                .byte $d5,$2a,$00,$46,$00,$aa,$82,$aa
                .byte $a8,$82,$aa,$80,$7f,$00,$7f,$00
                .byte $7f,$00,$7e,$00,$7e,$00,$7e,$00
                .byte $7e,$2a,$2a,$28,$7e,$79,$f2,$65
                .byte $70,$61,$40,$d5,$e5,$f5,$f4,$f5
                .byte $f9,$fc,$7b,$70,$6f,$40,$3f,$00
                .byte $39,$00,$39,$00,$39,$00,$39,$41
                .byte $51,$54,$7f,$7f,$ff,$7f,$7f,$7f
                .byte $7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$2a,$2a,$2a

                .align 128

bomber_3        .byte $7f,$7f,$3f,$1f,$3f,$1f,$0f,$af
                .byte $9f,$bf,$bf,$bf,$ff,$ff,$7f,$3f
                .byte $5f,$0f,$77,$07,$77,$07,$77,$07
                .byte $77,$07,$77,$0a,$2a,$2a,$03,$54
                .byte $aa,$55,$00,$0c,$00,$d5,$85,$d5
                .byte $d1,$85,$d4,$01,$7e,$00,$7f,$00
                .byte $7f,$00,$7c,$00,$7c,$00,$7c,$00
                .byte $7c,$54,$54,$51,$7c,$72,$e5,$4a
                .byte $60,$43,$00,$aa,$ca,$ea,$e8,$ea
                .byte $f2,$78,$77,$60,$5f,$00,$7f,$00
                .byte $73,$00,$73,$00,$73,$00,$73,$02
                .byte $22,$28,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7f,$7e,$7e,$7e,$7e
                .byte $7e,$7e,$7e,$7e,$7e,$55,$55,$55

                .align 128

bomber_4        .byte $7f,$7f,$ff,$3f,$7f,$3f,$1f,$df
                .byte $bf,$ff,$ff,$ff,$ff,$ff,$7f,$7f
                .byte $3f,$1f,$6f,$0f,$6f,$0f,$6f,$0f
                .byte $6f,$0f,$6f,$15,$55,$55,$07,$29
                .byte $d4,$2a,$00,$18,$00,$aa,$8a,$aa
                .byte $a2,$8a,$a9,$03,$7d,$00,$7f,$00
                .byte $7f,$00,$79,$00,$79,$00,$79,$00
                .byte $79,$28,$28,$22,$78,$65,$ca,$15
                .byte $40,$06,$00,$d5,$94,$d5,$d1,$d4
                .byte $e5,$70,$6f,$40,$3f,$00,$7f,$00
                .byte $67,$00,$67,$00,$67,$00,$67,$05
                .byte $45,$51,$7f,$7f,$ff,$7f,$7f,$7f
                .byte $7e,$fe,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7e,$7d,$7c,$7d,$7c
                .byte $7d,$7c,$7d,$7c,$7d,$2a,$2a,$2a

                .align 128

bomber_5        .byte $7f,$7f,$ff,$7f,$7f,$7f,$3f,$bf
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$7f,$7f
                .byte $7f,$3f,$5f,$1f,$5f,$1f,$5f,$1f
                .byte $5f,$1f,$5f,$2a,$2a,$2a,$0f,$53
                .byte $a9,$54,$01,$30,$00,$d5,$94,$d5
                .byte $c5,$95,$d3,$07,$7b,$01,$7e,$00
                .byte $7f,$00,$73,$00,$73,$00,$73,$00
                .byte $73,$50,$51,$45,$70,$4a,$95,$2a
                .byte $00,$0c,$00,$aa,$a8,$aa,$a2,$a8
                .byte $ca,$60,$5f,$00,$7f,$00,$7f,$00
                .byte $4f,$00,$4f,$00,$4f,$00,$4f,$0a
                .byte $0a,$22,$7f,$7f,$ff,$7e,$7f,$7e
                .byte $7c,$fd,$fe,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7e,$7c,$7b,$78,$7b,$78
                .byte $7b,$78,$7b,$78,$7b,$54,$55,$55

                .align 128

bomber_6        .byte $7f,$7f,$ff,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$3f,$3f,$3f,$3f,$3f,$3f
                .byte $3f,$3f,$3f,$55,$55,$55,$1f,$27
                .byte $d3,$29,$03,$61,$00,$aa,$a9,$ab
                .byte $8b,$ab,$a7,$0f,$77,$03,$7d,$00
                .byte $7f,$00,$67,$00,$67,$00,$67,$00
                .byte $67,$20,$22,$0a,$60,$15,$aa,$55
                .byte $00,$18,$00,$d5,$d0,$d5,$c5,$d0
                .byte $95,$40,$3f,$00,$7f,$00,$7f,$00
                .byte $1f,$00,$1f,$00,$1f,$00,$1f,$15
                .byte $15,$45,$7f,$7f,$fe,$7c,$7e,$7c
                .byte $78,$fa,$fc,$fe,$fe,$fe,$ff,$ff
                .byte $7f,$7e,$7d,$78,$77,$70,$77,$70
                .byte $77,$70,$77,$70,$77,$28,$2a,$2a
