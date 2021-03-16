#include "otsys.asm"

;short test program

;test register files
A1:
addu $0, $0, 5
addu $1, $0, 0
bne $0, $1, A1
A2:
addu $1,$0, 45
addu $2,$0, 45
bne $1,$2, A2
A3:
addu $3,$0, 145
addu $4,$0, 145
bne $3,$4, A3
A4:
addu $5,$0, 3845
addu $6,$0, 3845
bne $5,$6, A4
A5:
addu $7,$0, 336
addu $8,$0, 336
bne $7,$8, A5
A6:
addu $9,$0, 673
addu $10,$0, 673
bne $9,$10, A6
A7:
addu $11,$0, 3742
addu $12,$0, 3742
bne $11,$12, A7
A8:
addu $12,$0, 4372
addu $13,$0, 4372
bne $12,$13, A8
A9:
addu $14,$0, 328
addu $15,$0, 328
bne $14,$15, A9
A10:
addu $16,$0, 264
addu $17,$0, 264
bne $16,$17, A10
A11:
addu $18,$0, 283
addu $19,$0, 283
bne $18,$19, A11
A12:
addu $20,$0, 1264
addu $21,$0, 1264
beq $20, $18, A12
bne $20,$21, A12
A13:
addu $22,$0, 236
addu $23,$0, 236
bne $22,$23, A13
A14:
addu $24,$0, 221
addu $25,$0, 221
bne $24,$25, A14
A15:
addu $26,$0, 2811
addu $27,$0, 2811
bne $26,$27, A15
A16:
addu $28,$0, 236
addu $29,$0, 236
bne $28,$29, A16
A17:
addu $30,$0, 4627
addu $31,$0, 4627
bne $30,$31, A17

;test load/store




;test conditional jump




