#align 32
$divu:
addu $sp,$sp,-8
sw $23,0#($sp)
sw $30,4#($sp)
la $30,1
move $23,$0
b Ldivmul$3
Ldivmul$2:
sll $5,$5,1
sll $30,$30,1
Ldivmul$3:
bgeu $5,$4,Ldivmul$6
beq $30,$0,Ldivmul$6
and $15,$5,0x80000000
beq $15,$0,Ldivmul$2
Ldivmul$6:
b Ldivmul$8
Ldivmul$7:
bltu $4,$5,Ldivmul$10
subu $4,$4,$5
or $23,$23,$30
Ldivmul$10:
srl $30,$30,1
srl $5,$5,1
Ldivmul$8:
bne $30,$0,Ldivmul$7
move $2,$23
Ldivmul$1:
lw $23,0#($sp)
lw $30,4#($sp)
addu $sp,$sp,8
j $31
#align 32
$remu:
addu $sp,$sp,-8
sw $23,0#($sp)
sw $30,4#($sp)
la $30,1
move $23,$0
b Ldivmul$17
Ldivmul$16:
sll $5,$5,1
sll $30,$30,1
Ldivmul$17:
bgeu $5,$4,Ldivmul$20
beq $30,$0,Ldivmul$20
and $15,$5,0x80000000
beq $15,$0,Ldivmul$16
Ldivmul$20:
b Ldivmul$22
Ldivmul$21:
bltu $4,$5,Ldivmul$24
subu $4,$4,$5
or $23,$23,$30
Ldivmul$24:
srl $30,$30,1
srl $5,$5,1
Ldivmul$22:
bne $30,$0,Ldivmul$21
move $2,$4
Ldivmul$15:
lw $23,0#($sp)
lw $30,4#($sp)
addu $sp,$sp,8
j $31
#align 32
$div:
addu $sp,$sp,-16
sw $21,0#($sp)
sw $22,4#($sp)
sw $23,8#($sp)
sw $30,12#($sp)
move $22,$0
move $23,$0
la $30,1
bge $4,$0,Ldivmul$30
negu $4,$4
bne $22,$0,Ldivmul$33
la $21,1
b Ldivmul$34
Ldivmul$33:
move $21,$0
Ldivmul$34:
move $22,$21
Ldivmul$30:
bge $5,$0,Ldivmul$41
negu $5,$5
bne $22,$0,Ldivmul$38
la $21,1
b Ldivmul$39
Ldivmul$38:
move $21,$0
Ldivmul$39:
move $22,$21
b Ldivmul$41
Ldivmul$40:
sll $5,$5,1
sll $30,$30,1
Ldivmul$41:
bge $5,$4,Ldivmul$44
beq $30,$0,Ldivmul$44
and $24,$5,0x80000000
beq $24,$0,Ldivmul$40
Ldivmul$44:
b Ldivmul$46
Ldivmul$45:
blt $4,$5,Ldivmul$48
subu $4,$4,$5
or $24,$23,$30
move $23,$24
Ldivmul$48:
srl $30,$30,1
sra $5,$5,1
Ldivmul$46:
bne $30,$0,Ldivmul$45
beq $22,$0,Ldivmul$50
negu $23,$23
Ldivmul$50:
move $2,$23
Ldivmul$29:
lw $21,0#($sp)
lw $22,4#($sp)
lw $23,8#($sp)
lw $30,12#($sp)
addu $sp,$sp,16
j $31
#align 32
$rem:
addu $sp,$sp,-16
sw $23,0#($sp)
sw $30,4#($sp)
sw $0,-4+16#($sp)
move $23,$0
la $30,1
bge $4,$0,Ldivmul$55
negu $4,$4
la $24,1
sw $24,-4+16#($sp)
Ldivmul$55:
bge $5,$0,Ldivmul$60
negu $5,$5
b Ldivmul$60
Ldivmul$59:
sll $5,$5,1
sll $30,$30,1
Ldivmul$60:
bge $5,$4,Ldivmul$63
beq $30,$0,Ldivmul$63
and $24,$5,0x80000000
beq $24,$0,Ldivmul$59
Ldivmul$63:
b Ldivmul$65
Ldivmul$64:
blt $4,$5,Ldivmul$67
subu $4,$4,$5
or $24,$23,$30
move $23,$24
Ldivmul$67:
srl $30,$30,1
sra $5,$5,1
Ldivmul$65:
bne $30,$0,Ldivmul$64
lw $24,-4+16#($sp)
beq $24,$0,Ldivmul$69
negu $4,$4
Ldivmul$69:
move $2,$4
Ldivmul$54:
lw $23,0#($sp)
lw $30,4#($sp)
addu $sp,$sp,16
j $31
#align 32
$mul:
addu $sp,$sp,-8
sw $30,0#($sp)
move $30,$0
b Ldivmul$75
Ldivmul$74:
and $24,$4,1
beq $24,$0,Ldivmul$77
addu $30,$30,$5
Ldivmul$77:
srl $4,$4,1
sll $5,$5,1
Ldivmul$75:
bne $4,$0,Ldivmul$74
move $2,$30
Ldivmul$73:
lw $30,0#($sp)
addu $sp,$sp,8
j $31
putchar:                ;putchar function
la $8, 0xFFFFFFF8       ;status port 
la $9, 0xFFFFFFFC       ;command and data port
p$start:
lw $10, ($8)            ;check the status port
bne $10, $0, p$start    ;if port is busy , wait
move $10, $4           ;load the char into register 10
or $10, $10, 0x100      ;prepare the write command
sw $10, ($9)            ;put char
j $31                   ;return
gettime:                ;gettime function accepts one argument as the index of the timer
beq $4,$0,gettime$0 
gettime$1:  
la $8, 0xFFFFFFF4       ;address of timer2
lw $2, ($8)
j $31
gettime$0:
la $8, 0xFFFFFFF0       ;address of timer1
lw $2, ($8)
j $31



