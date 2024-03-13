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

; TODO:reduce erase overdraw of higher waves
;   in order to get some cycles back for earlier waves

; TODO: figure out how to consume cycles for
;   columns not erased on left/right edges

; 2017 cycles, with 3 erase columns

move_bomber_left
                jsr get_bomber_x
                sty temp_xcol
                ; stx temp_xshift
                jsr draw_bomber
                ; compute columns to erase
                lda temp_xcol
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
; TODO: reduce erase columns for earlier waves to get cycles back

move_bomber_right
                jsr get_bomber_x
                sty temp_xcol
                stx temp_xshift
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
@3              ldy temp_xcol
                ldx temp_xshift

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

bomberLine0     :=  hiresLine12
bomberLine1     :=  hiresLine13
bomberLine2     :=  hiresLine14
bomberLine3     :=  hiresLine15
bomberLine4     :=  hiresLine16
bomberLine5     :=  hiresLine17
bomberLine6     :=  hiresLine18
bomberLine7     :=  hiresLine19
bomberLine8     :=  hiresLine20
bomberLine9     :=  hiresLine21
bomberLine10    :=  hiresLine22
bomberLine11    :=  hiresLine23
bomberLine12    :=  hiresLine24
bomberLine13    :=  hiresLine25
bomberLine14    :=  hiresLine26
bomberLine15    :=  hiresLine27
bomberLine16    :=  hiresLine28
bomberLine17    :=  hiresLine29
bomberLine18    :=  hiresLine30
bomberLine19    :=  hiresLine31
bomberLine20    :=  hiresLine32
bomberLine21    :=  hiresLine33
bomberLine22    :=  hiresLine34
bomberLine23    :=  hiresLine35
bomberLine24    :=  hiresLine36
bomberLine25    :=  hiresLine37
bomberLine26    :=  hiresLine38
bomberLine27    :=  hiresLine39
bomberLine28    :=  hiresLine40
bomberLine29    :=  hiresLine41

; TODO (RPW65): parse macro args and
;   ignore them in the macro body
.macro bomber bits
                sta @mod+1
                ldx #0                  ; data offset
@1              lda bits,x
                sta bomberLine0,y
                inx
                lda bits,x
                sta bomberLine1,y
                inx
                lda bits,x
                sta bomberLine2,y
                inx
                lda bits,x
                sta bomberLine3,y
                inx
                lda bits,x
                sta bomberLine4,y
                inx
                lda bits,x
                sta bomberLine5,y
                inx
                lda bits,x
                sta bomberLine6,y
                inx
                lda bits,x
                sta bomberLine7,y
                inx
                lda bits,x
                sta bomberLine8,y
                inx
                lda bits,x
                sta bomberLine9,y
                inx
                lda bits,x
                sta bomberLine10,y
                inx
                lda bits,x
                sta bomberLine11,y
                inx
                lda bits,x
                sta bomberLine12,y
                inx
                lda bits,x
                sta bomberLine13,y
                inx
                lda bits,x
                sta bomberLine14,y
                inx
                lda bits,x
                sta bomberLine15,y
                inx
                lda bits,x
                sta bomberLine16,y
                inx
                lda bits,x
                sta bomberLine17,y
                inx
                lda bits,x
                sta bomberLine18,y
                inx
                lda bits,x
                sta bomberLine19,y
                inx
                lda bits,x
                sta bomberLine20,y
                inx
                lda bits,x
                sta bomberLine21,y
                inx
                lda bits,x
                sta bomberLine22,y
                inx
                lda bits,x
                sta bomberLine23,y
                inx
                lda bits,x
                sta bomberLine24,y
                inx
                lda bits,x
                sta bomberLine25,y
                inx
                lda bits,x
                sta bomberLine26,y
                inx
                lda bits,x
                sta bomberLine27,y
                inx
                lda bits,x
                sta bomberLine28,y
                inx
                lda bits,x
                sta bomberLine29,y
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
@3              sta bomberLine0,y
                sta bomberLine1,y
                sta bomberLine2,y
                sta bomberLine3,y
                sta bomberLine4,y
                sta bomberLine5,y
                sta bomberLine6,y
                sta bomberLine7,y
                sta bomberLine8,y
                sta bomberLine9,y
                sta bomberLine10,y
                sta bomberLine11,y
                sta bomberLine12,y
                sta bomberLine13,y
                sta bomberLine14,y
                sta bomberLine15,y
                sta bomberLine16,y
                sta bomberLine17,y
                sta bomberLine18,y
                sta bomberLine19,y
                sta bomberLine20,y
                sta bomberLine21,y
                sta bomberLine22,y
                sta bomberLine23,y
                sta bomberLine24,y
                sta bomberLine25,y
                sta bomberLine26,y
                sta bomberLine27,y
@mod            lda #$ff
                sta bomberLine28,y
                sta bomberLine29,y
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
                .byte $4e,$00,$4e,$00,$41,$05,$40,$2a
                .byte $d5,$2a,$00,$31,$00,$aa,$a0,$aa
                .byte $8a,$a0,$aa,$00,$7f,$00,$7f,$00
                .byte $7f,$00,$3f,$00,$3f,$00,$3f,$00
                .byte $3f,$00,$2a,$0a,$7f,$7e,$fc,$79
                .byte $7c,$78,$70,$f5,$f9,$fd,$fd,$fd
                .byte $fe,$7f,$7e,$7c,$7b,$70,$6f,$60
                .byte $6e,$60,$6e,$60,$6e,$60,$6e,$60
                .byte $50,$54,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$2a,$2a

                .align 128

bomber_1        .byte $7f,$1f,$cf,$27,$0f,$07,$03,$ab
                .byte $a7,$af,$af,$af,$9f,$bf,$5f,$0f
                .byte $77,$03,$7d,$01,$1d,$01,$1d,$01
                .byte $1d,$01,$1d,$01,$02,$0a,$00,$55
                .byte $aa,$55,$00,$63,$00,$d5,$c1,$d5
                .byte $94,$c1,$d5,$00,$7f,$00,$7f,$00
                .byte $7f,$00,$7f,$00,$7f,$00,$7f,$00
                .byte $7f,$00,$55,$14,$7f,$7c,$f9,$72
                .byte $78,$70,$60,$ea,$f2,$fa,$fa,$fa
                .byte $fc,$fe,$7d,$78,$77,$60,$5f,$40
                .byte $5c,$40,$5c,$40,$5c,$40,$5c,$40
                .byte $20,$28,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$55,$55

                .align 128

bomber_2        .byte $7f,$3f,$9f,$4f,$1f,$0f,$07,$d7
                .byte $cf,$df,$df,$df,$bf,$ff,$3f,$1f
                .byte $6f,$07,$7b,$03,$3b,$03,$3b,$03
                .byte $3b,$03,$3b,$03,$05,$15,$01,$2a
                .byte $d5,$2a,$00,$46,$00,$aa,$82,$aa
                .byte $a8,$82,$aa,$80,$7f,$00,$7f,$00
                .byte $7f,$00,$7e,$00,$7e,$00,$7e,$00
                .byte $7e,$00,$2a,$28,$7e,$79,$f2,$65
                .byte $70,$61,$40,$d5,$e5,$f5,$f4,$f5
                .byte $f9,$fc,$7b,$70,$6f,$40,$3f,$00
                .byte $39,$00,$39,$00,$39,$00,$39,$00
                .byte $41,$50,$7f,$7f,$ff,$7f,$7f,$7f
                .byte $7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$2a,$2a

                .align 128

bomber_3        .byte $7f,$7f,$3f,$1f,$3f,$1f,$0f,$af
                .byte $9f,$bf,$bf,$bf,$ff,$ff,$7f,$3f
                .byte $5f,$0f,$77,$07,$77,$07,$77,$07
                .byte $77,$07,$77,$07,$0a,$2a,$03,$54
                .byte $aa,$55,$00,$0c,$00,$d5,$85,$d5
                .byte $d1,$85,$d4,$01,$7e,$00,$7f,$00
                .byte $7f,$00,$7c,$00,$7c,$00,$7c,$00
                .byte $7c,$00,$54,$50,$7c,$72,$e5,$4a
                .byte $60,$43,$00,$aa,$ca,$ea,$e8,$ea
                .byte $f2,$78,$77,$60,$5f,$00,$7f,$00
                .byte $73,$00,$73,$00,$73,$00,$73,$00
                .byte $02,$20,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7f,$7e,$7e,$7e,$7e
                .byte $7e,$7e,$7e,$7e,$7e,$7e,$55,$55

                .align 128

bomber_4        .byte $7f,$7f,$ff,$3f,$7f,$3f,$1f,$df
                .byte $bf,$ff,$ff,$ff,$ff,$ff,$7f,$7f
                .byte $3f,$1f,$6f,$0f,$6f,$0f,$6f,$0f
                .byte $6f,$0f,$6f,$0f,$15,$55,$07,$29
                .byte $d4,$2a,$00,$18,$00,$aa,$8a,$aa
                .byte $a2,$8a,$a9,$03,$7d,$00,$7f,$00
                .byte $7f,$00,$79,$00,$79,$00,$79,$00
                .byte $79,$00,$28,$20,$78,$65,$ca,$15
                .byte $40,$06,$00,$d5,$94,$d5,$d1,$d4
                .byte $e5,$70,$6f,$40,$3f,$00,$7f,$00
                .byte $67,$00,$67,$00,$67,$00,$67,$00
                .byte $05,$41,$7f,$7f,$ff,$7f,$7f,$7f
                .byte $7e,$fe,$ff,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7f,$7e,$7d,$7c,$7d,$7c
                .byte $7d,$7c,$7d,$7c,$7d,$7c,$2a,$2a

                .align 128

bomber_5        .byte $7f,$7f,$ff,$7f,$7f,$7f,$3f,$bf
                .byte $ff,$ff,$ff,$ff,$ff,$ff,$7f,$7f
                .byte $7f,$3f,$5f,$1f,$5f,$1f,$5f,$1f
                .byte $5f,$1f,$5f,$1f,$2a,$2a,$0f,$53
                .byte $a9,$54,$01,$30,$00,$d5,$94,$d5
                .byte $c5,$95,$d3,$07,$7b,$01,$7e,$00
                .byte $7f,$00,$73,$00,$73,$00,$73,$00
                .byte $73,$00,$50,$41,$70,$4a,$95,$2a
                .byte $00,$0c,$00,$aa,$a8,$aa,$a2,$a8
                .byte $ca,$60,$5f,$00,$7f,$00,$7f,$00
                .byte $4f,$00,$4f,$00,$4f,$00,$4f,$00
                .byte $0a,$02,$7f,$7f,$ff,$7e,$7f,$7e
                .byte $7c,$fd,$fe,$ff,$ff,$ff,$ff,$ff
                .byte $7f,$7f,$7e,$7c,$7b,$78,$7b,$78
                .byte $7b,$78,$7b,$78,$7b,$78,$54,$55

                .align 128

bomber_6        .byte $7f,$7f,$ff,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
                .byte $7f,$7f,$3f,$3f,$3f,$3f,$3f,$3f
                .byte $3f,$3f,$3f,$3f,$55,$55,$1f,$27
                .byte $d3,$29,$03,$61,$00,$aa,$a9,$ab
                .byte $8b,$ab,$a7,$0f,$77,$03,$7d,$00
                .byte $7f,$00,$67,$00,$67,$00,$67,$00
                .byte $67,$00,$20,$02,$60,$15,$aa,$55
                .byte $00,$18,$00,$d5,$d0,$d5,$c5,$d0
                .byte $95,$40,$3f,$00,$7f,$00,$7f,$00
                .byte $1f,$00,$1f,$00,$1f,$00,$1f,$00
                .byte $15,$05,$7f,$7f,$fe,$7c,$7e,$7c
                .byte $78,$fa,$fc,$fe,$fe,$fe,$ff,$ff
                .byte $7f,$7e,$7d,$78,$77,$70,$77,$70
                .byte $77,$70,$77,$70,$77,$70,$28,$2a

                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %########....####....########....
                ; .byte %############################....
                ; .byte %############....############....
                ; .byte %....########....########........
                ; .byte %....####################........
                ; .byte %....####....####....####........
                ; .byte %....########....########........
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %############################....
                ; .byte %############################....
                ; .byte %############################....
                ; .byte %############################....
                ; .byte %############################....
                ; .byte %####....############....####....
                ; .byte %########....####....########....
                ; .byte %####....############....####....
                ; .byte %########....####....########....
                ; .byte %####....############....####....
                ; .byte %########....####....########....
                ; .byte %####....############....####....
                ; .byte %####....................####....
                ; .byte %####....................####....
                ; .byte %....####............####........
                ; .byte %................................
                ; .byte %................................
