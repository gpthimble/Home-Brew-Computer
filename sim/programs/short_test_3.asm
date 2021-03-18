;test conditional jump

err:

a1:
b a2
b err
a2:
la $2, b1
j $2
b err
b1:
;bgtz branch on greater than zero
la $2,1
bgtz $2,b2-$
b err
b2:
la $2,-3
bgtz $2,b3-$
b b4
b3:
b err
b4:
la $2,0
bgtz $2, b5-$
b b6
b5:
b err
b6:



;blez branch on less than or equal to zero
la $2,0
blez $2,c2-$
b err
c2:
la $2,-5
blez $2,c3-$
b err
c3:
la $2,1
blez $2,c4-$
b c5
c4:
b err
c5:

;bne branch on not equal
la $1, 23
la $2, 23
bne $1, $2, d1 
b d2 
d1:
b err
d2:
la $1, 21
bne $1, $2, d3
b err 
d3:

;beq branch on equal
la $1,45
la $2,43
beq $1, $2, e1
b e2
e1:
b err
e2:
la $1, 43
beq $1, $2, e3
b err
e3:

;bltz branch on less than zero
la $1, -3
bltz $1, f1-$
b err
f1:
la $1, 0
bltz $1, f2-$
b f3
f2:
b err
f3:
la $1, 1
bltz $1, f4-$
b f5
f4:
b err
f5:

;bgez branch on greater than or equal to zero
la $1, 0
bgez $1, g1-$
b err
g1:
la $1, 1
bgez $1, g2-$
b err
g2:
la $1, -1
bgez $1, g3-$
b g4
g3:
b err
g4:

;test jump and link instructions
;bltzal branch on less than zero and link
la $1, -3
bltzal $1, h1-$
l1:
b err
h1:
la $2, l1
bne $31, $2, err
la $1, 0
bltzal $1, h2-$
b h3
h2:
b err
h3:
la $1, 1
bltzal $1, h4-$
b h5
h4:
b err
h5:

;bgezal branch on greater than or equal to zero and link
la $1, 0
bgezal $1, i1-$
l2:
b err
i1:
la $2, l2
bne $2, $31, err
la $1, 1
bgezal $1, i2-$
l3:
b err
i2:
la $2, l3
bne $2, $31, err
la $1, -1
bgezal $1, i3-$
b i4
i3:
b err
i4:

;jal jump and link
jal j1
l4:
b err
j1:
la $2, l4
bne $2,$31, err

;jalr jump register and link
la $1, j2
jal $1
l5:
b err
j2:
la $2, l5
bne $2, $31, err







