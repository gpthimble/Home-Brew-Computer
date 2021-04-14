la $1, 0xFFFFFFF8   ;status port 
la $2, 0xFFFFFFFC   ;command and data port
la $3, str          ;pointer of the string

start:
lw $4, ($1)         ;check the status port
bne $4, $0, start   ;if port is busy , wait
lbu $5, ($3)        ;load the char into register 5
beq $5, $0, end     ;end if reach the end of the string
or $5, $5, 0x100       ;prepare the command
sw $5, ($2)         ;put char
addu $3, $3, 1      ;pointer grew one byte
b start             ;process next char

str:
#d "Hello World!\n\0"
end: