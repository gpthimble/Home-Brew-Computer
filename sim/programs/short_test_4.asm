;test interrupt exceptino raw smc and multicycle instructions
err:
b test_1

;test 1
exc_1:          ;exception handle routine for test_1
move $5, $2
move $6, $3
move $30, $31
la $7, 433
la $8, 156
la $29, 554
bne $5, $7, err
bne $6, $8, err 
bne $30, $29, err ;check the cancel signal
la $1,  epc_1 
mfc0 $4, 3     ;cp0 register 3 is the epc register
bne $4, $1, err ;check epc
mfc0 $4, 0    ;cp0 register 0 is the cause register
la $5, 0x100000
bne $4, $5, err ;check cause
addu $1, $1, 20
mtc0 $1, 3
eret            ;exception return


test_1:         ;test for MEM stage exception (unaligned exception)
la $1, exc_1
mtc0 $1, 2     ;address of exception handle routine
la $2, 433
la $3, 156
la$31, 554
epc_1:
sh $2, data_1+1 ;this instrcution will trigger the exception
or $2, $0, 100      
or $3, $0, 100      ;these two instruction will be abandoned
or $31, $0,100
b err
eret_1:         ;exception returns here
b test_2
b err

exc_2:
la $3,2147483647
bne $2,$3,err   ;check wheather the addition is canceled
mfc0 $4, 0     ;cp0 register 0 is the cause register
la $5,0x800000
bne $4, $5, err ;check cause
mfc0 $1, 3           ;cp0 register 3 is the epc register    
addu $1, $1, 4
mtc0 $1, 3
eret            ;exception return


test_2:         ;test for EXE stage exception (overflow exception)
la $1, exc_2
mtc0 $1, 2     ;address of exception handle routine
la $2, 2147483647
addi $2, $2, 4  ;this instruction will trigger the overflow
eret_2:         ;exception returns here


test_3:         ;test for EXE stage SMC
la $1, 345
la $2, 544
sw $0, magic_3  ;this instruction will trigger the SMC at EXE stage
magic_3:
add $1, $1, $2 ;this instruction is now at the EXE stage
la $2, 345
bne $1, $2, err ;$1 should not be changed

test_4:         ;test for overflow and EXE_SMC happen at the same time
la $1, 2147483647
la $3, 2
sw $0, magic_4  ;this instruction will trigger the SMC at EXE stage
magic_4:
addi $1, $1, 45 ;this instruction will trigger the overflow
addu $3,$3, -1   
bne $3, $0, magic_4 ;check the sync mechanism in cache
la $2, 2147483647
bne $1, $2, err ;$1 should not be changed
b test_5

exc_5:        ;exception handler for test_5
mfc0 $4, 0     ;cp0 register 0 is the cause register
la $5, 0x4000000
bne $4, $5, err ;check cause      
mfc0 $1, 3     ;cp0 register 3 is the epc register
addu $1, $1, 4
la $4, 3
mtc0 $1, 3
eret    

test_5:         ;test for exceptions in ID stage
la $1, exc_5    ;BP_miss has higher priority
mtc0 $1, 2     ;address of exception handle routine
b magic_5a       ;this instruction will trigger the BP_miss
sh $1, data_5   ;this multi-cycle instruction should be cancled
magic_5a:
la $0, 3893
lw $1, data_5
bne $1, $0, err
b magic_5b      ;this will trigger another BP_miss
sw $1, data_5   ;this instruction will also be abandoned
magic_5b:
la $0, 3893
lw $1, data_5
bne $1, $0, err
                ;test ID_SMC
la $1, 543
sw $0, magic_5c ;this will trigger the SMC in ID stage
la $0, 344
magic_5c:
syscall         ;This exception should be canceled
mfc0 $1, 0
bne $1, $0, err
syscall         ;this will trigger the ID stage exception
eret_5:         ;the exception will return here
b test_6

exc_6:

mfc0 $4, 0     ;cp0 register 0 is the cause register
la $5, 0x20000000
bne $4, $5, err ;check cause
mfc0 $1, 3      ;cp0 register 3 is the epc register
addu $1, $1, 3
mtc0 $1, 3
eret    


test_6:         ;test for exceptions in IF stage
la $1, 3342     ;test IF_SMC
la $4, 2
sw $0, magic_6a
la $2,382
la $3,929
magic_6a:
addu $1, $1, $2
addu $4, $4, -1
bne $4, $0, magic_6a
la $2, 3342
bne $1,$2, err
                ;test IF unaligned exception
la $1, exc_6    ;BP_miss has higher priority
mtc0 $1, 2     ;address of exception handle routine
la $1, magic_6b+1
j $1            ;this instruction will trigger the mis aligned exception
magic_6b:
b err           ;this instruction will be skipped in the exception handler






#align 32
data_1:  ;data for test 1
#res 4
data_5:
#res 4