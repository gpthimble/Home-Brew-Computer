$text:
#align 32
main:
addu $sp,$sp,-32
sw $31,16#($sp)
la $24,6
sw $24,-4+32#($sp)
la $24,7
sw $24,-8+32#($sp)
lw $4,-4+32#($sp)
lw $5,-8+32#($sp)
jal $mul
sw $2,-12+32#($sp)
lw $2,-12+32#($sp)
L$1:
lw $31,16#($sp)
addu $sp,$sp,32
j $31
$mul:
addu $sp,$sp,-8
sw $30,0#($sp)
move $30,$0
b L$75
L$74:
and $24,$4,1
beq $24,$0,L$77
addu $30,$30,$5
L$77:
srl $4,$4,1
sll $5,$5,1
L$75:
bne $4,$0,L$74
move $2,$30
L$73:
lw $30,0#($sp)
addu $sp,$sp,8
j $31


$sdata:

$data:

$rdata:

$bss:
