
data_addr_l     =   $50                 ; must be consecutive ->
data_addr_h     =   $51
code_ptr        =   $52
code_ptr_h      =   $53
table_ptr1      =   $54
table_ptr1_h    =   $55
table_ptr2      =   $56
table_ptr2_h    =   $57                 ; <- in this order

table_index     =   $58

draw_bombs      ldy player_wave
                lda wave_bomb_dy,y
                sta bomb_dy

                lda exp_bomb_frame
                beq @1
                jmp explode_bombs

@1              jsr draw_top_bomb

                lda bomb_vphase
                clc
                adc #bombMaxDy
                sec
                sbc bomb_dy
                sta start_line
                clc
                adc #bombPhaseDy
                sta end_line

                ldx #1
@next_bomb      stx bomb_index
                cpx #4
                bcc @no_hit
                bne @4

                jsr erase_buckets

; update bucket position to latest value
;   and compute right edge hit test values
                lda buckets_x
                asl
                tax
                clc
                adc #33
                tay
                lda div7,x
                sta bucket_xcol
                lda mod7,x
                sta bucket_xshift
                bcc @2
                ldx div7_hi,y
                lda mod7_hi,y
                bcs @3                  ; always
@2              ldx div7,y
                lda mod7,y
@3              stx hit_xcol
                sta hit_xshift
@4

; hit test bucket left/right
                ldx bomb_index
                lda bomb_columns,x
                lsr                     ; remove hflip bit
                sta temp
                tay
                iny
                cpy bucket_xcol
                bcc @no_hit
                lda hit_xcol
                cmp temp
                bne @5
; allow a small amount of overlap
                lda hit_xshift
                cmp #3
@5              bcc @no_hit

; hit test bomb against bucket top/bottom
                lda #bombsTop-bombMaxDy
                clc
                adc start_line
;               clc
                adc bomb_dy
                ldy player_buckets
                dey
                cmp bucket_bottoms,y
                bcs @no_hit
;               clc
                adc #14-1
@6              cmp bucket_tops,y
                bcs @7
                dey
                bpl @6
                bmi @no_hit             ; always

@7              ldx bomb_index
                lda bomb_frames,x
                beq @no_hit
                cpy splash_bucket
                beq @8
                lda #0
                sta splash_frame
@8              sty bucket_hit
                stx bomb_hit

@no_hit         jsr draw_bomb

                lda start_line
                clc
                adc #bombPhaseDy
                sta start_line
;               clc
                adc #bombPhaseDy
                sta end_line

                ldx bomb_index
                inx
                cpx #8
                beq @9
                jmp @next_bomb
@9              rts

explode_bombs   lda exp_bomb_index
                bne @1
                lda exp_bomb_frame
                cmp #$20
                bcc @1

; draw top explosion
                lda bomb_vphase
                clc
                adc #bomb0Top
                ldx #0
                jsr draw_explode
                jmp @2

@1              jsr draw_top_bomb
@2
                lda #4
                sta bomb_dy
                lda bomb_vphase
                sta start_line
                clc
                adc #bombPhaseDy
                sta end_line

                ldx #1
@next_bomb      stx bomb_index
                cpx #4
                bne @3
                jsr erase_buckets
                ldx bomb_index
@3              cpx exp_bomb_index
                bne @4

; draw currently exploding bomb
                lda exp_bomb_frame
                cmp #$20
                bcc @5

                lda start_line
                clc
                adc #bombsTop
                jsr draw_explode
                jmp @5

@4              jsr draw_bomb
@5              lda start_line
                clc
                adc #bombPhaseDy
                sta start_line
;               clc
                adc #bombPhaseDy
                sta end_line
                ldx bomb_index
                inx
                cpx #8
                bne @next_bomb
                rts
;
; On entry:
;   A: top line
;   X: bomb index
;
draw_explode    sta linenum
                lda bomb_columns,x
                lsr
                tay
                dey
                sty @mod1+1
                tya
                clc
                adc #4
                sta @mod3+1
                lsr
                lda exp_bomb_frame
                and #$0F
                bcc @1
;               sec
                adc #12-1
@1              asl
                tay
                lda explode_table+0,y
                sta @mod2+1
                lda explode_table+1,y
                sta @mod2+2

                lda #0
                sta offset
                lda linenum
                tax
                clc
                adc #16
                sta @mod4+1
@2              stx linenum
                lda hires_table_lo,x
                sta screenl
                lda hires_table_hi,x
                sta screenh
                ldx offset
@mod1           ldy #$ff
@mod2           lda $ffff,x
                sta (screenl),y
                inx
                iny
@mod3           cpy #$ff
                bne @mod2
                stx offset
                ldx linenum
                inx
                cpx #bombsBottom
                bcs @3
@mod4           cpx #$ff
                bne @2
                same_page_as @2
@3              rts

; NOTE: table_ptr1+0 and table_ptr2+0 are still #$00 from init_bombs
draw_bomb       ldx bomb_index          ; 3
                lda bomb_columns,x      ; 4
                lsr                     ; 2
                sta @mod1+1             ; 4
                rol                     ; 2
                and #$3                 ; 2
                ora #>table_buffer0_lo  ; 2
                sta table_ptr1+1        ; 3
                ora #$04                ; 2
                sta table_ptr2+1        ; 3
                ldy start_line          ; 3
                lda (table_ptr1),y      ; 5
                sta @mod2+1             ; 4
                lda (table_ptr2),y      ; 5
                sta @mod2+2             ; 4
                ldy end_line            ; 3
                lda (table_ptr1),y      ; 5
                sta bomb_ptr            ; 3
                lda (table_ptr2),y      ; 5
                sta bomb_ptr_h          ; 3
                ldy bomb_frames,x       ; 4
                lda bomb_offsets,y      ; 4
                ldy bomb_dy             ; 3
                clc                     ; 2
                adc bomb_dy_offset,y    ; 4
                tax                     ; 2
                ldy #0                  ; 2
                lda #$60                ; 2 rts
                sta (bomb_ptr),y        ; 6
@mod1           ldy #$ff                ; 2
@mod2           jsr $ffff               ; 6 + 6 rts
                ldy #0                  ; 2
                lda #$bd                ; 2 lda $ffff,x
                sta (bomb_ptr),y        ; 6
                rts                     ; 6 = 126 + lines * 20

bucket_tops     .byte bucketTopY
                .byte bucketMidY
                .byte bucketBotY

bucket_bottoms  .byte bucketTopY+bucketHeight
                .byte bucketMidY+bucketHeight
                .byte bucketBotY+bucketHeight

wave_bomb_dy    .byte 1,1,2,2,3,3,4,4

bomb_dy_offset  .byte 8,6,4,2,0         ; 2 bytes per line

; NOTE: offsets valid for even/odd and left/right
bomb_offsets    .byte bomb_lx_even-bombs_l_even
                .byte bomb_l0_even-bombs_l_even
                .byte bomb_l1_even-bombs_l_even
                .byte bomb_l2_even-bombs_l_even
                .byte bomb_l3_even-bombs_l_even

; 12 lines of bomb + 18 phase lines
topBombLine0    :=  hiresLine31
topBombLine1    :=  hiresLine32
topBombLine2    :=  hiresLine33
topBombLine3    :=  hiresLine34
topBombLine4    :=  hiresLine35
topBombLine5    :=  hiresLine36
topBombLine6    :=  hiresLine37
topBombLine7    :=  hiresLine38
topBombLine8    :=  hiresLine39

topBombLine9    :=  hiresLine40
topBombLine10   :=  hiresLine41
topBombLine11   :=  hiresLine42
topBombLine12   :=  hiresLine43
topBombLine13   :=  hiresLine44

topBombLine14   :=  hiresLine45
topBombLine15   :=  hiresLine46
topBombLine16   :=  hiresLine47
topBombLine17   :=  hiresLine48
topBombLine18   :=  hiresLine49
topBombLine19   :=  hiresLine50
topBombLine20   :=  hiresLine51
topBombLine21   :=  hiresLine52
topBombLine22   :=  hiresLine53
topBombLine23   :=  hiresLine54
topBombLine24   :=  hiresLine55
topBombLine25   :=  hiresLine56
topBombLine26   :=  hiresLine57
topBombLine27   :=  hiresLine58
topBombLine28   :=  hiresLine59
topBombLine29   :=  hiresLine60

prev_bomb_phase .byte 0
prev_bomb_col   .byte 0

; NOTE: This takes 270 cycles versus 625
;   cycles for a normal implementation.
erase_top_bomb  lda prev_bomb_col
                beq @4
                ldy prev_bomb_phase
                lda @offsets,y
                sta @mod1+1
                sta @mod3+1
                cpy #9                  ; start with white or green?
                php
                tya
                clc
                adc #12                 ; top bomb minimal height
                tay
                lda @offsets,y
                sta ptr+0
                lda #>@line0
                sta ptr+1
                ldy #0
                lda #$60                ; rts
                sta (ptr),y
                ldy prev_bomb_col
                ldx #$2a
                tya
                lsr
                bcc @2
                ldx #$55
@2              stx @mod0+1
                txa
                eor #$7f
                sta @mod2+1
                plp
                bcs @3                  ; all green?
                lda #$7F
                tax
@3              pha
                txa
@mod0           ldx #$ff
@mod1           jsr @line0
                iny
                pla
@mod2           ldx #$ff
@mod3           jsr @line0
                ldy #0
                lda #$99                ; sta abs,y
                sta (ptr),y
@4              rts

@offsets        .byte <@line0
                .byte <@line1
                .byte <@line2
                .byte <@line3
                .byte <@line4
                .byte <@line5
                .byte <@line6
                .byte <@line7
                .byte <@line8
                .byte <@line9
                .byte <@line10
                .byte <@line11
                .byte <@line12
                .byte <@line13
                .byte <@line14
                .byte <@line15
                .byte <@line16
                .byte <@line17
                .byte <@line18
                .byte <@line19
                .byte <@line20
                .byte <@line21
                .byte <@line22
                .byte <@line23
                .byte <@line24
                .byte <@line25
                .byte <@line26
                .byte <@line27
                .byte <@line28
                .byte <@line29

                .align 256

@line0          sta topBombLine0,y
@line1          sta topBombLine1,y
@line2          sta topBombLine2,y
@line3          sta topBombLine3,y
@line4          sta topBombLine4,y
@line5          sta topBombLine5,y
@line6          sta topBombLine6,y
@line7          sta topBombLine7,y
@line8          sta topBombLine8,y
                txa
@line9          sta topBombLine9,y
@line10         sta topBombLine10,y
@line11         sta topBombLine11,y
@line12         sta topBombLine12,y
@line13         sta topBombLine13,y
@line14         sta topBombLine14,y
@line15         sta topBombLine15,y
@line16         sta topBombLine16,y
@line17         sta topBombLine17,y
@line18         sta topBombLine18,y
@line19         sta topBombLine19,y
@line20         sta topBombLine20,y
@line21         sta topBombLine21,y
@line22         sta topBombLine22,y
@line23         sta topBombLine23,y
@line24         sta topBombLine24,y
@line25         sta topBombLine25,y
@line26         sta topBombLine26,y
@line27         sta topBombLine27,y
@line28         sta topBombLine28,y
@line29         sta topBombLine29,y
                rts

; Drawing top bomb:
;   5 lines of OR
;   7 lines of mask
;   (or 4 lines of mask, 3 lines of copy)
;
draw_top_bomb   lda bomb_columns+0
                lsr
                sta prev_bomb_col
                sta column
                ldy #4                  ; no bomb
                ldx bomb_frames+0
                beq @2
                php
                lsr
                ldy #0                  ; even
                bcc @1
                ldy #2                  ; odd
@1              plp
                bcc @2
                iny                     ; right fuse
@2              lda column
                ldx top_offsets,y

                lda bomb_vphase
                sta prev_bomb_phase
                clc
                adc #bomb0Top
;               clc
                adc #2                  ; 2 lines from top of phase
                tay
;               clc
                adc #5
                sta @mod1+1
;               clc
                adc #7
                sta @mod2+1

@3              sty linenum
                lda hires_table_lo,y
                sta screenl
                lda hires_table_hi,y
                sta screenh

                ldy column
                lda (screenl),y
;               and top_mask,x
                ora top_data,x
                sta (screenl),y
                inx
                iny
                lda (screenl),y
;               and top_mask,x
                ora top_data,x
                sta (screenl),y
                inx

                ldy linenum
                iny
@mod1           cpy #$ff
                bne @3
                same_page_as @3

@4              sty linenum
                lda hires_table_lo,y
                sta screenl
                lda hires_table_hi,y
                sta screenh

                ldy column
                lda (screenl),y
                and top_mask,x
                ora top_data,x
                sta (screenl),y
                inx
                iny
                lda (screenl),y
                and top_mask,x
                ora top_data,x
                sta (screenl),y
                inx

                ldy linenum
                iny
@mod2           cpy #$ff
                bne @4
                same_page_as @4
                rts

top_offsets     .byte 0,24,48,72,96

                .align 256

top_data        .byte $38,$00           ; even bomb, left fuse
                .byte $60,$01
                .byte $00,$07
                .byte $00,$07
                .byte $60,$01
                .byte $00,$00           ; (bomb start)
                .byte $00,$00
                .byte $78,$1f
                .byte $78,$1f
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00

                .byte $00,$1c           ; even bomb, right fuse
                .byte $00,$07
                .byte $60,$01
                .byte $60,$01
                .byte $00,$07
                .byte $00,$00           ; (bomb start)
                .byte $00,$00
                .byte $78,$1f
                .byte $78,$1f
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00

                .byte $1c,$00           ; odd bomb, left fuse
                .byte $70,$00
                .byte $40,$03
                .byte $40,$03
                .byte $70,$00
                .byte $00,$00           ; (bomb start)
                .byte $00,$00
                .byte $7c,$0f
                .byte $7c,$0f
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00

                .byte $00,$0e           ; odd bomb, right fuse
                .byte $40,$03
                .byte $70,$00
                .byte $70,$00
                .byte $40,$03
                .byte $00,$00           ; (bomb start)
                .byte $00,$00
                .byte $7c,$0f
                .byte $7c,$0f
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00

                .byte $00,$00           ; no bomb
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00           ; (bomb start)
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00

                .align 256

top_mask        .byte $00,$00           ; even bomb, left fuse
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $0f,$70
                .byte $03,$40
                .byte $03,$40
                .byte $03,$40
                .byte $03,$40
                .byte $0f,$70
                .byte $3f,$7c

                .byte $00,$00           ; even bomb, right fuse
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $0f,$70
                .byte $03,$40
                .byte $03,$40
                .byte $03,$40
                .byte $03,$40
                .byte $0f,$70
                .byte $3f,$7c

                .byte $00,$00           ; odd bomb, left fuse
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $07,$78
                .byte $01,$60
                .byte $01,$60
                .byte $01,$60
                .byte $01,$60
                .byte $07,$78
                .byte $1f,$7e

                .byte $00,$00           ; odd bomb, right fuse
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $07,$78
                .byte $01,$60
                .byte $01,$60
                .byte $01,$60
                .byte $01,$60
                .byte $07,$78
                .byte $1f,$7e

                .byte $00,$00           ; no bomb
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $00,$00
                .byte $7f,$7f
                .byte $7f,$7f
                .byte $7f,$7f
                .byte $7f,$7f
                .byte $7f,$7f
                .byte $7f,$7f
                .byte $7f,$7f

                .align 256
bombs_l_even
bomb_lx_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

bomb_l0_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $2a,$55
                .byte $3a,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $2a,$57
                .byte $6a,$55
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_l1_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $3a,$55
                .byte $3a,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $2a,$57
                .byte $6a,$55
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_l2_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $6a,$55
                .byte $ab,$55
                .byte $aa,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $2a,$57
                .byte $6a,$55
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_l3_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $bb,$55
                .byte $ba,$55
                .byte $aa,$55
                .byte $eb,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $6a,$55
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .align 256
bombs_r_even
bomb_rx_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

bomb_r0_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$5d
                .byte $2a,$57
                .byte $6a,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_r1_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$55
                .byte $2a,$5d
                .byte $2a,$5d
                .byte $2a,$57
                .byte $6a,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_r2_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$57
                .byte $2a,$f5
                .byte $2a,$d5
                .byte $2a,$57
                .byte $6a,$55
                .byte $6a,$55
                .byte $2a,$57
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

bomb_r3_even    .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$f7
                .byte $2a,$dd
                .byte $2a,$d5
                .byte $2a,$d7
                .byte $2a,$57
                .byte $6a,$55
                .byte $2a,$57
                .byte $0a,$50
                .byte $02,$40
                .byte $7a,$5f
                .byte $7a,$5f
                .byte $02,$40
                .byte $0a,$50
                .byte $2a,$54

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .align 256
bombs_l_odd
bomb_lx_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

bomb_l0_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $5d,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $55,$2b
                .byte $75,$2a
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_l1_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $5d,$2a
                .byte $5d,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $55,$2b
                .byte $75,$2a
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_l2_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $75,$2a
                .byte $d7,$2a
                .byte $d5,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $55,$2b
                .byte $75,$2a
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_l3_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $f7,$2a
                .byte $f5,$2a
                .byte $d5,$2a
                .byte $d7,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $75,$2a
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .align 256
bombs_r_odd
bomb_rx_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

bomb_r0_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2e
                .byte $55,$2b
                .byte $75,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_r1_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2a
                .byte $55,$2e
                .byte $55,$2e
                .byte $55,$2b
                .byte $75,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_r2_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$2b
                .byte $55,$ba
                .byte $55,$aa
                .byte $55,$2b
                .byte $75,$2a
                .byte $75,$2a
                .byte $55,$2b
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

bomb_r3_odd     .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

                .byte $55,$bb
                .byte $55,$ab
                .byte $55,$aa
                .byte $55,$ba
                .byte $55,$2b
                .byte $75,$2a
                .byte $55,$2b
                .byte $05,$28
                .byte $01,$20
                .byte $7d,$2f
                .byte $7d,$2f
                .byte $01,$20
                .byte $05,$28
                .byte $15,$2a

                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a
                .byte $55,$2a

explode_table   .word explode_xx_even
                .word explode_0p_even
                .word explode_0w_even
                .word explode_0p_even

                .word explode_1w_even
                .word explode_1p_even
                .word explode_1w_even
                .word explode_1p_even

                .word explode_2w_even
                .word explode_2p_even
                .word explode_2w_even
                .word explode_2p_even

                .word explode_xx_odd
                .word explode_0p_odd
                .word explode_0w_odd
                .word explode_0p_odd

                .word explode_1w_odd
                .word explode_1p_odd
                .word explode_1w_odd
                .word explode_1p_odd

                .word explode_2w_odd
                .word explode_2p_odd
                .word explode_2w_odd
                .word explode_2p_odd

explode_0w_even .byte $2a,$55,$2e,$55
                .byte $6a,$5d,$2a,$55
                .byte $2a,$75,$3a,$55
                .byte $2a,$75,$2e,$55
                .byte $6a,$75,$2f,$55
                .byte $2a,$77,$6b,$55
                .byte $2a,$7f,$2f,$55
                .byte $2a,$7d,$2f,$55
                .byte $6a,$7d,$2b,$55
                .byte $2a,$75,$6f,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$7f,$2f,$55
                .byte $2a,$77,$3b,$55
                .byte $6a,$75,$6a,$55
                .byte $2a,$75,$2e,$55
                .byte $2a,$55,$2a,$55

explode_0w_odd  .byte $55,$2a,$5d,$2a
                .byte $55,$3b,$55,$2a
                .byte $55,$6a,$75,$2a
                .byte $55,$6a,$5d,$2a
                .byte $55,$6b,$5f,$2a
                .byte $55,$6e,$57,$2b
                .byte $55,$7e,$5f,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$7b,$57,$2a
                .byte $55,$6a,$5f,$2b
                .byte $55,$7a,$5f,$2a
                .byte $55,$7e,$5f,$2a
                .byte $55,$6e,$77,$2a
                .byte $55,$6b,$55,$2b
                .byte $55,$6a,$5d,$2a
                .byte $55,$2a,$55,$2a

explode_0p_even .byte $2a,$55,$24,$55
                .byte $4a,$48,$2a,$55
                .byte $2a,$25,$12,$55
                .byte $2a,$25,$24,$55
                .byte $4a,$24,$25,$55
                .byte $2a,$22,$49,$54
                .byte $2a,$2a,$25,$55
                .byte $2a,$29,$25,$55
                .byte $4a,$28,$29,$55
                .byte $2a,$25,$45,$54
                .byte $2a,$29,$25,$55
                .byte $2a,$2a,$25,$55
                .byte $2a,$22,$11,$55
                .byte $4a,$24,$4a,$54
                .byte $2a,$25,$24,$55
                .byte $2a,$55,$2a,$55

explode_0p_odd  .byte $55,$2a,$49,$2a
                .byte $15,$11,$55,$2a
                .byte $55,$4a,$24,$2a
                .byte $55,$4a,$48,$2a
                .byte $15,$49,$4a,$2a
                .byte $55,$44,$12,$29
                .byte $55,$54,$4a,$2a
                .byte $55,$52,$4a,$2a
                .byte $15,$51,$52,$2a
                .byte $55,$4a,$0a,$29
                .byte $55,$52,$4a,$2a
                .byte $55,$54,$4a,$2a
                .byte $55,$44,$22,$2a
                .byte $15,$49,$14,$29
                .byte $55,$4a,$48,$2a
                .byte $55,$2a,$55,$2a

explode_1w_even .byte $2a,$55,$2a,$55
                .byte $2a,$55,$3a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$77,$2e,$55
                .byte $2a,$75,$2f,$55
                .byte $2a,$77,$2b,$55
                .byte $2a,$7f,$2f,$55
                .byte $2a,$7f,$2f,$55
                .byte $2a,$7d,$2b,$55
                .byte $2a,$75,$2f,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$75,$2b,$55
                .byte $2a,$77,$2f,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55

explode_1w_odd  .byte $55,$2a,$55,$2a
                .byte $55,$2a,$75,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$6e,$5d,$2a
                .byte $55,$6a,$5f,$2a
                .byte $55,$6e,$57,$2a
                .byte $55,$7e,$5f,$2a
                .byte $55,$7e,$5f,$2a
                .byte $55,$7a,$57,$2a
                .byte $55,$6a,$5f,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$6a,$57,$2a
                .byte $55,$6e,$5f,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a

explode_1p_even .byte $2a,$55,$2a,$55
                .byte $2a,$55,$12,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$22,$24,$55
                .byte $2a,$25,$25,$55
                .byte $2a,$22,$29,$55
                .byte $2a,$2a,$25,$55
                .byte $2a,$2a,$25,$55
                .byte $2a,$29,$29,$55
                .byte $2a,$25,$25,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$25,$29,$55
                .byte $2a,$22,$25,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55

explode_1p_odd  .byte $55,$2a,$55,$2a
                .byte $55,$2a,$25,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$44,$48,$2a
                .byte $55,$4a,$4a,$2a
                .byte $55,$44,$52,$2a
                .byte $55,$54,$4a,$2a
                .byte $55,$54,$4a,$2a
                .byte $55,$52,$52,$2a
                .byte $55,$4a,$4a,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$4a,$52,$2a
                .byte $55,$44,$4a,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a

explode_2w_even .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$75,$2b,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$75,$2b,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$7d,$2f,$55
                .byte $2a,$75,$2b,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55

explode_2w_odd  .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$6a,$57,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$6a,$57,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$7a,$5f,$2a
                .byte $55,$6a,$57,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a

explode_2p_even .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$25,$29,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$25,$29,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$29,$25,$55
                .byte $2a,$25,$29,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55

explode_2p_odd  .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$4a,$52,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$4a,$52,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$52,$4a,$2a
                .byte $55,$4a,$52,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a

explode_xx_even .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55
                .byte $2a,$55,$2a,$55

explode_xx_odd  .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a
                .byte $55,$2a,$55,$2a

; 54 cycles per line
; 19 lines
; 8 bombs
; = 8208 cycles

; 14 bytes per line
; 142 lines
; = 1988 bytes (0x7C4)

; 72 + 20 cycles per line
; 19 lines
; 8 bombs
; = 3616 cycles

; NOTE: There's very little cycle savings
;   in trimming end_line based on bomb_dy.

;               lda bomb_data,x         ; 4
;               sta bombLineN+0,y       ; 4
;               inx                     ; 2
;               lda bomb_data,x         ; 4
;               sta bombLineN+1,y       ; 4
;               inx                     ; 2
;
; 20 cycles per bomb line
; 14 bytes of code per bomb line

; generate bomb blitting code
init_bombs      ldy #0                  ; table entry 0
                jsr @unroll
                ldy #8                  ; table entry 1
                jsr @unroll
                ldy #16                 ; table entry 2
                jsr @unroll
                ldy #24                 ; table entry 3
@unroll         ldx #0
@1              lda unroll_table,y
                sta data_addr_l,x
                iny
                inx
                cpx #8
                bne @1

                ldx #bombsTop-4         ; 4 extra lines for max delta
                lda #0
                sta table_index
@2              ldy table_index
                lda code_ptr
                sta (table_ptr1),y
                lda code_ptr_h
                sta (table_ptr2),y
                iny
                sty table_index

                ldy #0
                lda #$bd                ; lda $ffff,x
                sta (code_ptr),y
                iny
                lda data_addr_l
                sta (code_ptr),y
                iny
                lda data_addr_h
                sta (code_ptr),y
                iny
                lda #$99                ; sta $ffff,y
                sta (code_ptr),y
                iny

                cpx #bombsBottom
                bcc @3
                lda #<clip_buffer
                sta (code_ptr),y
                iny
                lda #>clip_buffer
                bcs @4                  ; always

@3              lda hires_table_lo,x
;               ora #0                  ; bombLineN+0
                sta (code_ptr),y
                iny
                lda hires_table_hi,x

@4              sta (code_ptr),y
                iny
                lda #$e8                ; inx
                sta (code_ptr),y
                iny
                lda #$bd                ; lda $ffff,x
                sta (code_ptr),y
                iny
                lda data_addr_l
                sta (code_ptr),y
                iny
                lda data_addr_h
                sta (code_ptr),y
                iny
                lda #$99                ; sta $ffff,y
                sta (code_ptr),y
                iny

                cpx #bombsBottom
                bcc @5
                lda #<clip_buffer
                sta (code_ptr),y
                iny
                lda #>clip_buffer
                bcs @6                  ; always

@5              lda hires_table_lo,x
                ora #1                  ; bombLineN+1
                sta (code_ptr),y
                iny
                lda hires_table_hi,x

@6              sta (code_ptr),y
                iny
                lda #$e8                ; inx
                sta (code_ptr),y
                iny
                tya
                clc
                adc code_ptr
                sta code_ptr
                bcc @7
                inc code_ptr_h
@7              inx
                cpx #bombsBottom+7
                beq @8
                jmp @2

; write final rts and terminating table entry
@8              ldy #0
                lda #$60                ; rts
                sta (code_ptr),y
                ldy table_index
                lda code_ptr
                sta (table_ptr1),y
                lda code_ptr_h
                sta (table_ptr2),y
                rts

unroll_table    .word bombs_l_even,code_buffer0,table_buffer0_lo,table_buffer0_hi
                .word bombs_r_even,code_buffer1,table_buffer1_lo,table_buffer1_hi
                .word bombs_l_odd, code_buffer2,table_buffer2_lo,table_buffer2_hi
                .word bombs_r_odd, code_buffer3,table_buffer3_lo,table_buffer3_hi


                ; .byte %................................
                ; .byte %................................
                ; .byte %................................
                ; .byte %........####....................
                ; .byte %............####................
                ; .byte %................####............
                ; .byte %................####............
                ; .byte %............####................
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %............####................
                ; .byte %................................		; bomb 0

                ; .byte %................................
                ; .byte %................................
                ; .byte %........####....................
                ; .byte %........####....................
                ; .byte %............####................
                ; .byte %................####............
                ; .byte %................####............
                ; .byte %............####................
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %............####................
                ; .byte %................................		; bomb 1

                ; .byte %............####................
                ; .byte %........########................
                ; .byte %........####....................
                ; .byte %........####....................
                ; .byte %............####................
                ; .byte %................####............
                ; .byte %................####............
                ; .byte %............####................
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %............####................
                ; .byte %................................		; bomb 2

                ; .byte %........####....................
                ; .byte %....########....................
                ; .byte %........####....................
                ; .byte %........####....................
                ; .byte %............####................
                ; .byte %................####............
                ; .byte %................####............
                ; .byte %............####................
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %........############............
                ; .byte %........############............
                ; .byte %............####................
                ; .byte %................................		; bomb 3

                ; .byte %....................####........
                ; .byte %####....####....................
                ; .byte %............####........####....
                ; .byte %............####....####........
                ; .byte %####........############........
                ; .byte %....####....########........####
                ; .byte %....####################........
                ; .byte %........################........
                ; .byte %####....############............
                ; .byte %............############....####
                ; .byte %........################........
                ; .byte %....####################........
                ; .byte %....####....########....####....
                ; .byte %####........####............####
                ; .byte %............####....####........
                ; .byte %................................		; explode 0

                ; .byte %................................
                ; .byte %........................####....
                ; .byte %................................
                ; .byte %....####....####....####........
                ; .byte %............############........
                ; .byte %....####....########............
                ; .byte %....####################........
                ; .byte %....####################........
                ; .byte %........############............
                ; .byte %............############........
                ; .byte %........################........
                ; .byte %........################........
                ; .byte %............########............
                ; .byte %....####....############........
                ; .byte %................................
                ; .byte %................................		; explode 1

                ; .byte %................................
                ; .byte %................................
                ; .byte %................................
                ; .byte %................................
                ; .byte %............########............
                ; .byte %........################........
                ; .byte %........################........
                ; .byte %............########............
                ; .byte %........################........
                ; .byte %........################........
                ; .byte %............########............
                ; .byte %................................
                ; .byte %................................
                ; .byte %................................
                ; .byte %................................
                ; .byte %................................		; explode 2
