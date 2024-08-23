
;-------------------------------------------------------------------------------

DISABLE_TONE_A         = %00000001
DISABLE_TONE_B         = %00000010
DISABLE_TONE_C         = %00000100
DISABLE_NOISE_A        = %00001000
DISABLE_NOISE_B        = %00010000
DISABLE_NOISE_C        = %00100000

REG_AY_A_FINE_TONE     = $00
REG_AY_A_COARSE_TONE   = $01
REG_AY_B_FINE_TONE     = $02
REG_AY_B_COARSE_TONE   = $03
REG_AY_C_FINE_TONE     = $04
REG_AY_C_COARSE_TONE   = $05
REG_AY_NOISE           = $06
REG_AY_ENABLE          = $07
REG_AY_A_VOLUME        = $08
REG_AY_B_VOLUME        = $09
REG_AY_C_VOLUME        = $0A
REG_AY_ENVELOPE_FINE   = $0B
REG_AY_ENVELOPE_COARSE = $0C
REG_AY_ENVELOPE_SHAPE  = $0D

; AY-3-8910 commands
                                        ; DIR BC1 BC0
MB_AY_RESET     =   $00                 ;  0   0   0
MB_AY_INACTIVE  =   $04                 ;  1   0   0
MB_AY_READ      =   $05                 ;  1   0   1
MB_AY_WRITE     =   $06                 ;  1   1   0
MB_AY_LATCH     =   $07                 ;  1   1   1

; offsets from slot address

MB_6522_BASE1   =   $00
MB_6522_BASE2   =   $80

; left speaker
MB_6552_ORB1    =   $00                 ; #1 port B data
MB_6552_ORA1    =   $01                 ; #1 port A data
MB_6522_DDRB1   =   $02                 ; #1 data direction port B
MB_6522_DDRA1   =   $03                 ; #1 data direction port A

; right speaker
MB_6552_ORB2    =   $80                 ; #2 port B data
MB_6552_ORA2    =   $81                 ; #2 port A data
MB_6522_DDRB2   =   $82                 ; #2 data direction port B
MB_6522_DDRA2   =   $83                 ; #2 data direction port A

MB_6522_T1CL    =   $04                 ; #1 timer 1 low order counter
MB_6522_T1CH    =   $05                 ; #1 timer 1 high order counter
MB_6522_T1LL    =   $06                 ; #1 timer 1 low order latch
MB_6522_T1LH    =   $07                 ; #1 timer 1 high order latch
MB_6522_T2CL    =   $08                 ; #1 timer 2 low order counter
MB_6522_T2CH    =   $09                 ; #1 timer 2 high order counter
MB_6522_SR      =   $0A                 ; #1 shift register
MB_6522_ACR     =   $0B                 ; #1 auxilliary control register
MB_6522_PCR     =   $0C                 ; #1 peripheral control register
MB_6522_IFR     =   $0D                 ; #1 interrupt flag register
MB_6522_IER     =   $0E                 ; #1 interrupt enable register
MB_6522_ORANH   =   $0F                 ; #1 port a data no handshake

;-------------------------------------------------------------------------------

init_sound      bit machine_type
                bvc @1
; enable IIc mockingboard
                lda #$ff
                sta $c403
                sta $c404
@1              lda #$00
                sta mb_ptr
                lda #$c7
                sta mb_ptr_h
; detect mockingboard
                ldy #4
@2              ldx #2
@3              lda (mb_ptr),y
                sta temp                ; 3
                lda (mb_ptr),y          ; 5
                sec
                sbc temp
                cmp #$f8
                bne @4
                dex
                bne @3
                beq mb_init             ; always
@4              dec mb_ptr_h
                lda mb_ptr_h
                cmp #$c0
                bne @2
                dec mb_ptr              ; not found
                rts

mb_init         lda #$ff                ; all output
                ldy #MB_6522_DDRB1
                jsr @init
                ldy #MB_6522_DDRB2
@init           sta (mb_ptr),y
                iny
                sta (mb_ptr),y
;               rts

mb_reset        ldy #MB_6552_ORB1
                jsr @reset
                ldy #MB_6552_ORB2
@reset          lda #MB_AY_RESET
                sta (mb_ptr),y
                lda #MB_AY_INACTIVE
                sta (mb_ptr),y
;               rts

mb_clear        ldx #13
@1              lda #0
                jsr mb_write
                dex
                bpl @1
                rts
;
; On entry:
;   X: register
;   A: value
;
; On exit:
;   X: unchanged
;
mb_write        ldy mb_ptr
                bne @no_sound

                pha
                txa
                jsr @write_a
                lda #MB_AY_LATCH
                jsr @write_b
                lda #MB_AY_INACTIVE
                jsr @write_b
                pla
                jsr @write_a
                lda #MB_AY_WRITE
                jsr @write_b
                lda #MB_AY_INACTIVE
                ; fall through

@write_b        ldy #MB_6552_ORB1
                sta (mb_ptr),y
                ldy #MB_6552_ORB2
                sta (mb_ptr),y
                rts

@write_a        ldy #MB_6552_ORA1
                sta (mb_ptr),y
                ldy #MB_6552_ORA2
                sta (mb_ptr),y
@no_sound       rts

;-------------------------------------------------------------------------------

; volume:      4-bits  (atari: 4-bits)
; noise pitch: 5-bits  (atari: 5-bits)
; tone pitch: 12-bits  (atari: 5-bits on 3/3 pattern)

; Tone Freq  = A2 Clock Freq/ [ (4096 x Coarse) + (16 x Fine) ]
; Noise Freq = A2 Clock Freq/ (16 x NG value)

; a2freq = 1023000
; mbfreq = 63938    ; a2freq / 16 = 63937.5
; atfreq = 32400    ; NTSC: 31399.5 Hz (3.579545MHz/114)

; Mockingboard baseline frequency works out to be approximately
;   2x the baseine frequency of the Atari 2600.  So, any frequency
;   divider value from the Atari needs to be doubled to get the
;   same pitch on the Mockingboard.

update_sound

; play bonus bucket sound (highest priority)
;
; bonus_sound ($3F -> $01)
;
; control = "div 6 : pure tone"
; if (bonus_sound & 2)
;     freq = bonus_sound >> 2
; else
;     freq = bonus_sound
; volume = #$0C
;
                lda bonus_sound
                beq @2
                dec bonus_sound
                tax                     ; tone6 freq = bonus_sound
                and #2
                beq @1
                txa                     ; if (bonus_sound & 2)
                lsr                     ;   tone6 freq = bonus_sound >> 2
                lsr
                tax
@1              txa
                and #$1f                ; original assumes bits 7:5 ignored
                asl
                tax
                lda tone6_table+1,x
                pha
                lda tone6_table+0,x
                ldx #REG_AY_A_FINE_TONE
                jsr mb_write
                pla
                ldx #REG_AY_A_COARSE_TONE
                jsr mb_write
                ldx #REG_AY_A_VOLUME
                lda #$0C
                jsr mb_write            ; channel A volume = #$0C
                ldx #REG_AY_ENABLE
                lda #$3e
                jmp mb_write            ; enable tone channel A

; play bomb explosion sound
;
; exp_bomb_frame ($2B-1 -> $01), ($20-1 -> $01)
;
; control = white noise
; if (exp_bomb_frame + exp_bomb_index < #$20)
;     volume = (exp_bomb_frame + exp_bomb_index) >> 1
;     freq = #$1F
; else
;     volume = exp_bomb_frame + exp_bomb_index
;     freq = #$08
;
@2              lda exp_bomb_frame
                beq @5
                clc
                adc exp_bomb_index
                ldx #REG_AY_A_VOLUME
                cmp #$20
                bcs @3
; if (exp_bomb_frame + exp_bomb_index < #$20)
                lsr
                jsr mb_write            ; volume = (exp_bomb_frame + exp_bomb_index) >> 1
                ldx #$1F                ; noise freq = #$1F
                bne @4                  ; always

; else (exp_bomb_frame + exp_bomb_index >= #$20)
@3              jsr mb_write            ; volume = exp_bomb_frame + exp_bomb_index
                ldx #$08                ; noise freq = #$08
@4              lda noise_table,x
                ldx #REG_AY_NOISE
                jsr mb_write
                ldx #REG_AY_ENABLE
                lda #$37
                jmp mb_write            ; enable noise channel A

; play bucket splash sound
;
; splash_frame ($10 -> $01)
;
; if (splash_frame >= $0F)
;   control = "div 6 : pure tone"
;   freq = splash_frame - game_wave
;   volume = 12
; else
;   control = white noise
;   freq = splash_frame
;   volume = 8
;
@5              lda splash_frame
                beq @7
                dec splash_frame
                cmp #$0F
                bcc @6
; if splash_frame >= #$0F
                sec
                sbc player_wave
                asl
                tax
                lda tone6_table+1,x
                pha
                lda tone6_table+0,x
                ldx #REG_AY_A_FINE_TONE
                jsr mb_write            ; tone freq = splash_frame - game_wave
                pla
                ldx #REG_AY_A_COARSE_TONE
                jsr mb_write
                ldx #REG_AY_A_VOLUME
                lda #$0C
                jsr mb_write            ; volume = #$0C
                ldx #REG_AY_ENABLE
                lda #$3e
                JMP mb_write            ; enable tone channel A

; if splash_frame < #$0F
@6              tax
                lda noise_table,x
                ldx #REG_AY_NOISE
                jsr mb_write            ; noise pitch = splash_frame
                ldx #REG_AY_A_VOLUME
                lda #$08
                jsr mb_write            ; volume = #$08
                ldx #REG_AY_ENABLE
                lda #$37
                jmp mb_write            ; enable noise channel A

; play active bomb fuse burn sound
;
; rnd_0123 = random & 3
; control = white noise
; freq = rnd_0123
; volume = rnd_0123 >> 1
;
@7              lda active_bombs
                beq @8
                jsr random
                and #$03
                pha
                tax
                lda noise_table,x
                ldx #REG_AY_NOISE
                jsr mb_write            ; noise freq = rnd_0123
                pla
                lsr
                ldx #REG_AY_A_VOLUME
                jsr mb_write            ; volume = rnd_0123 >> 1
                ldx #REG_AY_ENABLE
                lda #$37
                jmp mb_write            ; enable noise channel A

; no sound active
;
@8              ldx #REG_AY_ENABLE
                lda #$3f
                jmp mb_write            ; disable all channels

tone6_table     .word 6*1*2             ; *2 MB adjust
                .word 6*2*2
                .word 6*3*2
                .word 6*4*2
                .word 6*5*2
                .word 6*6*2
                .word 6*7*2
                .word 6*8*2
                .word 6*9*2
                .word 6*10*2
                .word 6*11*2
                .word 6*12*2
                .word 6*13*2
                .word 6*14*2
                .word 6*15*2
                .word 6*16*2
                .word 6*17*2
                .word 6*18*2
                .word 6*19*2
                .word 6*20*2
                .word 6*21*2
                .word 6*22*2
                .word 6*23*2
                .word 6*24*2
                .word 6*25*2
                .word 6*26*2
                .word 6*27*2
                .word 6*28*2
                .word 6*29*2
                .word 6*30*2
                .word 6*31*2
                .word 6*32*2

; (x + 1) * 2 - 1
noise_table     .byte 1,3,5,7,9
                .byte 11,13,15,17,19
                .byte 21,23,25,27,29
                .byte 31,33,35,37,39
                .byte 41,43,45,47,49
                .byte 51,53,55,57,59
                .byte 61,63

;-------------------------------------------------------------------------------
