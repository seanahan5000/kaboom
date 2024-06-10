                .align 256

div7            .byte $00,$00,$00,$00,$00,$00,$00
                .byte $01,$01,$01,$01,$01,$01,$01
                .byte $02,$02,$02,$02,$02,$02,$02
                .byte $03,$03,$03,$03,$03,$03,$03
                .byte $04,$04,$04,$04,$04,$04,$04
                .byte $05,$05,$05,$05,$05,$05,$05
                .byte $06,$06,$06,$06,$06,$06,$06
                .byte $07,$07,$07,$07,$07,$07,$07
                .byte $08,$08,$08,$08,$08,$08,$08
                .byte $09,$09,$09,$09,$09,$09,$09
                .byte $0a,$0a,$0a,$0a,$0a,$0a,$0a
                .byte $0b,$0b,$0b,$0b,$0b,$0b,$0b
                .byte $0c,$0c,$0c,$0c,$0c,$0c,$0c
                .byte $0d,$0d,$0d,$0d,$0d,$0d,$0d
                .byte $0e,$0e,$0e,$0e,$0e,$0e,$0e
                .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f
                .byte $10,$10,$10,$10,$10,$10,$10
                .byte $11,$11,$11,$11,$11,$11,$11
                .byte $12,$12,$12,$12,$12,$12,$12
                .byte $13,$13,$13,$13,$13,$13,$13
                .byte $14,$14,$14,$14,$14,$14,$14
                .byte $15,$15,$15,$15,$15,$15,$15
                .byte $16,$16,$16,$16,$16,$16,$16
                .byte $17,$17,$17,$17,$17,$17,$17
                .byte $18,$18,$18,$18,$18,$18,$18
                .byte $19,$19,$19,$19,$19,$19,$19
                .byte $1a,$1a,$1a,$1a,$1a,$1a,$1a
                .byte $1b,$1b,$1b,$1b,$1b,$1b,$1b
                .byte $1c,$1c,$1c,$1c,$1c,$1c,$1c
                .byte $1d,$1d,$1d,$1d,$1d,$1d,$1d
                .byte $1e,$1e,$1e,$1e,$1e,$1e,$1e
                .byte $1f,$1f,$1f,$1f,$1f,$1f,$1f
                .byte $20,$20,$20,$20,$20,$20,$20
                .byte $21,$21,$21,$21,$21,$21,$21
                .byte $22,$22,$22,$22,$22,$22,$22
                .byte $23,$23,$23,$23,$23,$23,$23
                .byte $24,$24,$24,$24

                .align 256

mod7            .byte $00,$01,$02,$03
mod7_hi         .byte $04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03,$04,$05,$06
                .byte $00,$01,$02,$03

                .align 256

hires_table_lo  .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $80,$80,$80,$80,$80,$80,$80,$80
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $80,$80,$80,$80,$80,$80,$80,$80
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $80,$80,$80,$80,$80,$80,$80,$80
                .byte $00,$00,$00,$00,$00,$00,$00,$00
                .byte $80,$80,$80,$80,$80,$80,$80,$80
                .byte $28,$28,$28,$28,$28,$28,$28,$28
                .byte $a8,$a8,$a8,$a8,$a8,$a8,$a8,$a8
                .byte $28,$28,$28,$28,$28,$28,$28,$28
                .byte $a8,$a8,$a8,$a8,$a8,$a8,$a8,$a8
                .byte $28,$28,$28,$28,$28,$28,$28,$28
                .byte $a8,$a8,$a8,$a8,$a8,$a8,$a8,$a8
                .byte $28,$28,$28,$28,$28,$28,$28,$28
                .byte $a8,$a8,$a8,$a8,$a8,$a8,$a8,$a8
                .byte $50,$50,$50,$50,$50,$50,$50,$50
                .byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
                .byte $50,$50,$50,$50,$50,$50,$50,$50
                .byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
                .byte $50,$50,$50,$50,$50,$50,$50,$50
                .byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
                .byte $50,$50,$50,$50,$50,$50,$50,$50
                .byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0

div7_hi         .byte $24,$24,$24
                .byte $25,$25,$25,$25,$25,$25,$25
                .byte $26,$26,$26,$26,$26,$26,$26
                .byte $27,$27,$27,$27,$27,$27,$27

                .align 256

hires_table_hi  .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
                .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
                .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $20,$24,$28,$2c,$30,$34,$38,$3c
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $21,$25,$29,$2d,$31,$35,$39,$3d
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $22,$26,$2a,$2e,$32,$36,$3a,$3e
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
                .byte $23,$27,$2b,$2f,$33,$37,$3b,$3f
