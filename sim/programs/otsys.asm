#bits 8
#subruledef register
{
    $0  =>  0
    $1  =>  1
    $2  =>  2
    $3  =>  3
    $4  =>  4
    $5  =>  5
    $6  =>  6
    $7  =>  7
    $8  =>  8
    $9  =>  9
    $10 => 10
    $11 => 11
    $12 => 12
    $13 => 13
    $14 => 14
    $15 => 15
    $16 => 16
    $17 => 17
    $18 => 18
    $19 => 19
    $20 => 20
    $21 => 21
    $22 => 22
    $23 => 23
    $24 => 24
    $25 => 25
    $26 => 26
    $27 => 27
    $28 => 28
    $29 => 29
    $gp => 28
    $sp => 29
    $30 => 30
    $31 => 31
}

;define rules for the ported lcc compiler
#ruledef
{
    ;--------------------------------------------------------------------------------------
    ;la load address
    ;la rt, offset  ; offset->rt
    la {rt:register}, {offset: s16} => ;addiu rt, $0, offset`16
									0b001001@0b00000@rt`5@offset`16

    la {rt:register}, {offset: s32} =>	{assert((offset < -32768)| (offset > 32767) ),
									;lui rt, offset[31:16]
									0b001111@0b00000@rt`5@offset[31:16]@
									;ori rt, rt, offset[15:0]
									0b001101@rt`5@rt`5@offset[15:0]}
									
    ;la rt, offset#(register)   ; offset#(register)->rt
    la {rt:register}, {offset: s16}#({rs: register})=>
									;addui rt, rs, offset`16
									0b001001@rs`5@rt`5@offset`16
									
    la {rt:register}, {offset: s32}#({rs: register})=>{assert((offset < -32768)| (offset > 32767) ),
									;lui rt, offset[31:16]
									0b001111@0b00000@rt`5@offset[31:16]@
									;ori rt, rt, offset[15:0]
									0b001101@rt`5@rt`5@offset[15:0]@
									;addu rt, rt, rs
									0b000000@ rt`5 @ rs`5 @ rt`5 @0b00000@0b100001}
    ;--------------------------------------------------------------------------------------
    ;sw store word
    ;sw rt, (base) ; rt -> mem[(base)]
    sw {rt:register} ,({base:register}) => ;sw rt, (base)
									0b101011 @ base`5 @ rt`5 @ 0x0000

    ;sw rt, offset#(base) ; rt -> mem[offset#(base)]
    sw {rt:register} ,{offset: s16}#({base:register}) => ;sw rt, offset(base)
									0b101011 @ base`5 @ rt`5 @ offset`16

    sw {rt:register} ,{offset: s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;sw $rt, ($1)
									0b101011 @ 0b00001 @ rt`5	 @ 0x0000  } 
    ;sw rt, offset ; rt -> mem[offset]
    sw {rt:register}, {offset:s16}=> 	;sw rt, offset
									0b101011 @ 0b00000 @ rt`5 @ offset`16

    sw {rt:register}, {offset:s32}=>{assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;sw $rt, ($1)
									0b101011 @ 0b00001 @ rt`5	 @ 0x0000  }									
    ;--------------------------------------------------------------------------------------
    ;sh store half-word
    ;sh rt, (base) ; rt -> mem[(base)]
    sh {rt:register} ,({base:register}) => ;sh rt, (base)
									0b101001 @ base`5 @ rt`5 @ 0x0000

    ;sh rt, offset#(base) ; rt -> mem[offset#(base)]
    sh {rt:register} ,{offset: s16}#({base:register}) => ;sh rt, offset(base)
									0b101001 @ base`5 @ rt`5 @ offset`16

    sh {rt:register} ,{offset: s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;sh $rt, ($1)
									0b101001 @ 0b00001 @ rt`5	 @ 0x0000  } 
    ;sh rt, offset ; rt -> mem[offset]
    sh {rt:register}, {offset:s16}=> 	;sh rt, offset
									0b101001 @ 0b00000 @ rt`5 @ offset`16

    sh {rt:register}, {offset:s32}=>{assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;sh $rt, ($1)
									0b101001 @ 0b00001 @ rt`5	 @ 0x0000  }									
    ;--------------------------------------------------------------------------------------
    ;sb store byte
    ;sb rt, (base) ; rt -> mem[(base)]
    sb {rt:register} ,({base:register}) => ;sb rt, (base)
									0b101000 @ base`5 @ rt`5 @ 0x0000

    ;sb rt, offset#(base) ; rt -> mem[offset#(base)]
    sb {rt:register} ,{offset: s16}#({base:register}) => ;sb rt, offset(base)
									0b101000 @ base`5 @ rt`5 @ offset`16

    sb {rt:register} ,{offset: s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;sb $rt, ($1)
									0b101000 @ 0b00001 @ rt`5	 @ 0x0000  } 
    ;sb rt, offset ; rt -> mem[offset]
    sb {rt:register}, {offset:s16}=> 	;sb rt, offset
									0b101000 @ 0b00000 @ rt`5 @ offset`16

    sb {rt:register}, {offset:s32}=>{assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;sb $rt, ($1)
									0b101000 @ 0b00001 @ rt`5	 @ 0x0000  }	

    ;--------------------------------------------------------------------------------------
    ;lb load byte
    ;lb rt, (base) ; mem[(base)] -> rt
    lb {rt:register},({base:register}) => ;lb rt, (base)
									0b100000 @ base`5 @ rt`5 @ 0x0000
    ;lb rt, offset ; mem[offset] -> rt
    lb {rt:register}, {offset: s16} =>	;lb rt, offset
									0b100000 @ 0b00000 @ rt`5 @ offset`16
    lb {rt:register}, {offset: s32} => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;lb rt, ($1)
									0b100000 @ 0b00001 @ rt`5 @ 0x0000 }
    ;lb rt, offset#(base) ; mem[offset#(base)] -> rt
    lb {rt:register}, {offset :s16}#({base:register}) => ;lb rt, offset#(base)	
									0b100000 @ base`5 @ rt`5 @ offset`16					
    lb {rt:register}, {offset :s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;lb rt, ($1)
									0b100000 @ 0b00001 @ rt`5 @ 0x0000 }
    ;--------------------------------------------------------------------------------------
    ;lh load half-word
    ;lh rt, (base) ; mem[(base)] -> rt
    lh {rt:register},({base:register}) => ;lh rt, (base)
									0b100001 @ base`5 @ rt`5 @ 0x0000
    ;lh rt, offset ; mem[offset] -> rt
    lh {rt:register}, {offset: s16} =>	;lh rt, offset
									0b100001 @ 0b00000 @ rt`5 @ offset`16
    lh {rt:register}, {offset: s32} => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;lh rt, ($1)
									0b100001 @ 0b00001 @ rt`5 @ 0x0000 }
    ;lh rt, offset#(base) ; mem[offset#(base)] -> rt
    lh {rt:register}, {offset :s16}#({base:register}) => ;lh rt, offset#(base)	
									0b100001 @ base`5 @ rt`5 @ offset`16					
    lh {rt:register}, {offset :s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;lh rt, ($1)
									0b100001 @ 0b00001 @ rt`5 @ 0x0000 }
    ;--------------------------------------------------------------------------------------
    ;lw load word
    ;lw rt, (base) ; mem[(base)] -> rt
    lw {rt:register},({base:register}) => ;lw rt, (base)
									0b100011 @ base`5 @ rt`5 @ 0x0000
    ;lw rt, offset ; mem[offset] -> rt
    lw {rt:register}, {offset: s16} =>	;lw rt, offset
									0b100011 @ 0b00000 @ rt`5 @ offset`16
    lw {rt:register}, {offset: s32} => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;lw rt, ($1)
									0b100011 @ 0b00001 @ rt`5 @ 0x0000 }
    ;lw rt, offset#(base) ; mem[offset#(base)] -> rt
    lw {rt:register}, {offset :s16}#({base:register}) => ;lw rt, offset#(base)	
									0b100011 @ base`5 @ rt`5 @ offset`16					
    lw {rt:register}, {offset :s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;lw rt, ($1)
									0b100011 @ 0b00001 @ rt`5 @ 0x0000 }
    ;--------------------------------------------------------------------------------------
    ;lbu load byte unsigned
    ;lbu rt, (base) ; mem[(base)] -> rt
    lbu {rt:register},({base:register}) => ;lbu rt, (base)
									0b100100 @ base`5 @ rt`5 @ 0x0000
    ;lbu rt, offset ; mem[offset] -> rt
    lbu {rt:register}, {offset: s16} =>	;lbu rt, offset
									0b100100 @ 0b00000 @ rt`5 @ offset`16
    lbu {rt:register}, {offset: s32} => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;lbu rt, ($1)
									0b100100 @ 0b00001 @ rt`5 @ 0x0000 }
    ;lbu rt, offset#(base) ; mem[offset#(base)] -> rt
    lbu {rt:register}, {offset :s16}#({base:register}) => ;lbu rt, offset#(base)	
									0b100100 @ base`5 @ rt`5 @ offset`16					
    lbu {rt:register}, {offset :s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;lbu rt, ($1)
									0b100100 @ 0b00001 @ rt`5 @ 0x0000 }
    ;--------------------------------------------------------------------------------------
    ;lhu load half-word unsigned
    ;lhu rt, (base) ; mem[(base)] -> rt
    lhu {rt:register},({base:register}) => ;lhu rt, (base)
									0b100101 @ base`5 @ rt`5 @ 0x0000
    ;lhu rt, offset ; mem[offset] -> rt
    lhu {rt:register}, {offset: s16} =>	;lhu rt, offset
									0b100101 @ 0b00000 @ rt`5 @ offset`16
    lhu {rt:register}, {offset: s32} => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;lhu rt, ($1)
									0b100101 @ 0b00001 @ rt`5 @ 0x0000 }
    ;lhu rt, offset#(base) ; mem[offset#(base)] -> rt
    lhu {rt:register}, {offset :s16}#({base:register}) => ;lhu rt, offset#(base)	
									0b100101 @ base`5 @ rt`5 @ offset`16					
    lhu {rt:register}, {offset :s32}#({base:register}) => {assert((offset < -32768)| (offset > 32767) ),
									;lui $1,offset[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ offset[31:16] @ 
									;ori $1, $1, offset[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ offset[15: 0] @
									;addu $1, $base , $1
									0b000000 @ base`5  @ 0b00001 @ 0b00001 @ 0b00000 @ 0b100001 @
									;lhu rt, ($1)
									0b100101 @ 0b00001 @ rt`5 @ 0x0000 }
    ;--------------------------------------------------------------------------------------
    ;addu add unsigned
    ;addu rd, rs, rt ; rs + rt -> rd
    addu {rd:register} , {rs:register}, {rt:register} =>
									;addu rd, rs, rt
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100001
    ;addu rt, rs, imm ; rs + imm -> rt
    addu {rt:register} , {rs:register}, {imm: s16} =>
									;addiu rt, rs, imm
									0b001001 @ rs`5 @ rt`5 @ imm`16
    addu {rt:register} , {rs:register}, {imm: s32} => {assert((imm < -32768)| (imm > 32767) ),
									;lui $1,imm[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ imm[31:16] @ 
									;ori $1, $1, imm[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ imm[15: 0] @		
									;addu rt, rs, $1
									0b000000 @ rs`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100001}
    ;--------------------------------------------------------------------------------------
    ;subu sub unsigned
    ;subu rd, rs, rt ; rs - rt -> rd
    subu {rd:register} , {rs:register}, {rt:register} =>
									;subu rd, rs, rt
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100011
    ;sub rt, rs, imm ; rs - imm -> rt
    subu {rt:register} , {rs:register}, {imm: s32}=>{neg_imm = -imm
									assert((neg_imm >= -32768)& (neg_imm <= 32767) )
									;addiu rt, rs, neg_imm
									0b001001 @ rs`5 @ rt`5 @ neg_imm`16}
    subu {rt:register} , {rs:register}, {imm: s32}=>{neg_imm = -imm			
									assert((neg_imm < -32768)| (neg_imm > 32767))
									;lui $1,neg_imm[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ neg_imm[31:16] @ 
									;ori $1, $1, neg_imm[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ neg_imm[15: 0] @		
									;addu rt, rs, $1
									0b000000 @ rs`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100001
									}		
    ;--------------------------------------------------------------------------------------
    ;and
    ;and rd, rs, rt ; rs & rt -> rd
    and {rd:register}, {rs:register}, {rt:register} =>
									;and rd, rs, rt
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100100
    ;and rt, rs, imm ; rs & imm -> rd
    and {rt:register}, {rs:register}, {imm:u16} =>
									;andi rt, rs, imm
									0b001100 @ rs`5 @ rt`5 @ imm`16
    and {rt:register}, {rs:register}, {imm:u32} =>{assert(imm>65535)
									;lui $1,imm[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ imm[31:16] @ 
									;ori $1, $1, imm[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ imm[15: 0] @	
									;and rt, rs ,$1
									0b000000 @ rs`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100100
									}
    ;--------------------------------------------------------------------------------------								
    ;or
    ;or rd, rs, rt ; rs | rt -> rd
    or {rd:register}, {rs:register}, {rt:register} =>
									;or rd, rs, rt
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100101
    ;or rt, rs, imm ; rs | imm -> rd
    or {rt:register}, {rs:register}, {imm:u16} =>
									;ori rt, rs, imm
									0b001101 @ rs`5 @ rt`5 @ imm`16
    or {rt:register}, {rs:register}, {imm:u32} =>{assert(imm>65535)
									;lui $1,imm[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ imm[31:16] @ 
									;ori $1, $1, imm[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ imm[15: 0] @	
									;or rt, rs ,$1
									0b000000 @ rs`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100101
									}
    ;--------------------------------------------------------------------------------------								
    ;xor
    ;xor rd, rs, rt ; rs ^ rt -> rd
    xor {rd:register}, {rs:register}, {rt:register} =>
									;xor rd, rs, rt
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100110
    ;xor rt, rs, imm ; rs ^ imm -> rd
    xor {rt:register}, {rs:register}, {imm:u16} =>
									;xori rt, rs, imm
									0b001110 @ rs`5 @ rt`5 @ imm`16
    xor {rt:register}, {rs:register}, {imm:u32} =>{assert(imm>65535)
									;lui $1,imm[31:16]
									0b001111 @ 0b00000 @ 0b00001 @ imm[31:16] @ 
									;ori $1, $1, imm[15:0]
									0b001101 @ 0b00001 @ 0b00001 @ imm[15: 0] @	
									;xor rt, rs ,$1
									0b000000 @ rs`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100110
									}
    ;--------------------------------------------------------------------------------------								
    ;sll shift left logical
    ;sll rd, rt, sa ; rt << sa -> rd
    sll {rd:register}, {rt:register}, {sa:i32} =>
									;sll rd, rt, sa
									0b000000 @ 0b00000 @ rt`5 @ rd`5 @ sa[4:0] @ 0b000000
    ;sll rd, rt, rs ; rt << rs -> rd
    sll {rd:register}, {rt:register}, {rs:register} =>
									;sllv rd, rt, rs
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b000100
    ;--------------------------------------------------------------------------------------
    ;sra shift right arithmetic
    ;sra rd, rt, sa ; rt >> sa -> rd
    sra {rd:register}, {rt:register}, {sa:i32} =>
									;sra rd, rt, sa
									0b000000 @ 0b00000 @ rt`5 @ rd`5 @ sa[4:0] @ 0b000011
    ;sra rd, rt, rs ; rt >> rs -> rd
    sra {rd:register}, {rt:register}, {rs:register} =>
									;srav rd, rt, rs
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b000111
    ;--------------------------------------------------------------------------------------
    ;srl shift right logical
    ;srl rd, rt, sa ; rt >> sa -> rd
    srl {rd:register}, {rt:register}, {sa:i32} =>
									;srl rd, rt, sa
									0b000000 @ 0b00000 @ rt`5 @ rd`5 @ sa[4:0] @ 0b000010
    ;srl rd, rt, rs ; rt >> rs -> rd
    srl {rd:register}, {rt:register}, {rs:register} =>
									;srlv rd, rt, rs
									0b000000 @ rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b000110
    ;--------------------------------------------------------------------------------------
    ;not pseudo instruction, bitwise flip
    ;not rd, rt ; rt nor $0 -> rd
    not {rd:register}, {rt:register} => ;nor rd, rt, $0
									0b000000 @ rt`5 @ 0b00000 @ rd`5 @ 0b00000 @ 0b100111
    ;--------------------------------------------------------------------------------------
    ;negu pseudoinstruction calculates the two's complement negation 
    ;negu rd, rt ; subu rd, $0, rt
    negu {rd:register}, {rt:register} => ;subu rd, $0, rt
									0b000000 @ 0b00000 @ rt`5 @ rd`5 @ 0b00000 @ 0b100011
    ;--------------------------------------------------------------------------------------
    ;move pseudoinstruction
    ;move rd, rt ; $0 + rt -> rd
    move {rd:register}, {rt:register} => ;addu rd, $0, rt
									0b000000 @ 0b00000 @ rt`5 @ rd`5 @ 0b00000 @ 0b100001
    ;--------------------------------------------------------------------------------------
    ;b branch target
    b {target:u28} 			=> {assert(pc[31:28]== 0x0)
                            ;j target
						    0b000010 @ target[27:2]}
    b {target:u28}			=> {assert(pc[31:28]!= 0x0)
						    ;lui $1,target[31:16]
						    0b001111 @ 0b00000 @ 0b00001 @ target[31:16] @ 
						    ;ori $1, $1, target[15:0]
						    0b001101 @ 0b00001 @ 0b00001 @ target[15: 0] @
						    ;jr $1
						    0b000000 @ 0b00001 @ 0b0000000000 @0b00000 @ 0b001000}	
    b {target:u32}			=> {assert(target > 0xfffffff)
						    ;lui $1,target[31:16]
						    0b001111 @ 0b00000 @ 0b00001 @ target[31:16] @ 
						    ;ori $1, $1, target[15:0]
						    0b001101 @ 0b00001 @ 0b00001 @ target[15: 0] @
						    ;jr $1
						    0b000000 @ 0b00001 @ 0b0000000000 @0b00000  @ 0b001000}		
    ;--------------------------------------------------------------------------------------
    ;jump register
    j {target:register}		=>;jr target
						    0b000000 @ target`5 @ 0b0000000000 @0b00000 @ 0b001000
    ;--------------------------------------------------------------------------------------
    ;jump and link (function call)
    ;jal target ;  target << 2 -> pc ;  return address -> $31 
    jal {target:u28}		=>  {assert(pc[31:28]== 0x0)
                            ;jal target
						    0b000011 @ target[27:2]}
    jal {target:u28}    	=> {assert(pc[31:28]!= 0x0)
							;lui $1,target[31:16]
							0b001111 @ 0b00000 @ 0b00001 @ target[31:16] @ 
							;ori $1, $1, target[15:0]
							0b001101 @ 0b00001 @ 0b00001 @ target[15: 0] @
							;jalr $1
							0b000000 @ 0b00001 @ 0b00000 @ 0b11111 @ 0b00000 @ 0b001001}
    jal {target:u32}		=> {assert(target > 0xfffffff)
							;lui $1,target[31:16]
							0b001111 @ 0b00000 @ 0b00001 @ target[31:16] @ 
							;ori $1, $1, target[15:0]
							0b001101 @ 0b00001 @ 0b00001 @ target[15: 0] @
							;jalr $1
							0b000000 @ 0b00001 @ 0b00000 @ 0b11111 @ 0b00000 @ 0b001001}
    jal {target:register}		=> ;jalr target
    							0b000000 @ target`5 @ 0b00000 @ 0b11111 @ 0b00000 @ 0b001001
    ;--------------------------------------------------------------------------------------
    ;conditional branch
    ;beq rs, rt, target ; target -> pc if rs == rt
    beq {rs:register}, {rt:register}, {target:u32} => {offset = target - $
							assert((offset>= -32768)& (offset<= 32767))
							;beq rs, rt, offset
							0b000100 @ rs`5 @ rt`5 @ offset`16}
    ;bge rs, rt, target ; targe -> pc if rs >= rt
    bge {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;slt $1, rs, rt
							0b000000 @ rs`5 @ rt`5 @ 0b00001 @ 0b00000 @ 0b101010 @
							;beq $1, $0, offset
							0b000100 @ 0b00001 @ 0b00000 @ offset`16}
    ;bgeu rs, rt, target ; targe -> pc if rs >= rt
    bgeu {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;sltu $1, rs, rt
							0b000000 @ rs`5 @ rt`5 @ 0b00001 @ 0b00000 @ 0b101011 @
							;beq $1, $0, offset
							0b000100 @ 0b00001 @ 0b00000 @ offset`16}	
    ;bgt rs, rt, target ; target  -> pc if rs > rt
    bgt {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;slt $1, rt, rs
							0b000000 @ rt`5 @ rs`5 @ 0b00001 @ 0b00000 @ 0b101010 @
							;bne $1, $0, offset
							0b000101 @ 0b00001 @ 0b00000 @ offset`16}	
    ;bgtu rs, rt, target ; target  -> pc if rs > rt
    bgtu {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;sltu $1, rt, rs
							0b000000 @ rt`5 @ rs`5 @ 0b00001 @ 0b00000 @ 0b101011 @
							;bne $1, $0, offset
							0b000101 @ 0b00001 @ 0b00000 @ offset`16}	
    ;ble rs, rt, target ; target -> pc if rs <= rt 
    ble {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;slt $1, rt, rs
							0b000000 @ rt`5 @ rs`5 @ 0b00001 @ 0b00000 @ 0b101010 @
							;beq $1, $0, offset
							0b000100 @ 0b00001 @ 0b00000 @ offset`16}
    ;bleu rs, rt, target ; target -> pc if rs <= rt 
    bleu {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;sltu $1, rt, rs
							0b000000 @ rt`5 @ rs`5 @ 0b00001 @ 0b00000 @ 0b101011 @
							;beq $1, $0, offset
							0b000100 @ 0b00001 @ 0b00000 @ offset`16}
    ;blt rs, rt, target ; target -> pc if rs < rt
    blt {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;slt $1, rs, rt
							0b000000 @ rs`5 @ rt`5 @ 0b00001 @ 0b00000 @ 0b101010 @
							;bne $1, $0, offset
							0b000101 @ 0b00001 @ 0b00000 @ offset`16}						
    ;bltu rs, rt, target ; target -> pc if rs <rt
    bltu {rs:register}, {rt:register}, {target:u32} => {offset = target - $ -4
							assert((offset>= -32768)& (offset<= 32767))
							;sltu $1, rs, rt
							0b000000 @ rs`5 @ rt`5 @ 0b00001 @ 0b00000 @ 0b101011 @
							;bne $1, $0, offset
							0b000101 @ 0b00001 @ 0b00000 @ offset`16}	
    ;bne rs, rt, target ; target -> pc if rs == rt
    bne {rs:register}, {rt:register}, {target:u32} => {offset = target - $
							assert((offset>= -32768)& (offset<= 32767))
							;bne rs, rt, offset
							0b000101 @ rs`5 @ rt`5 @ offset`16}
    ;--------------------------------------------------------------------------------------
    ;unaligned load half-word unsigned
    ulhu {rt:register},{offset: s16}#({base:register}) =>{ offset1=offset+1
    							;lbu rt, offset#(base)
    							0b100100 @ base`5 @ rt`5 @ offset`16 @
    							;lbu $1, offset+1#(base)
    							0b100100 @ base`5 @ 0b00001 @ offset1`16 @
    							;sll $1, $1, 8
    							0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b01000 @ 0b000000 @
    							;or rt, rt, $1
    							0b000000 @ rt`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100101}

    ;unaligned load word
    ulw {rt:register},{offset: s16}#({base:register}) =>{ offset1=offset+1
    							offset2=offset+2
    							offset3=offset+3			
    							;lbu rt, offset#(base)
    							0b100100 @ base`5 @ rt`5 @ offset`16 @
    							;lbu $1, offset+1#(base)
    							0b100100 @ base`5 @ 0b00001 @ offset1`16 @
    							;sll $1, $1, 8
    							0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b01000 @ 0b000000 @
    							;or rt, rt, $1
    							0b000000 @ rt`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100101 @
    							;lbu $1, offset+2#(base)
    							0b100100 @ base`5 @ 0b00001 @ offset2`16 @
    							;sll $1, $1, 16
    							0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b10000 @ 0b000000 @
    							;or rt, rt, $1
    							0b000000 @ rt`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100101 @
    							;lbu $1, offset+3#(base)
    							0b100100 @ base`5 @ 0b00001 @ offset3`16 @
    							;sll $1, $1,24
    							0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b11000 @ 0b000000 @
    							;or rt, rt, $1
    							0b000000 @ rt`5 @ 0b00001 @ rt`5 @ 0b00000 @ 0b100101
    														}
    ;unaligned store half-word
    ush {rt:register},{offset: s16}#({base:register}) =>{ offset1=offset+1
    							;sb rt, offset#(base)
    							0b101000 @ base`5 @ rt`5 @ offset`16 @
    							;srl $1, rt, 8
    							0b000000 @ 0b00000 @ rt`5 @ 0b00001 @ 0b01000 @ 0b000010 @
    							;sb $1, offset+1(base)
    							0b101000 @ base`5 @ 0b00001 @ offset1`16
    							}

    ;unaligned store word							
    usw {rt:register},{offset: s16}#({base:register}) =>{ offset1=offset+1
                                offset2=offset+2
                                offset3=offset+3
    							;sb rt, offset#(base)
                                0b101000 @ base`5 @ rt`5 @ offset`16 @
    							;srl $1, rt, 8
                                0b000000 @ 0b00000 @ rt`5 @ 0b00001 @ 0b01000 @ 0b000010 @
    							;sb $1, offset+1(base)
                                0b101000 @ base`5 @ 0b00001 @ offset1`16@	
    							;srl $1, $1, 8
                                0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b01000 @ 0b000010 @
    							;sb $1, offset+2(base)
                                0b101000 @ base`5 @ 0b00001 @ offset2`16@	
    							;srl $1, $1, 8
                                0b000000 @ 0b00000 @ 0b00001 @ 0b00001 @ 0b01000 @ 0b000010 @
    							;sb $1, offset+3(base)
                                0b101000 @ base`5 @ 0b00001 @ offset3`16   }


}

;define rules for instructions that not used by the lcc compiler
#ruledef
{   
    ;lui rt, imm; imm << 16 -> rt
    lui {rt:register}, {imm: i16} => 0b001111 @ 0b00000 @ rt`5 @ imm`16
    ;sltiu rt, rs, imm; (rs < imm)(unsigned) -> rt
    sltiu {rt:register}, {rs:register}, {imm: i16} => 0b001011 @ rs`5 @ rt`5 @ imm`16
    ;slti rt, rs, imm; (rs < imm)(signed) -> rt
    slti {rt:register}, {rs:register}, {imm: i16} => 0b001010 @ rs`5 @ rt`5 @ imm`16
    ;clo rd, rs; Count Leading Ones in Word
    clo {rd:register}, {rs:register} => 0b011100 @ rs`5 @ 0b00000 @ rd`5 @ 0b00000 @ 0b100001
    ;clz rd, rs; Count Leading Zeros in word
    clz {rd:register}, {rs:register} => 0b011100 @ rs`5 @ 0b00000 @ rd`5 @ 0b00000 @ 0b100000
    ;sltu rd, rs, rt; (rs < rt)(unsigned) -> rd 
    sltu {rd:register}, {rs:register}, {rt:register} => 0b000000 @rs`5@rt`5@rd`5@0b00000@0b101011
    ;slt rd, rs, rt; (rs < rt)(signed) -> rd 
    slt {rd:register}, {rs:register}, {rt:register} => 0b000000 @rs`5@rt`5@rd`5@0b00000@0b101010    
    ;nor rd, rs, rt; rs nor rt -> rd 
    nor {rd:register}, {rs:register}, {rt:register} => 0b000000 @rs`5@rt`5@rd`5@0b00000@0b100111  
    ;syscall; System Call
    syscall => 0b000000 @ 0b00000000000000000000 @ 0b001100
    syscall {code: u20} => 0b000000 @ code`20 @ 0b001100
    ;mtc0 rt, rd; Move to Coprocessor 0
    mtc0 {rt:register}, {rd:u5} => 0b010000 @ 0b00100 @ rt`5 @ rd`5 @ 0b00000000 @ 0b000
    ;mfc0 rt, rd; Move from Coprocessor 0
    mfc0 {rt:register}, {rd:u5} => 0b010000 @ 0b00000 @ rt`5 @ rd`5 @ 0b00000000 @ 0b000
    ;eret; Eception Return
    eret => 0b010000 @ 0b1 @ 0b0000000000000000000 @ 0b011000
    ;bgtz if rs > 0 then branch
    bgtz {rs:register}, {offset: s16} => 0b000111 @ rs`5 @ 0b00000 @ offset`16
    ;blez if rs <= 0 then branch
    blez {rs:register}, {offset: s16} => 0b000110 @ rs`5 @ 0b00000 @ offset`16
    ;bltzal; Branch on Less Than Zero and Link
    bltzal {rs:register}, {offset: s16} => 0b000001 @ rs`5 @ 0b10000 @ offset`16
    ;bltz; Branch on Less Than Zero
    bltz {rs:register}, {offset: s16} => 0b000001 @ rs`5 @ 0b00000 @ offset`16
    ;bgezal; branch on greater than or equal to zero and link
    bgezal {rs:register}, {offset: s16} => 0b000001 @ rs`5 @ 0b10001 @ offset`16   
    ;bgez; branch on greater than or equal to zero
    bgez {rs:register}, {offset: s16} => 0b000001 @ rs`5 @ 0b00001 @ offset`16   
	;add ;this instruction will cause overflow
	add {rd:register}, {rs:register}, {rt:register} => 0b000000 @rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100000
	;sub ;this instruction will cause overflow
	sub {rd:register}, {rs:register}, {rt:register} => 0b000000 @rs`5 @ rt`5 @ rd`5 @ 0b00000 @ 0b100010
	;addi ;add imediate; this instruction will cause overflow
	addi {rt:register}, {rs:register}, {imm: s16} => 0b001000 @ rs`5 @ rt`5 @ imm`16
}
