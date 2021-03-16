;test arithmatic

err:
;lui
la $2, 257949753
lui $1, 3936
addu $1,$1,57
bne $1,$2, err
;xor
la $3, 13130
la $1, 5789
la $2, 9687
xor $1,$1,$2
bne $1,$3, err
;xori
la $3, 54279
la $1,8965
xor $1, $1,63234
bne $1,$3, err

;or
la $3, 223047
la $1, 8965
la $2, 214599
or $1,$1,$2
bne $1,$3, err
;ori
la $3, 126955
la $1,85547
or $1, $1,42464
bne $1,$3, err

;and
la $3, 18822
la $1, 88535
la $2, 20366
and $1,$1,$2
bne $1,$3, err
;andi
la $3, 42288
la $1,58874
and $1, $1,42288
bne $1,$3, err

;sltiu
la $1, 56
sltiu $1, $1, 57352
subu $1,$1, 1
bne $1,$0,err
la $1, 56
sltiu $1, $1, 55
bne $1,$0,err

;slti
la $1, 543
slti $1, $1, 57352
bne $1,$0,err
la $1, 56
slti $1, $1, 57
subu $1,$1, 1
bne $1,$0,err

;addu
la $3, 108901
la $1, 88535
la $2, 20366
addu $1,$1,$2
bne $1,$3, err
;addui
la $3, 58870
la $1,58874
addu $1, $1,-4
bne $1,$3, err

;clo
la $3, 5
la $2, -132119195
clo $1, $2
bne $1,$3, err

;clz
la $3, 10
la $2, 2098533
clz $1, $2
bne $1,$3, err

;sltu
la $3, 1
la $1, 32
la $2, -132119195
sltu $1,$1, $2
bne $1,$3, err

;slt
la $3, 0
la $1, 32
la $2, -132119195
slt $1, $1,$2
bne $1,$3, err

;nor
la $3, -44846
la $1, 36620
la $2, 8745
nor $1, $1,$2
bne $1,$3, err

;subu
la $3, 68169
la $1, 88535
la $2, 20366
subu $1,$1,$2
bne $1,$3, err
;subui
la $3, 58878
la $1,58874
subu $1, $1,-4
bne $1,$3, err

;srav
la $3, -219
la $1, -874
la $2, 2
sra $1,$1,$2
bne $1,$3, err
;sra
la $3, 919
la $1,58874
sra $1, $1,6
bne $1,$3, err

;srlv
la $3, 1073741605
la $1, -874
la $2, 2
srl $1,$1,$2
bne $1,$3, err
;sra
la $3, 1760
la $1,56327
srl $1, $1,5
bne $1,$3, err

;sll
la $3, -3496
la $1, -874
la $2, 2
sll $1,$1,$2
bne $1,$3, err
;sra
la $3, 1802464
la $1,56327
sll $1, $1,5
bne $1,$3, err



