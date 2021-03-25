$text:
la $sp, 32760
#align 32
main:
addu $sp,$sp,-232
sw $19,16#($sp)
sw $20,20#($sp)
sw $21,24#($sp)
sw $22,28#($sp)
sw $23,32#($sp)
sw $30,36#($sp)
sw $31,40#($sp)
la $20,10
sw $0,-80+232#($sp)
la $24,1
sw $24,-84+232#($sp)
la $4,L$7
jal printstr
la $24,-132+232#($sp)
sw $24,Next_Ptr_Glob
la $24,-180+232#($sp)
sw $24,Ptr_Glob
lw $24,Ptr_Glob
lw $15,Next_Ptr_Glob
sw $15,($24)
lw $24,Ptr_Glob
sw $0,4#($24)
lw $24,Ptr_Glob
la $15,2
sw $15,8#($24)
lw $24,Ptr_Glob
la $15,40
sw $15,12#($24)
lw $24,Ptr_Glob
la $4,16#($24)
la $5,L$8
jal strcpy
la $4,-74+232#($sp)
la $5,L$9
jal strcpy
la $24,10
sw $24,Arr_2_Glob+1600+28
la $4,L$12
jal printstr
la $4,L$13
jal printstr
la $4,L$14
jal printstr
la $4,L$12
jal printstr
la $4,L$15
jal printstr
la $4,Reg_Define
la $5,L$16
jal strcpy
la $21,50000
L$17:
subu $20,$20,1
la $24,10
sw $24,Arr_2_Glob+1600+28
move $4,$0
jal gettime
sw $2,start_time
la $22,1
b L$25
L$22:
jal Proc_5
jal Proc_4
la $24,2
sw $24,-4+232#($sp)
la $30,3
la $4,-43+232#($sp)
la $5,L$26
jal strcpy
la $24,1
sw $24,-12+232#($sp)
la $4,-74+232#($sp)
la $5,-43+232#($sp)
jal Func_2
move $24,$2
bne $24,$0,L$28
la $19,1
b L$29
L$28:
move $19,$0
L$29:
sw $19,Bool_Glob
b L$31
L$30:
lw $24,-4+232#($sp)
sw $24,-184+232#($sp)
la $4,5
move $5,$24
jal $mul
subu $24,$2,$30
sw $24,-8+232#($sp)
lw $24,-184+232#($sp)
move $4,$24
move $5,$30
la $6,-8+232#($sp)
jal Proc_7
lw $24,-4+232#($sp)
la $24,1#($24)
sw $24,-4+232#($sp)
L$31:
lw $24,-4+232#($sp)
blt $24,$30,L$30
la $4,Arr_1_Glob
la $5,Arr_2_Glob
lw $6,-4+232#($sp)
lw $7,-8+232#($sp)
jal Proc_8
lw $4,Ptr_Glob
jal Proc_1
la $23,65
b L$36
L$33:
sll $4,$23,24
sra $4,$4,24
la $5,67
jal Func_1
lw $15,-12+232#($sp)
bne $15,$2,L$37
move $4,$0
la $5,-12+232#($sp)
jal Proc_6
la $4,-43+232#($sp)
la $5,L$39
jal strcpy
move $30,$22
sw $22,Int_Glob
L$37:
L$34:
sll $24,$23,24
sra $24,$24,24
la $24,1#($24)
move $23,$24
L$36:
sll $24,$23,24
sra $24,$24,24
lb $15,Ch_2_Glob
ble $24,$15,L$33
move $4,$30
lw $5,-4+232#($sp)
jal $mul
move $30,$2
lw $24,-8+232#($sp)
sw $24,-184+232#($sp)
move $4,$30
move $5,$24
jal $div
sw $2,-4+232#($sp)
la $4,7
lw $24,-184+232#($sp)
subu $5,$30,$24
jal $mul
move $24,$2
lw $15,-4+232#($sp)
subu $30,$24,$15
la $4,-4+232#($sp)
jal Proc_2
L$23:
la $22,1#($22)
L$25:
ble $22,$21,L$22
move $4,$0
jal gettime
lw $15,start_time
subu $24,$2,$15
sw $24,Microseconds
move $4,$21
la $5,10
jal printnum
la $4,L$40
jal printstr
lw $4,Microseconds
la $5,10
jal printnum
la $4,L$41
jal printstr
lw $24,Microseconds
la $15,200000
ble $24,$15,L$42
move $20,$0
b L$43
L$42:
lw $24,Microseconds
la $15,100
bge $24,$15,L$44
la $4,5
move $5,$21
jal $mul
move $21,$2
L$44:
L$43:
L$18:
bgt $20,$0,L$17
lw $4,Microseconds
la $5,1000000
jal $div
move $24,$2
sw $24,User_Time
la $4,L$12
jal printstr
la $4,L$46
jal printstr
la $4,L$12
jal printstr
la $4,L$47
jal printstr
lw $24,Int_Glob
la $15,5
bne $24,$15,L$48
la $4,L$50
jal printstr
b L$49
L$48:
la $4,L$51
jal printstr
L$49:
lw $4,Int_Glob
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$53
jal printstr
lw $24,Bool_Glob
la $15,1
bne $24,$15,L$54
la $4,L$50
jal printstr
b L$55
L$54:
la $4,L$51
jal printstr
L$55:
lw $4,Bool_Glob
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$56
jal printstr
lb $24,Ch_1_Glob
la $15,65
bne $24,$15,L$57
la $4,L$50
jal printstr
b L$58
L$57:
la $4,L$51
jal printstr
L$58:
lb $4,Ch_1_Glob
jal putchar
la $4,L$52
jal printstr
la $4,L$59
jal printstr
lb $24,Ch_2_Glob
la $15,66
bne $24,$15,L$60
la $4,L$50
jal printstr
b L$61
L$60:
la $4,L$51
jal printstr
L$61:
lb $4,Ch_2_Glob
jal putchar
la $4,L$12
jal printstr
la $4,L$62
jal printstr
lw $24,Arr_1_Glob+32
la $15,7
bne $24,$15,L$63
la $4,L$50
jal printstr
b L$64
L$63:
la $4,L$51
jal printstr
L$64:
lw $4,Arr_1_Glob+32
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$67
jal printstr
lw $24,Arr_2_Glob+1600+28
la $15,10#($21)
bne $24,$15,L$68
la $4,L$50
jal printstr
b L$69
L$68:
la $4,L$51
jal printstr
L$69:
lw $4,Arr_2_Glob+1600+28
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$74
jal printstr
la $4,L$75
jal printstr
lw $24,Ptr_Glob
lw $24,($24)
move $4,$24
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$76
jal printstr
lw $24,Ptr_Glob
lw $24,4#($24)
bne $24,$0,L$77
la $4,L$50
jal printstr
b L$78
L$77:
la $4,L$51
jal printstr
L$78:
lw $24,Ptr_Glob
lw $4,4#($24)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$79
jal printstr
lw $24,Ptr_Glob
lw $24,8#($24)
la $15,2
bne $24,$15,L$80
la $4,L$50
jal printstr
b L$81
L$80:
la $4,L$51
jal printstr
L$81:
lw $24,Ptr_Glob
lw $4,8#($24)
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$82
jal printstr
lw $24,Ptr_Glob
lw $24,12#($24)
la $15,17
bne $24,$15,L$83
la $4,L$50
jal printstr
b L$84
L$83:
la $4,L$51
jal printstr
L$84:
lw $24,Ptr_Glob
lw $4,12#($24)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$85
jal printstr
lw $24,Ptr_Glob
la $4,16#($24)
la $5,L$8
jal strcmp
bne $2,$0,L$86
la $4,L$50
jal printstr
b L$87
L$86:
la $4,L$51
jal printstr
L$87:
lw $24,Ptr_Glob
la $4,16#($24)
jal printstr
la $4,L$12
jal printstr
la $4,L$88
jal printstr
la $4,L$75
jal printstr
lw $24,Next_Ptr_Glob
lw $24,($24)
move $4,$24
la $5,10
jal printnum
la $4,L$89
jal printstr
la $4,L$76
jal printstr
lw $24,Next_Ptr_Glob
lw $24,4#($24)
bne $24,$0,L$90
la $4,L$50
jal printstr
b L$91
L$90:
la $4,L$51
jal printstr
L$91:
lw $24,Next_Ptr_Glob
lw $4,4#($24)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$79
jal printstr
lw $24,Next_Ptr_Glob
lw $24,8#($24)
la $15,1
bne $24,$15,L$92
la $4,L$50
jal printstr
b L$93
L$92:
la $4,L$51
jal printstr
L$93:
lw $24,Next_Ptr_Glob
lw $4,8#($24)
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$82
jal printstr
lw $24,Next_Ptr_Glob
lw $24,12#($24)
la $15,18
bne $24,$15,L$94
la $4,L$50
jal printstr
b L$95
L$94:
la $4,L$51
jal printstr
L$95:
lw $24,Next_Ptr_Glob
lw $4,12#($24)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$85
jal printstr
lw $24,Next_Ptr_Glob
la $4,16#($24)
la $5,L$8
jal strcmp
bne $2,$0,L$96
la $4,L$50
jal printstr
b L$97
L$96:
la $4,L$51
jal printstr
L$97:
lw $24,Next_Ptr_Glob
la $4,16#($24)
jal printstr
la $4,L$12
jal printstr
la $4,L$98
jal printstr
lw $24,-4+232#($sp)
la $15,5
bne $24,$15,L$99
la $4,L$50
jal printstr
b L$100
L$99:
la $4,L$51
jal printstr
L$100:
lw $4,-4+232#($sp)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$101
jal printstr
la $24,13
bne $30,$24,L$102
la $4,L$50
jal printstr
b L$103
L$102:
la $4,L$51
jal printstr
L$103:
move $4,$30
la $5,10
jal printnum
la $4,L$12
jal printstr
la $4,L$104
jal printstr
lw $24,-8+232#($sp)
la $15,7
bne $24,$15,L$105
la $4,L$50
jal printstr
b L$106
L$105:
la $4,L$51
jal printstr
L$106:
lw $4,-8+232#($sp)
la $5,10
jal printnum
la $4,L$52
jal printstr
la $4,L$107
jal printstr
lw $24,-12+232#($sp)
la $15,1
bne $24,$15,L$108
la $4,L$50
jal printstr
b L$109
L$108:
la $4,L$51
jal printstr
L$109:
lw $4,-12+232#($sp)
la $5,10
jal printnum
la $4,L$110
jal printstr
la $4,L$111
jal printstr
la $4,-74+232#($sp)
la $5,L$9
jal strcmp
bne $2,$0,L$112
la $4,L$50
jal printstr
b L$113
L$112:
la $4,L$51
jal printstr
L$113:
la $4,-74+232#($sp)
jal printstr
la $4,L$12
jal printstr
la $4,L$114
jal printstr
la $4,-43+232#($sp)
la $5,L$26
jal strcmp
bne $2,$0,L$115
la $4,L$50
jal printstr
b L$116
L$115:
la $4,L$51
jal printstr
L$116:
la $4,-43+232#($sp)
jal printstr
la $4,L$12
jal printstr
la $4,L$12
jal printstr
lw $24,User_Time
la $15,2
bge $24,$15,L$117
la $4,L$119
jal printstr
la $4,L$120
jal printstr
la $4,L$12
jal printstr
b L$126
L$117:
lw $24,User_Time
sw $24,-184+232#($sp)
la $4,1000000
move $5,$24
jal $mul
move $24,$2
move $4,$24
move $5,$21
jal $div
sw $2,Microseconds
move $4,$21
lw $24,-184+232#($sp)
move $5,$24
jal $div
move $24,$2
sw $24,Dhrystones_Per_Second
lw $4,Dhrystones_Per_Second
la $5,1757
jal $div
move $24,$2
sw $24,Vax_Mips
la $4,L$121
jal printstr
lw $4,Microseconds
la $5,10
jal printnum
la $4,L$122
jal printstr
la $4,L$123
jal printstr
lw $4,Dhrystones_Per_Second
la $5,10
jal printnum
la $4,L$122
jal printstr
la $4,L$124
jal printstr
lw $4,Vax_Mips
la $5,10
jal printnum
la $4,L$122
jal printstr
la $4,L$12
jal printstr
L$125:
L$126:
b L$125
L$6:
lw $19,16#($sp)
lw $20,20#($sp)
lw $21,24#($sp)
lw $22,28#($sp)
lw $23,32#($sp)
lw $30,36#($sp)
lw $31,40#($sp)
addu $sp,$sp,232
j $31
#align 32
Proc_1:
addu $sp,$sp,-32
sw $23,16#($sp)
sw $30,20#($sp)
sw $31,24#($sp)
move $30,$4
lw $23,($30)
lw $24,($30)
lw $8,Ptr_Glob
addu $8,$8,48
addu $10,$24,48
L$161:
addu $8,$8,-8
addu $10,$10,-8
lw $3,0#($8)
lw $9,4#($8)
sw $3,0#($10)
sw $9,4#($10)
bltu $24,$10,L$161
la $24,5
sw $24,12#($30)
lw $24,12#($30)
sw $24,12#($23)
lw $24,($30)
sw $24,($23)
move $4,$23
jal Proc_3
lw $24,4#($23)
bne $24,$0,L$156
la $24,6
sw $24,12#($23)
lw $4,8#($30)
la $5,8#($23)
jal Proc_6
lw $24,Ptr_Glob
lw $24,($24)
sw $24,($23)
la $24,12#($23)
lw $4,12#($23)
la $5,10
move $6,$24
jal Proc_7
b L$157
L$156:
lw $8,($30)
addu $8,$8,48
addu $10,$30,48
L$162:
addu $8,$8,-8
addu $10,$10,-8
lw $3,0#($8)
lw $9,4#($8)
sw $3,0#($10)
sw $9,4#($10)
bltu $30,$10,L$162
L$157:
L$155:
lw $23,16#($sp)
lw $30,20#($sp)
lw $31,24#($sp)
addu $sp,$sp,32
j $31
#align 32
Proc_2:
addu $sp,$sp,-8
sw $23,0#($sp)
sw $30,4#($sp)
lw $24,($4)
la $23,10#($24)
L$164:
lb $24,Ch_1_Glob
la $15,65
bne $24,$15,L$167
subu $23,$23,1
lw $24,Int_Glob
subu $24,$23,$24
sw $24,($4)
move $30,$0
L$167:
L$165:
bne $30,$0,L$164
L$163:
lw $23,0#($sp)
lw $30,4#($sp)
addu $sp,$sp,8
j $31
#align 32
Proc_3:
addu $sp,$sp,-24
sw $31,16#($sp)
sw $4,24#($sp)
lw $24,Ptr_Glob
beq $24,$0,L$170
lw $24,0+24#($sp)
lw $15,Ptr_Glob
lw $15,($15)
sw $15,($24)
L$170:
la $4,10
lw $5,Int_Glob
lw $24,Ptr_Glob
la $6,12#($24)
jal Proc_7
L$169:
lw $31,16#($sp)
addu $sp,$sp,24
j $31
#align 32
Proc_4:
addu $sp,$sp,-8
sw $30,0#($sp)
lb $24,Ch_1_Glob
la $15,65
bne $24,$15,L$174
la $30,1
b L$175
L$174:
move $30,$0
L$175:
sw $30,-4+8#($sp)
lw $24,-4+8#($sp)
lw $15,Bool_Glob
or $24,$24,$15
sw $24,Bool_Glob
la $24,66
sb $24,Ch_2_Glob
L$172:
lw $30,0#($sp)
addu $sp,$sp,8
j $31
#align 32
Proc_5:
la $24,65
sb $24,Ch_1_Glob
sw $0,Bool_Glob
L$177:
j $31
#align 32
Proc_6:
addu $sp,$sp,-32
sw $23,16#($sp)
sw $30,20#($sp)
sw $31,24#($sp)
sw $4,32#($sp)
sw $5,36#($sp)
lw $30,0+32#($sp)
lw $24,4+32#($sp)
sw $30,($24)
move $4,$30
jal Func_3
bne $2,$0,L$179
lw $24,4+32#($sp)
la $15,3
sw $15,($24)
L$179:
move $23,$30
blt $23,$0,L$181
la $24,4
bgt $23,$24,L$181
sll $24,$23,2
lw $24,L$191#($24)
j $24
L$184:
lw $24,4+32#($sp)
sw $0,($24)
b L$182
L$185:
lw $24,Int_Glob
la $15,100
ble $24,$15,L$186
lw $24,4+32#($sp)
sw $0,($24)
b L$182
L$186:
lw $24,4+32#($sp)
la $15,3
sw $15,($24)
b L$182
L$188:
lw $24,4+32#($sp)
la $15,1
sw $15,($24)
b L$182
L$190:
lw $24,4+32#($sp)
la $15,2
sw $15,($24)
L$181:
L$182:
L$178:
lw $23,16#($sp)
lw $30,20#($sp)
lw $31,24#($sp)
addu $sp,$sp,32
j $31
#align 32
Proc_7:
addu $sp,$sp,-8
la $24,2#($4)
sw $24,-4+8#($sp)
lw $24,-4+8#($sp)
addu $24,$5,$24
sw $24,($6)
L$193:
addu $sp,$sp,8
j $31
#align 32
Proc_8:
addu $sp,$sp,-40
sw $21,16#($sp)
sw $22,20#($sp)
sw $23,24#($sp)
sw $30,28#($sp)
sw $31,32#($sp)
move $30,$4
move $23,$5
sw $6,48#($sp)
sw $7,52#($sp)
lw $24,8+40#($sp)
la $22,5#($24)
sll $24,$22,2
addu $24,$24,$30
lw $15,12+40#($sp)
sw $15,($24)
sll $24,$22,2
la $15,4#($24)
addu $15,$15,$30
addu $24,$24,$30
lw $24,($24)
sw $24,($15)
sll $24,$22,2
la $24,120#($24)
addu $24,$24,$30
sw $22,($24)
move $21,$22
b L$198
L$195:
la $4,200
move $5,$22
jal $mul
sll $15,$21,2
addu $24,$2,$23
addu $24,$15,$24
sw $22,($24)
L$196:
la $21,1#($21)
L$198:
la $24,1#($22)
ble $21,$24,L$195
la $4,200
move $5,$22
jal $mul
sll $15,$22,2
subu $15,$15,4
addu $24,$2,$23
addu $24,$15,$24
lw $15,($24)
la $15,1#($15)
sw $15,($24)
la $4,200
move $5,$22
jal $mul
sll $15,$22,2
la $24,4000#($2)
addu $24,$24,$23
addu $24,$15,$24
addu $15,$15,$30
lw $15,($15)
sw $15,($24)
la $24,5
sw $24,Int_Glob
L$194:
lw $21,16#($sp)
lw $22,20#($sp)
lw $23,24#($sp)
lw $30,28#($sp)
lw $31,32#($sp)
addu $sp,$sp,40
j $31
#align 32
Func_1:
addu $sp,$sp,-8
sb $4,-1+8#($sp)
lb $24,-1+8#($sp)
sb $24,-2+8#($sp)
lb $24,-2+8#($sp)
sll $15,$5,24
sra $15,$15,24
beq $24,$15,L$206
move $2,$0
b L$205
L$206:
lb $24,-1+8#($sp)
sb $24,Ch_1_Glob
la $2,1
L$205:
addu $sp,$sp,8
j $31
#align 32
Func_2:
addu $sp,$sp,-40
sw $21,16#($sp)
sw $22,20#($sp)
sw $23,24#($sp)
sw $30,28#($sp)
sw $31,32#($sp)
move $30,$4
move $23,$5
la $22,2
b L$210
L$209:
addu $24,$22,$30
lb $4,($24)
la $24,1#($22)
addu $24,$24,$23
lb $5,($24)
jal Func_1
bne $2,$0,L$212
la $21,65
la $22,1#($22)
L$212:
L$210:
la $24,2
ble $22,$24,L$209
sll $24,$21,24
sra $24,$24,24
la $15,87
blt $24,$15,L$214
la $15,90
bge $24,$15,L$214
la $22,7
L$214:
sll $24,$21,24
sra $24,$24,24
la $15,82
bne $24,$15,L$216
la $2,1
b L$208
L$216:
move $4,$30
move $5,$23
jal strcmp
ble $2,$0,L$218
la $22,7#($22)
sw $22,Int_Glob
la $2,1
b L$208
L$218:
move $2,$0
L$208:
lw $21,16#($sp)
lw $22,20#($sp)
lw $23,24#($sp)
lw $30,28#($sp)
lw $31,32#($sp)
addu $sp,$sp,40
j $31
#align 32
Func_3:
addu $sp,$sp,-8
sw $4,-4+8#($sp)
lw $24,-4+8#($sp)
la $15,2
bne $24,$15,L$224
la $2,1
b L$223
L$224:
move $2,$0
L$223:
addu $sp,$sp,8
j $31
#align 32
printstr:
addu $sp,$sp,-32
sw $23,16#($sp)
sw $30,20#($sp)
sw $31,24#($sp)
move $30,$4
lb $23,($30)
b L$228
L$227:
sll $24,$23,24
sra $24,$24,24
la $15,10
bne $24,$15,L$230
la $4,10
jal putchar
la $4,13
jal putchar
b L$231
L$230:
sll $4,$23,24
sra $4,$4,24
jal putchar
L$231:
la $30,1#($30)
lb $23,($30)
L$228:
sll $24,$23,24
sra $24,$24,24
bne $24,$0,L$227
L$226:
lw $23,16#($sp)
lw $30,20#($sp)
lw $31,24#($sp)
addu $sp,$sp,32
j $31
#align 32
printnum:
addu $sp,$sp,-56
sw $31,16#($sp)
sw $4,56#($sp)
sw $5,60#($sp)
lw $4,0+56#($sp)
la $5,-33+56#($sp)
lw $6,4+56#($sp)
jal itoa
la $4,-33+56#($sp)
jal printstr
L$232:
lw $31,16#($sp)
addu $sp,$sp,56
j $31
#align 32
swap:
addu $sp,$sp,-8
lb $24,($4)
sb $24,-1+8#($sp)
lb $24,($5)
sb $24,($4)
lb $24,-1+8#($sp)
sb $24,($5)
L$233:
addu $sp,$sp,8
j $31
#align 32
reverse:
addu $sp,$sp,-32
sw $22,16#($sp)
sw $23,20#($sp)
sw $30,24#($sp)
sw $31,28#($sp)
move $30,$4
move $23,$5
move $22,$6
b L$236
L$235:
move $24,$23
la $23,1#($24)
addu $4,$24,$30
move $24,$22
subu $22,$24,1
addu $5,$24,$30
jal swap
L$236:
blt $23,$22,L$235
move $2,$30
L$234:
lw $22,16#($sp)
lw $23,20#($sp)
lw $30,24#($sp)
lw $31,28#($sp)
addu $sp,$sp,32
j $31
#align 32
itoa:
addu $sp,$sp,-40
sw $20,16#($sp)
sw $21,20#($sp)
sw $22,24#($sp)
sw $23,28#($sp)
sw $30,32#($sp)
sw $31,36#($sp)
sw $4,40#($sp)
move $30,$5
move $23,$6
lw $4,0+40#($sp)
jal abs
move $22,$2
move $20,$0
move $21,$0
la $24,2
blt $23,$24,L$244
la $24,32
ble $23,$24,L$246
L$244:
move $2,$30
b L$241
L$245:
move $4,$22
move $5,$23
jal $rem
move $21,$2
la $24,10
blt $21,$24,L$248
move $24,$20
la $20,1#($24)
addu $24,$24,$30
subu $15,$21,10
la $15,65#($15)
sb $15,($24)
b L$249
L$248:
move $24,$20
la $20,1#($24)
addu $24,$24,$30
la $15,48#($21)
sb $15,($24)
L$249:
move $4,$22
move $5,$23
jal $div
move $22,$2
L$246:
bne $22,$0,L$245
bne $20,$0,L$250
move $24,$20
la $20,1#($24)
addu $24,$24,$30
la $15,48
sb $15,($24)
L$250:
lw $24,0+40#($sp)
bge $24,$0,L$252
la $24,10
bne $23,$24,L$252
move $24,$20
la $20,1#($24)
addu $24,$24,$30
la $15,45
sb $15,($24)
L$252:
addu $24,$20,$30
sb $0,($24)
move $4,$30
move $5,$0
subu $6,$20,1
jal reverse
move $24,$2
L$241:
lw $20,16#($sp)
lw $21,20#($sp)
lw $22,24#($sp)
lw $23,28#($sp)
lw $30,32#($sp)
lw $31,36#($sp)
addu $sp,$sp,40
j $31
#align 32
abs:
addu $sp,$sp,-8
sw $30,0#($sp)
bge $4,$0,L$264
negu $30,$4
b L$265
L$264:
move $30,$4
L$265:
move $2,$30
L$262:
lw $30,0#($sp)
addu $sp,$sp,8
j $31
#align 32
strcmp:
b L$268
L$267:
lb $24,($4)
lb $15,($5)
beq $24,$15,L$270
b L$269
L$270:
la $4,1#($4)
la $5,1#($5)
L$268:
lb $24,($4)
bne $24,$0,L$267
L$269:
lbu $24,($4)
lbu $15,($5)
subu $2,$24,$15
L$266:
j $31
#align 32
strcpy:
addu $sp,$sp,-8
sw $4,-4+8#($sp)
bne $4,$0,L$277
move $2,$0
b L$273
L$276:
lb $24,($5)
sb $24,($4)
la $4,1#($4)
la $5,1#($5)
L$277:
lb $24,($5)
bne $24,$0,L$276
sb $0,($4)
lw $24,-4+8#($sp)
move $2,$24
L$273:
addu $sp,$sp,8
j $31
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




$sdata:

$data:
#align 8
Reg_Define:
#d8 82
#d8 101
#d8 103
#d8 105
#d8 115
#d8 116
#d8 101
#d8 114
#d8 32
#d8 111
#d8 112
#d8 116
#d8 105
#d8 111
#d8 110
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 83
#d8 101
#d8 108
#d8 101
#d8 99
#d8 116
#d8 101
#d8 100
#d8 46
#d8 0
#res 9

$rdata:
#align 32
L$191:
#d32 L$184
#d32 L$185
#d32 L$188
#d32 L$182
#d32 L$190
#align 8
L$124:
#d8 86
#d8 65
#d8 88
#d8 32
#d8 32
#d8 77
#d8 73
#d8 80
#d8 83
#d8 32
#d8 114
#d8 97
#d8 116
#d8 105
#d8 110
#d8 103
#d8 32
#d8 61
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$123:
#d8 68
#d8 104
#d8 114
#d8 121
#d8 115
#d8 116
#d8 111
#d8 110
#d8 101
#d8 115
#d8 32
#d8 112
#d8 101
#d8 114
#d8 32
#d8 83
#d8 101
#d8 99
#d8 111
#d8 110
#d8 100
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$122:
#d8 32
#d8 10
#d8 0
#align 8
L$121:
#d8 77
#d8 105
#d8 99
#d8 114
#d8 111
#d8 115
#d8 101
#d8 99
#d8 111
#d8 110
#d8 100
#d8 115
#d8 32
#d8 102
#d8 111
#d8 114
#d8 32
#d8 111
#d8 110
#d8 101
#d8 32
#d8 114
#d8 117
#d8 110
#d8 32
#d8 116
#d8 104
#d8 114
#d8 111
#d8 117
#d8 103
#d8 104
#d8 32
#d8 68
#d8 104
#d8 114
#d8 121
#d8 115
#d8 116
#d8 111
#d8 110
#d8 101
#d8 58
#d8 32
#d8 0
#align 8
L$120:
#d8 80
#d8 108
#d8 101
#d8 97
#d8 115
#d8 101
#d8 32
#d8 105
#d8 110
#d8 99
#d8 114
#d8 101
#d8 97
#d8 115
#d8 101
#d8 32
#d8 110
#d8 117
#d8 109
#d8 98
#d8 101
#d8 114
#d8 32
#d8 111
#d8 102
#d8 32
#d8 114
#d8 117
#d8 110
#d8 115
#d8 10
#d8 0
#align 8
L$119:
#d8 77
#d8 101
#d8 97
#d8 115
#d8 117
#d8 114
#d8 101
#d8 100
#d8 32
#d8 116
#d8 105
#d8 109
#d8 101
#d8 32
#d8 116
#d8 111
#d8 111
#d8 32
#d8 115
#d8 109
#d8 97
#d8 108
#d8 108
#d8 32
#d8 116
#d8 111
#d8 32
#d8 111
#d8 98
#d8 116
#d8 97
#d8 105
#d8 110
#d8 32
#d8 109
#d8 101
#d8 97
#d8 110
#d8 105
#d8 110
#d8 103
#d8 102
#d8 117
#d8 108
#d8 32
#d8 114
#d8 101
#d8 115
#d8 117
#d8 108
#d8 116
#d8 115
#d8 10
#d8 0
#align 8
L$114:
#d8 83
#d8 116
#d8 114
#d8 95
#d8 50
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$111:
#d8 83
#d8 116
#d8 114
#d8 95
#d8 49
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$110:
#d8 32
#d8 32
#d8 10
#d8 0
#align 8
L$107:
#d8 69
#d8 110
#d8 117
#d8 109
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$104:
#d8 73
#d8 110
#d8 116
#d8 95
#d8 51
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$101:
#d8 73
#d8 110
#d8 116
#d8 95
#d8 50
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$98:
#d8 73
#d8 110
#d8 116
#d8 95
#d8 49
#d8 95
#d8 76
#d8 111
#d8 99
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$89:
#d8 32
#d8 115
#d8 97
#d8 109
#d8 101
#d8 32
#d8 97
#d8 115
#d8 32
#d8 97
#d8 98
#d8 111
#d8 118
#d8 101
#d8 10
#d8 0
#align 8
L$88:
#d8 78
#d8 101
#d8 120
#d8 116
#d8 95
#d8 80
#d8 116
#d8 114
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 45
#d8 62
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$85:
#d8 83
#d8 116
#d8 114
#d8 95
#d8 67
#d8 111
#d8 109
#d8 112
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$82:
#d8 32
#d8 32
#d8 73
#d8 110
#d8 116
#d8 95
#d8 67
#d8 111
#d8 109
#d8 112
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$79:
#d8 69
#d8 110
#d8 117
#d8 109
#d8 95
#d8 67
#d8 111
#d8 109
#d8 112
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$76:
#d8 32
#d8 32
#d8 68
#d8 105
#d8 115
#d8 99
#d8 114
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$75:
#d8 32
#d8 32
#d8 80
#d8 116
#d8 114
#d8 95
#d8 67
#d8 111
#d8 109
#d8 112
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 42
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$74:
#d8 80
#d8 116
#d8 114
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 45
#d8 62
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$67:
#d8 65
#d8 114
#d8 114
#d8 95
#d8 50
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 56
#d8 47
#d8 55
#d8 58
#d8 32
#d8 0
#align 8
L$62:
#d8 65
#d8 114
#d8 114
#d8 95
#d8 49
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 91
#d8 56
#d8 93
#d8 58
#d8 32
#d8 0
#align 8
L$59:
#d8 67
#d8 104
#d8 95
#d8 50
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$56:
#d8 67
#d8 104
#d8 95
#d8 49
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$53:
#d8 66
#d8 111
#d8 111
#d8 108
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$52:
#d8 32
#d8 32
#d8 0
#align 8
L$51:
#d8 87
#d8 82
#d8 79
#d8 78
#d8 71
#d8 32
#d8 0
#align 8
L$50:
#d8 79
#d8 46
#d8 75
#d8 46
#d8 32
#d8 32
#d8 0
#align 8
L$47:
#d8 73
#d8 110
#d8 116
#d8 95
#d8 71
#d8 108
#d8 111
#d8 98
#d8 58
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$46:
#d8 70
#d8 105
#d8 110
#d8 97
#d8 108
#d8 32
#d8 118
#d8 97
#d8 108
#d8 117
#d8 101
#d8 115
#d8 32
#d8 40
#d8 42
#d8 32
#d8 105
#d8 109
#d8 112
#d8 108
#d8 101
#d8 109
#d8 101
#d8 110
#d8 116
#d8 97
#d8 116
#d8 105
#d8 111
#d8 110
#d8 45
#d8 100
#d8 101
#d8 112
#d8 101
#d8 110
#d8 100
#d8 101
#d8 110
#d8 116
#d8 41
#d8 58
#d8 10
#d8 0
#align 8
L$41:
#d8 32
#d8 109
#d8 105
#d8 99
#d8 114
#d8 111
#d8 32
#d8 115
#d8 101
#d8 99
#d8 111
#d8 110
#d8 100
#d8 115
#d8 32
#d8 10
#d8 0
#align 8
L$40:
#d8 32
#d8 114
#d8 117
#d8 110
#d8 115
#d8 32
#d8 0
#align 8
L$39:
#d8 68
#d8 72
#d8 82
#d8 89
#d8 83
#d8 84
#d8 79
#d8 78
#d8 69
#d8 32
#d8 80
#d8 82
#d8 79
#d8 71
#d8 82
#d8 65
#d8 77
#d8 44
#d8 32
#d8 51
#d8 39
#d8 82
#d8 68
#d8 32
#d8 83
#d8 84
#d8 82
#d8 73
#d8 78
#d8 71
#d8 0
#align 8
L$26:
#d8 68
#d8 72
#d8 82
#d8 89
#d8 83
#d8 84
#d8 79
#d8 78
#d8 69
#d8 32
#d8 80
#d8 82
#d8 79
#d8 71
#d8 82
#d8 65
#d8 77
#d8 44
#d8 32
#d8 50
#d8 39
#d8 78
#d8 68
#d8 32
#d8 83
#d8 84
#d8 82
#d8 73
#d8 78
#d8 71
#d8 0
#align 8
L$16:
#d8 82
#d8 101
#d8 103
#d8 105
#d8 115
#d8 116
#d8 101
#d8 114
#d8 32
#d8 111
#d8 112
#d8 116
#d8 105
#d8 111
#d8 110
#d8 32
#d8 32
#d8 78
#d8 111
#d8 116
#d8 32
#d8 115
#d8 101
#d8 108
#d8 101
#d8 99
#d8 116
#d8 101
#d8 100
#d8 46
#d8 0
#align 8
L$15:
#d8 82
#d8 101
#d8 103
#d8 105
#d8 115
#d8 116
#d8 101
#d8 114
#d8 32
#d8 111
#d8 112
#d8 116
#d8 105
#d8 111
#d8 110
#d8 32
#d8 110
#d8 111
#d8 116
#d8 32
#d8 115
#d8 101
#d8 108
#d8 101
#d8 99
#d8 116
#d8 101
#d8 100
#d8 10
#d8 10
#d8 0
#align 8
L$14:
#d8 78
#d8 111
#d8 110
#d8 45
#d8 111
#d8 112
#d8 116
#d8 105
#d8 109
#d8 105
#d8 115
#d8 101
#d8 100
#d8 0
#align 8
L$13:
#d8 79
#d8 112
#d8 116
#d8 105
#d8 109
#d8 105
#d8 115
#d8 97
#d8 116
#d8 105
#d8 111
#d8 110
#d8 32
#d8 32
#d8 32
#d8 32
#d8 0
#align 8
L$12:
#d8 10
#d8 0
#align 8
L$9:
#d8 68
#d8 72
#d8 82
#d8 89
#d8 83
#d8 84
#d8 79
#d8 78
#d8 69
#d8 32
#d8 80
#d8 82
#d8 79
#d8 71
#d8 82
#d8 65
#d8 77
#d8 44
#d8 32
#d8 49
#d8 39
#d8 83
#d8 84
#d8 32
#d8 83
#d8 84
#d8 82
#d8 73
#d8 78
#d8 71
#d8 0
#align 8
L$8:
#d8 68
#d8 72
#d8 82
#d8 89
#d8 83
#d8 84
#d8 79
#d8 78
#d8 69
#d8 32
#d8 80
#d8 82
#d8 79
#d8 71
#d8 82
#d8 65
#d8 77
#d8 44
#d8 32
#d8 83
#d8 79
#d8 77
#d8 69
#d8 32
#d8 83
#d8 84
#d8 82
#d8 73
#d8 78
#d8 71
#d8 0
#align 8
L$7:
#d8 68
#d8 104
#d8 114
#d8 121
#d8 115
#d8 116
#d8 111
#d8 110
#d8 101
#d8 32
#d8 66
#d8 101
#d8 110
#d8 99
#d8 104
#d8 109
#d8 97
#d8 114
#d8 107
#d8 44
#d8 32
#d8 86
#d8 101
#d8 114
#d8 115
#d8 105
#d8 111
#d8 110
#d8 32
#d8 50
#d8 46
#d8 49
#d8 32
#d8 40
#d8 76
#d8 97
#d8 110
#d8 103
#d8 117
#d8 97
#d8 103
#d8 101
#d8 58
#d8 32
#d8 67
#d8 32
#d8 111
#d8 114
#d8 32
#d8 67
#d8 43
#d8 43
#d8 41
#d8 10
#d8 0

$bss:
#align 32
Vax_Mips:
#res 4
#align 32
Dhrystones_Per_Second:
#res 4
#align 32
Microseconds:
#res 4
#align 32
start_time:
#res 4
#align 32
User_Time:
#res 4
#align 32
Arr_2_Glob:
#res 10000
#align 32
Arr_1_Glob:
#res 200
#align 8
Ch_2_Glob:
#res 1
#align 8
Ch_1_Glob:
#res 1
#align 32
Bool_Glob:
#res 4
#align 32
Int_Glob:
#res 4
#align 32
Next_Ptr_Glob:
#res 4
#align 32
Ptr_Glob:
#res 4
#d64 0x00000000
