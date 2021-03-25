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

