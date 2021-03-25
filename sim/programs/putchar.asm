putchar:
la $8, 0xFFFFFFF8       ;status port 
la $9, 0xFFFFFFFC       ;command and data port
p$start:
lw $10, ($8)            ;check the status port
bne $10, $0, p$start    ;if port is busy , wait
move $10, $4           ;load the char into register 10
or $10, $10, 0x100      ;prepare the write command
sw $10, ($9)            ;put char
j $31                   ;return

