
value           :=  temp
lfsr            :=  offset
lfsr_hi         :=  column

init_sound
; 9-bit lfsr noise (mode $8)
                lda #$ff
                sta lfsr
                lda #$01
                sta lfsr_hi
                ldx #0
@1              ldy #8
@2              lsr lfsr_hi
                lda lfsr
                ror lfsr
                rol value
                and #%00010001
                beq @3
                cmp #%00010001
                beq @3
                lda #$01
                sta lfsr_hi
@3              dey
                bne @2
                lda value
                sta noise9_buffer,x
                inx
                bne @1

; 6-bit tone (mode $C)
                ldx #0
                ldy #0
@4              lda @pattern6,y
                sta tone6_buffer,x
                iny
                cpy #3
                bne @5
                ldy #0
@5              inx
                bne @4
                rts

@pattern6       .byte %11100011
                .byte %10001110
                .byte %00111000

update_sound
; ***
                ; ldx #4
                ; lda #<tone6_buffer
                ; ldy #>tone6_buffer
                ; jsr play_sound
                ; sta saved_data
                ; sty saved_index
                ; ror
                ; sta saved_carry

;***
                ldx #18
@1              cmp click
                jsr wait_64
                jsr wait_32
                cmp click
                jsr wait_64
                jsr wait_32
                dex
                bne @1
                rts

; saved_mode      .byte 0
saved_data      .byte 0
saved_index     .byte 0
saved_carry     .byte 0
; ***

                .align 256              ;***

; play bonus bucket sound (highest priority)
                lda bonus_sound
                beq @2
                dec bonus_sound
; *** bonus_sound ($3F -> $01)
;   control = "div 6 : pure tone"
;   if (bonus_sound & 2)
;       freq = bonus_sound >> 2
;   else
;       freq = bonus_sound
;   volume = #$0C
                tax
                and #2
                beq @1
                txa
                lsr
                lsr
                tax
@1              lda #<tone6_buffer
                ldy #>tone6_buffer
                bne play_sound          ; always

; play bomb explosion sound
@2              lda exp_bomb_frame
                beq @4
; *** exp_bomb_frame ($2B-1 -> $01), ($20-1 -> $01)
; control = white noise
; exp_bomb_frame + exp_bomb_index < #$20
;   volume = (exp_bomb_frame + exp_bomb_index) >> 1
;   freq = #$1F
; else
;   volume = exp_bomb_frame + exp_bomb_index
;   freq = #$08
                ldx #$1f
                cmp #$20
                bcc @3
                ldx #$08
@3              lda #<noise9_buffer
                ldy #>noise9_buffer
                bne play_sound          ; always

; play bucket splash sound
@4              lda splash_frame
                beq @5
;               dec splash_frame
; *** splash_frame ($10 -> $01)
; frame >= $0F
;   control = "div 6 : pure tone"
;   freq = splash_frame - game_wave
;   volume = 12
; frame < $0F
;   control = white noise
;   freq = splash_frame
;   volume = 8
                cmp #$0F
                bcc @32

                sec
                sbc game_wave
                tax
                lda #<tone6_buffer
                ldy #>tone6_buffer
                bne play_sound          ; always

@32             tax
                lda #<noise9_buffer
                ldy #>noise9_buffer
                bne play_sound          ; always

; play active bomb fuse burn sound
@5              lda active_bombs
                beq @6
;   control = white noise
;   freq = rnd_0123
;   volume = rnd_0123 >> 1
                jsr random              ;*** always for consistent timing?
                tax
                lda #<noise9_buffer
                ldy #>noise9_buffer
                bne play_sound          ; always

@6
; *** if nothing played, reset speaker state?
                rts

play_sound      sta ptr
                sty ptr_h
                txa
                cmp #16
                bcc @0
                lda #15                 ; *** skip low frequencies
@0              tay
                asl
                tax
                lda freq_delays+0,x
                sta wait_cycles+1
                lda freq_delays+1,x
                sta wait_cycles+2

                ldx sample_counts,y

                ldy saved_index
                bne @have_data

                bit saved_carry
                bpl @more_data_off
                bmi @more_data_on       ; always

@have_data      lda saved_data
                bit saved_carry
                bmi @still_off
                ; bpl @still_on

@still_on       nop                     ; 2
@loop_on        ; no click
                nop                     ; 2
                nop                     ; 2
                dex                     ; 2
                beq @done_on            ; 2
                asl                     ; 2
                beq @more_data_on       ; 2/3
                bcc @now_off            ; 2/3
                jsr wait_cycles         ; 15
                jmp @loop_on            ; 3

@now_off        jsr wait_cycles         ; 15
                nop                     ; 2
@now_off2       cmp click               ; 4
                dex                     ; 2
                beq @done_off           ; 2
                asl                     ; 2
                beq @more_data_off      ; 2/3
                bcs @now_on             ; 2/3
                jsr wait_cycles         ; 15
                jmp @loop_off           ; 3

@more_data_off  lda (ptr),y             ; 5   no page cross
                iny                     ; 2
                stx temp                ; 3
                sec                     ; 2
                rol                     ; 2
                bcc @still_off          ; 2/3
                jmp @now_on2            ; 3

@done_off       clc
                rts

@still_off      nop                     ; 2
@loop_off       ; no click
                nop                     ; 2
                nop                     ; 2
                dex                     ; 2
                beq @done_off           ; 2
                asl                     ; 2
                beq @more_data_off      ; 2/3
                bcs @now_on             ; 2/3
                jsr wait_cycles         ; 15
                jmp @loop_off           ; 3

@now_on         jsr wait_cycles         ; 15
                nop                     ; 2
@now_on2        cmp click               ; 4
                dex                     ; 2
                beq @done_on            ; 2
                asl                     ; 2
                beq @more_data_on       ; 2/3
                bcc @now_off            ; 2/3
                jsr wait_cycles         ; 15
                jmp @loop_on            ; 3

@more_data_on   lda (ptr),y             ; 5   no page cross
                iny                     ; 2
                stx temp                ; 3
                sec                     ; 2
                rol                     ; 2
                bcs @still_on           ; 2/3
                jmp @now_off2           ; 3

@done_on        sec
                rts

                same_page_as @still_on

freq_delays     .word wait_32_8
                .word wait_65_7
                .word wait_98_6
                .word wait_131_5
                .word wait_164_4
                .word wait_197_2
                .word wait_230_1
                .word wait_263_0
                .word wait_295_9
                .word wait_328_8
                .word wait_361_6
                .word wait_394_5
                .word wait_427_4
                .word wait_460_3
                .word wait_493_2
                .word wait_526_0

sound_cycles    =   3000
sample_counts   .byte sound_cycles/32
                .byte sound_cycles/65
                .byte sound_cycles/98
                .byte sound_cycles/131
                .byte sound_cycles/164
                .byte sound_cycles/197
                .byte sound_cycles/230
                .byte sound_cycles/263
                .byte sound_cycles/295
                .byte sound_cycles/328
                .byte sound_cycles/361
                .byte sound_cycles/394
                .byte sound_cycles/427
                .byte sound_cycles/460
                .byte sound_cycles/493
                .byte sound_cycles/526

                                        ; 6 (jsr)
wait_cycles     jmp $ffff               ; 3  modified

.macro delay_2
                nop                     ; 2
.endmacro

.macro delay_3
                stx temp                ; 3
.endmacro

.macro delay_4
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_5
                stx temp                ; 3
                nop                     ; 2
.endmacro

.macro delay_6
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_7
                pha                     ; 3
                pla                     ; 4
.endmacro

.macro delay_8
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_9
                pha                     ; 3
                pla                     ; 4
                nop                     ; 2
.endmacro

.macro delay_10
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_11
                pha                     ; 3
                pla                     ; 4
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_12
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_13
                pha                     ; 3
                pla                     ; 4
                nop                     ; 2
                nop                     ; 2
                nop                     ; 2
.endmacro

.macro delay_14
                pha                     ; 3
                pla                     ; 4
                pha                     ; 3
                pla                     ; 4
.endmacro

.macro delay_17
                pha                     ; 3
                pla                     ; 4
                pha                     ; 3
                pla                     ; 4
                stx temp                ; 3
.endmacro

; - 17 cycles of overhead in sound loop
; - 15 cycles of overhead calling wait_cycles and returning

; 32 - 32 = 0
wait_32_8       rts

; 65 - 32 = 33
wait_65_7       jsr wait_16
                delay_17
                rts

; 98 - 32 = 66
wait_98_6       jsr wait_64
                delay_2
                rts

; 131 - 32 = 99
wait_131_5      jsr wait_64
                jsr wait_32
                delay_3
                rts

; 164 - 32 = 132
wait_164_4      jsr wait_128
                delay_4
                rts

; 197 - 32 = 165
wait_197_2      jsr wait_128
                jsr wait_32
                delay_5
                rts

; 230 - 32 = 198
wait_230_1      jsr wait_128
                jsr wait_64
                delay_6
                rts

; 263 - 32 = 231
wait_263_0      jsr wait_128
                jsr wait_64
                jsr wait_32
                delay_7
                rts

; 295 - 32 = 263
wait_295_9      jsr wait_256
                delay_7
                rts

; 328 - 32 = 296
wait_328_8      jsr wait_256
                jsr wait_32
                delay_8
                rts

; 361 - 32 = 329
wait_361_6      jsr wait_256
                jsr wait_64
                delay_9
                rts

; 394 - 32 = 362
wait_394_5      jsr wait_256
                jsr wait_64
                jsr wait_32
                delay_10
                rts

; 427 - 32 = 395
wait_427_4      jsr wait_256
                jsr wait_128
                delay_11
                rts

; 460 - 32 = 428
wait_460_3      jsr wait_256
                jsr wait_128
                jsr wait_32
                delay_12
                rts

; 493 - 32 = 461
wait_493_2      jsr wait_256
                jsr wait_128
                jsr wait_64
                delay_13
                rts

; 526 - 32 = 494
wait_526_0      jsr wait_256
                jsr wait_128
                jsr wait_64
                jsr wait_32
                delay_14
                rts

wait_256        jsr wait_128
wait_128        jsr wait_64
wait_64         jsr wait_32
wait_32         jsr wait_16
wait_16         nop                     ; 2
                nop                     ; 2
                rts                     ; 6


; base cyles
;   1023000 / 31113.1 = 32.88

; frequency divided
;
;   0: 1023000 / 31113.1 * 1 = 32.88
;   1: 1023000 / 31113.1 * 2 = 65.76
;   2: 1023000 / 31113.1 * 3 = 98.64
;   3: 1023000 / 31113.1 * 4 = 131.52
;
;   4: 1023000 / 31113.1 * 5 = 164.40
;   5: 1023000 / 31113.1 * 6 = 197.28
;   6: 1023000 / 31113.1 * 7 = 230.16
;   7: 1023000 / 31113.1 * 8 = 263.04
;   8: 1023000 / 31113.1 * 9 = 295.92
;   9: 1023000 / 31113.1 * 10 = 328.80
;  10: 1023000 / 31113.1 * 11 = 361.68
;  11: 1023000 / 31113.1 * 12 = 394.56
;  12: 1023000 / 31113.1 * 13 = 427.44
;  13: 1023000 / 31113.1 * 14 = 460.32
;  14: 1023000 / 31113.1 * 15 = 493.20
;  15: 1023000 / 31113.1 * 16 = 526.08
;
; *** 16 -> 30 ***
;
;  31: 1023000 / 31113.1 * 32 = 1052.16

;   15      AUDC0   ....1111  audio control 0
;   16      AUDC1   ....1111  audio control 1
;
; Bit 0-3, Noise/Division Control (0-15, see below)
;   0  set to 1                    8  9 bit poly (white noise)
;   1  4 bit poly                  9  5 bit poly
;   2  div 15 -> 4 bit poly        A  div 31 : pure tone
;   3  5 bit poly -> 4 bit poly    B  set last 4 bits to 1
;   4  div 2 : pure tone           C  div 6 : pure tone
;   5  div 2 : pure tone           D  div 6 : pure tone
;   6  div 31 : pure tone          E  div 93 : pure tone
;   7  5 bit poly -> div 2         F  5 bit poly div 6

;   17      AUDF0   ...11111  audio frequency 0
;   18      AUDF1   ...11111  audio frequency 1
;
; Bit 0-4, Frequency Divider (0..31 = 30KHz/1..30KHz/32)
;
; The so-called "30KHz" is clocked twice per scanline,
;   (ie. at CPUCLK/38 aka DOTCLK/114), so the exact rate is:
;   PAL:  31113.1 Hz (3.546894MHz/114)
;   NTSC: 31399.5 Hz (3.579545MHz/114)
; After applying the Frequency Divider, the resulting frequency is
;   subsequently divided by AUDC0/AUDC1, which provides additional
;   division by 2, 6, 31, or 93 for pure tone; so the tone frequency
;   range is circa 10Hz..15kHz (ie. 30KHz/32/93..30KHz/1/2).

;   19      AUDV0   ....1111  audio volume 0
;   1A      AUDV1   ....1111  audio volume 1
;
; Bit 0-3, Volume 0-15 (0=Off, 15=Loudest)





; x Rep Pattern Shape
; 0   1 ----------------------------------------------------------------------
; 1  15 ----___-__--_-_----___-__--_-_----___-__--_-_----___-__--_-_----___-__
; 2 465 --------------------------------------------------------------________
; 3 465 ------______-___---__-----___-------___----___--__--_____---------___-
; 4   2 -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
; 5   2 -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
; 6  31 ------------------_____________------------------_____________--------
; 7  31 -----___--_---_-_-____-__-_--__-----___--_---_-_-____-__-_--__-----___

; 8 511 ---------_____----_-----___-_---__--__-_____-__-_-__---_--_-___----__-

; 9  31 -----___--_---_-_-____-__-_--__-----___--_---_-_-____-__-_--__-----___
; A  31 ------------------_____________------------------_____________--------
; B   1 ----------------------------------------------------------------------

; C   6 ---___---___---___---___---___---___---___---___---___---___---___---_

; D   6 ---___---___---___---___---___---___---___---___---___---___---___---_
; E  93 -------------------------------------------------_____________________
; F  93 ----------_____---_______----__________------___------____---------___
