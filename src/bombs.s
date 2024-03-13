
; *** 18 (15+3) lines between bombs ***
; *** +2 lines for clipping ***

bomb_columns    .byte 2,4,6,8,10,12,14,16
bomb_frames     .byte 1,0,0,0, 0, 0, 0, 0

bomb_dy_offset  .byte 0,6,4,2,0

init_bombs      jsr write_unrolls
                ; ***
                rts

draw_bombs
                ; TODO: clean up/justify +1 here
                ;   (currently needed because bomb_phase can be -1)
                lda #18*7+1
                clc
                adc bomb_phase
                sta start_line
                ; lda #centerHeight
;               clc
                adc #18
                sta end_line

                ldx #7
@1              stx bomb_index

                ; randomize bomb frame
                ldy bomb_frames,x
                beq @2
                jsr random
                eor vblank_count
                and #$03
                tay
                iny
                tya
                sta bomb_frames,x
@2
                ; TODO: drawing bottom to top won't be needed
                ;   for DY of 1-3, if not always padding to 4 lines
                ; TODO: don't always draw 4 lines of DY in order to
                ;   get cycles back for earlier waves

                lda bomb_offsets_l,y
                ; *** use wave directly?
                ldy bomb_dy
                clc
                adc bomb_dy_offset,y
                ldy bomb_columns,x
                tax

                ; *** pick left/right bomb draw
                ; jsr draw_bomb_l
                ; jsr draw_bomb_r
                jsr blit_bomb_l

@3              lda start_line
                sta end_line
                sec
                sbc #18
                sta start_line

                ldx bomb_index
                dex
                bpl @1

                rts

update_bombs
                ; adjust bomb phase by DY
                lda bomb_phase
                clc
                adc bomb_dy
                ; TODO: clean up/justify -1 here
                cmp #18-1
                bcc @2
;               sec
                sbc #18
                pha                     ;***
                ; *** if last bomb present, end round ***

                ldx #6
@1              lda bomb_columns,x
                sta bomb_columns+1,x
                lda bomb_frames,x
                sta bomb_frames+1,x
                dex
                bpl @1

                ;*** pick new position, etc.
                ;*** bad alignment -- center on bomber after move ***
                lda bomber_x
                asl
                tax
                lda div7,x
                and #$FE
                bne @3
                lda #2                  ;*** fix with bomber instead
@3              sta bomb_columns+0
                ; *** also clamp to right side? ***

                lda #1
                sta bomb_frames+0

                ; erase bottom bomb
                lda #0
                sta bomb_frames+7

                ; bump score
                ; TODO: remember to cap at 999999 and stop
                sed
                sec                     ; game_wave+1
                lda score+2
                adc game_wave
                sta score+2
                lda score+1
                adc #0
                sta score+1
                lda score+0
                adc #0
                sta score+0
                cld

                pla                     ;***
@2              sta bomb_phase
                rts

; *** combine these ***

bomb_offsets_l  .byte bomb_lx-bomb_data_l
                .byte bomb_l0-bomb_data_l
                .byte bomb_l1-bomb_data_l
                .byte bomb_l2-bomb_data_l
                .byte bomb_l3-bomb_data_l

bomb_offsets_r  .byte bomb_rx-bomb_data_r
                .byte bomb_r0-bomb_data_r
                .byte bomb_r1-bomb_data_r
                .byte bomb_r2-bomb_data_r
                .byte bomb_r3-bomb_data_r

                .align 256
bomb_data_l
bomb_lx         .byte $2a,$55
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
                .byte $2a,$55

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_l0         .byte $2a,$55
                .byte $2a,$55
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_l1         .byte $2a,$55
                .byte $2a,$55
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_l2         .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $6a,$55
                .byte $ab,$55
                .byte $aa,$55
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_l3         .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $bb,$55
                .byte $ba,$55
                .byte $aa,$55
                .byte $ab,$55
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

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .align 256
bomb_data_r
bomb_rx         .byte $2a,$55
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
                .byte $2a,$55

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_r0         .byte $2a,$55
                .byte $2a,$55
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_r1         .byte $2a,$55
                .byte $2a,$55
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_r2         .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$57
                .byte $2a,$f5
                .byte $2a,$d5
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

;               .byte $2a,$55
;               .byte $2a,$55
;               .byte $2a,$55

bomb_r3         .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55

                .byte $2a,$fd
                .byte $2a,$dd
                .byte $2a,$d5
                .byte $2a,$f5
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

                .byte $2a,$55
                .byte $2a,$55
                .byte $2a,$55




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

explode_bits
                .byte %00000100
                .byte %10100000
                .byte %00010010
                .byte %00010100
                .byte %10011100
                .byte %01011001
                .byte %01111100
                .byte %00111100
                .byte %10111000
                .byte %00011101
                .byte %00111100
                .byte %01111100
                .byte %01011010
                .byte %10010001
                .byte %00010100
                .byte %00000000		; explode 0

                .byte %00000000
                .byte %00000010
                .byte %00000000
                .byte %01010100
                .byte %00011100
                .byte %01011000
                .byte %01111100
                .byte %01111100
                .byte %00111000
                .byte %00011100
                .byte %00111100
                .byte %00111100
                .byte %00011000
                .byte %01011100
                .byte %00000000
                .byte %00000000		; explode 1

                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00011000
                .byte %00111100
                .byte %00111100
                .byte %00011000
                .byte %00111100
                .byte %00111100
                .byte %00011000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000
                .byte %00000000		; explode 2



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


;
; On entry:
;   X: offset into bomb data
;   Y: dest column
;   start_line: first bomb line
;   end_line: last bomb line, exclusive
;
blit_bomb_l     sty @mod1+1             ; 4
                ldy start_line          ; 3
                lda table_buffer0_lo,y  ; 4
                sta @mod2+1             ; 4
                lda table_buffer0_hi,y  ; 4
                sta @mod2+2             ; 4
                ldy end_line            ; 3
                lda table_buffer0_lo,y  ; 4
                sta temp_ptr            ; 3
                lda table_buffer0_hi,y  ; 4
                sta temp_ptr_h          ; 3
                ldy #0                  ; 2
                lda #$60                ; 2 rts
                sta (temp_ptr),y        ; 5
@mod1           ldy #$ff                ; 2
@mod2           jsr $ffff               ; 6 + 6 rts
                ldy #0                  ; 2
                lda #$bd                ; 2 lda $ffff,x
                sta (temp_ptr),y        ; 5
                rts                     ; = 72 + lines * 20

blit_bomb_r     sty @mod1+1             ; 4
                ldy start_line          ; 3
                lda table_buffer1_lo,y  ; 4
                sta @mod2+1             ; 4
                lda table_buffer1_hi,y  ; 4
                sta @mod2+2             ; 4
                ldy end_line            ; 3
                lda table_buffer1_lo,y  ; 4
                sta temp_ptr            ; 3
                lda table_buffer1_hi,y  ; 4
                sta temp_ptr_h          ; 3
                ldy #0                  ; 2
                lda #$60                ; 2 rts
                sta (temp_ptr),y        ; 5
@mod1           ldy #$ff                ; 2
@mod2           jsr $ffff               ; 6 + 6 rts
                ldy #0                  ; 2
                lda #$bd                ; 2 lda $ffff,x
                sta (temp_ptr),y        ; 5
                rts                     ; = 72 + lines * 20

data_addr_l     =   $a0                 ; must be consecutive ->
data_addr_h     =   $a1
code_ptr        =   $a2
code_ptr_h      =   $a3
table_ptr1      =   $a4
table_ptr1_h    =   $a5
table_ptr2      =   $a6
table_ptr2_h    =   $a7                 ; <- in this order

table_index     =   $a8

table_buffer0_lo =  $4000
table_buffer0_hi =  $4100
code_buffer0    =   $4200

table_buffer1_lo =  $5000
table_buffer1_hi =  $5100
code_buffer1    =   $5200
clip_buffer     =   $5f00

unroll_table    .word bomb_data_l,code_buffer0,table_buffer0_lo,table_buffer0_hi
                .word bomb_data_r,code_buffer1,table_buffer1_lo,table_buffer1_hi

;               lda bomb_data,x         ; 4
;               sta bombLineN+0,y       ; 4
;               inx                     ; 2
;               lda bomb_data,x         ; 4
;               sta bombLineN+1,y       ; 4
;               inx                     ; 2
;
; 20 cycles per bomb line
; 14 bytes of code per bomb line

write_unrolls   ldy #0                  ; table entry 0
                jsr @unroll
                ldy #8                  ; table entry 1
@unroll         ldx #0
@1              lda unroll_table,y
                sta data_addr_l,x
                iny
                inx
                cpx #8
                bne @1

                ldx #bombsTop
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
                ; TODO: limit this to the actual/exact number needed
                cpx #bombsBottom+18+1
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
