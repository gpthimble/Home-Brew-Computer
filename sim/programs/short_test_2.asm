;test load/store
b err
#align 32
data1:
#res 4
data2:
#res 4
err:
la $1,1014822030
la $2,142
la $3,244
la $4,15484
sb $2, data1
sb $3, data1+1
sh $4, data1+2
sw $1, data2
lw $5, data1
lw $6, data2
bne $1, $5, err
bne $1, $6, err

lh $7, data1
addu $8, $0, -2930
bne $7, $8, err
lhu $7, data1
or $8, $0, 62606
bne $7, $8 ,err

lh $7, data1+2
or $8, $0, 15484
bne $7, $8, err
lhu $7, data1 +2
or $8, $0, 15484
bne $7, $8 ,err

lb $7, data1+1
addu $8, $0, -12
bne $7, $8, err
lbu $7, data1+1
or $8, $0, 244
bne $7, $8, err

lb $7, data1+2
addu $8, $0, 124
bne $7, $8, err
lbu $7, data1+2
or $8, $0, 124
bne $7, $8, err


;unaligned load & store
la $10, 233665201 
la $2, 255472364
la $3, 15
sb $3, data2+3
la $4, 976415757
usw $4, data1+3#($0)
la $5, 60786
ush $5, data1+1#($0)
la $6, 177
sb $6, data1
lw $7, data2
bne $7, $2, err
lw $8, data1
bne $8,$10,err
ulhu $11, data1+1#($0)
la $12, 60786
bne $11, $12, err
ulw $13, data1+3#($0)
la $14, 976415757
bne $13, $14, err


