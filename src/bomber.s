;
; On entry:
;   A: X position (0-139)
;
;   draw at X * 2
;
draw_bomber     asl
                tax
                ldy div7,x
                lda mod7,x
                lsr
                tax
                lda draw_bombers_lo,x
                sta @mod+1
                lda draw_bombers_hi,x
                sta @mod+2
                lda #0
                ror
                tax                     ; data offset = 0 or 128
                tya
;               clc
                adc #3
@mod            jsr $ffff
                lda #$ff
                sta bomberLine7,y       ; clean up artifact by forcing high bit
                rts

draw_bombers_lo .byte <draw_bomber_01
                .byte <draw_bomber_23
                .byte <draw_bomber_45
                .byte <draw_bomber_6

draw_bombers_hi .byte >draw_bomber_01
                .byte >draw_bomber_23
                .byte >draw_bomber_45
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

draw_bomber_01  bomber bomber_0
draw_bomber_23  bomber bomber_2
draw_bomber_45  bomber bomber_4
draw_bomber_6   bomber bomber_6

erase_bomber    lda bomber_x
                asl
                tax
                ldy div7,x
                ldx #3
                tya
                lsr a
                lda #$2a
                bcc @1
                lda #$55
@1              sta @mod+1
@2              lda #$7f
                sta bomberLine0,y
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

; NOTE: bomber graphics are captured in column order
; NOTE: these are currently just the smiling bomber

                .align 256

bomber_0        .byte $1f,$27,$d3,$29,$03,$31,$00,$aa
                .byte $a9,$ab,$8b,$ab,$a7,$0f,$6f,$07
                .byte $7b,$01,$7e,$00,$6e,$00,$6e,$00
                .byte $6e,$00,$6e,$00,$20,$02,$78,$65
                .byte $ca,$15,$40,$0c,$00,$d5,$94,$d5
                .byte $d1,$d4,$e5,$70,$77,$60,$5f,$00
                .byte $7f,$00,$77,$00,$77,$00,$77,$00
                .byte $77,$00,$05,$41,$7f,$7f,$ff,$7f
                .byte $7f,$7f,$7e,$fe,$ff,$ff,$ff,$ff
                .byte $ff,$7f,$7f,$7f,$7f,$7f,$7e,$7e
                .byte $7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
                .byte $2a,$2a

                .align 128

bomber_1        .byte $3f,$4f,$a7,$53,$07,$63,$01,$d5
                .byte $d3,$d7,$97,$d7,$cf,$1f,$5f,$0f
                .byte $77,$03,$7d,$01,$5d,$01,$5d,$01
                .byte $5d,$01,$5d,$01,$41,$05,$70,$4a
                .byte $95,$2a,$00,$18,$00,$aa,$a8,$aa
                .byte $a2,$a8,$ca,$60,$6f,$40,$3f,$00
                .byte $7f,$00,$6f,$00,$6f,$00,$6f,$00
                .byte $6f,$00,$0a,$02,$7f,$7f,$ff,$7e
                .byte $7f,$7e,$7c,$fd,$fe,$ff,$ff,$ff
                .byte $ff,$7f,$7f,$7f,$7f,$7e,$7d,$7c
                .byte $7d,$7c,$7d,$7c,$7d,$7c,$7d,$7c
                .byte $54,$55

                .align 128

bomber_2        .byte $7f,$1f,$cf,$27,$0f,$47,$03,$ab
                .byte $a7,$af,$af,$af,$9f,$3f,$3f,$1f
                .byte $6f,$07,$7b,$03,$3b,$03,$3b,$03
                .byte $3b,$03,$3b,$03,$02,$0a,$60,$15
                .byte $aa,$55,$00,$31,$00,$d5,$d1,$d5
                .byte $c4,$d1,$95,$40,$5f,$00,$7f,$00
                .byte $7f,$00,$5f,$00,$5f,$00,$5f,$00
                .byte $5f,$00,$15,$04,$7f,$7f,$fe,$7c
                .byte $7e,$7c,$78,$fa,$fc,$fe,$fe,$fe
                .byte $ff,$7f,$7f,$7f,$7e,$7c,$7b,$78
                .byte $7b,$78,$7b,$78,$7b,$78,$7b,$78
                .byte $28,$2a

                .align 128

bomber_3        .byte $7f,$3f,$9f,$4f,$1f,$0f,$07,$d7
                .byte $cf,$df,$df,$df,$bf,$7f,$7f,$3f
                .byte $5f,$0f,$77,$07,$77,$07,$77,$07
                .byte $77,$07,$77,$07,$05,$15,$41,$2a
                .byte $d5,$2a,$00,$63,$00,$aa,$a2,$aa
                .byte $88,$a2,$aa,$00,$3e,$00,$7f,$00
                .byte $7f,$00,$3e,$00,$3e,$00,$3e,$00
                .byte $3e,$00,$2a,$08,$7f,$7e,$fc,$79
                .byte $7c,$78,$70,$f5,$f9,$fd,$fd,$fd
                .byte $fe,$7f,$7f,$7e,$7d,$78,$77,$70
                .byte $77,$70,$77,$70,$77,$70,$77,$70
                .byte $50,$54

                .align 128

bomber_4        .byte $7f,$7f,$bf,$1f,$3f,$1f,$0f,$af
                .byte $9f,$bf,$bf,$bf,$ff,$7f,$7f,$7f
                .byte $3f,$1f,$6f,$0f,$6f,$0f,$6f,$0f
                .byte $6f,$0f,$6f,$0f,$0a,$2a,$03,$54
                .byte $aa,$55,$00,$46,$00,$d5,$c5,$d5
                .byte $91,$c5,$d4,$01,$7d,$00,$7f,$00
                .byte $7f,$00,$7d,$00,$7d,$00,$7d,$00
                .byte $7d,$00,$54,$10,$7f,$7c,$f9,$72
                .byte $78,$71,$60,$ea,$f2,$fa,$fa,$fa
                .byte $fc,$7e,$7e,$7c,$7b,$70,$6f,$60
                .byte $6e,$60,$6e,$60,$6e,$60,$6e,$60
                .byte $20,$28

                .align 128

bomber_5        .byte $7f,$7f,$ff,$3f,$7f,$3f,$1f,$df
                .byte $bf,$ff,$ff,$ff,$ff,$7f,$7f,$7f
                .byte $7f,$3f,$5f,$1f,$5f,$1f,$5f,$1f
                .byte $5f,$1f,$5f,$1f,$15,$55,$07,$29
                .byte $d4,$2a,$00,$0c,$00,$aa,$8a,$aa
                .byte $a2,$8a,$a9,$03,$7b,$01,$7e,$00
                .byte $7f,$00,$7b,$00,$7b,$00,$7b,$00
                .byte $7b,$00,$28,$20,$7e,$79,$f2,$65
                .byte $70,$63,$40,$d5,$e5,$f5,$f4,$f5
                .byte $f9,$7c,$7d,$78,$77,$60,$5f,$40
                .byte $5d,$40,$5d,$40,$5d,$40,$5d,$40
                .byte $41,$50

                .align 128

bomber_6        .byte $7f,$7f,$ff,$7f,$7f,$7f,$3f,$bf
                .byte $ff,$ff,$ff,$ff,$ff,$7f,$7f,$7f
                .byte $7f,$7f,$3f,$3f,$3f,$3f,$3f,$3f
                .byte $3f,$3f,$3f,$3f,$2a,$2a,$0f,$53
                .byte $a9,$54,$01,$18,$00,$d5,$94,$d5
                .byte $c5,$95,$d3,$07,$77,$03,$7d,$00
                .byte $7f,$00,$77,$00,$77,$00,$77,$00
                .byte $77,$00,$50,$41,$7c,$72,$e5,$4a
                .byte $60,$46,$00,$aa,$ca,$ea,$e8,$ea
                .byte $f2,$78,$7b,$70,$6f,$40,$3f,$00
                .byte $3b,$00,$3b,$00,$3b,$00,$3b,$00
                .byte $02,$20

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
