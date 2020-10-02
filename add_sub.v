//FILE:         add_sub.v
//DESCRIPTION:  Module for add and sub, this module is total combinational logic.
//DATA:         2020-10-02
//AUTHOR:       Thimble Liu
//INTERFACE:
//              input : add_sub -- 0 for add; 1 for sub.
//                      a, b;
//              output: overflow, result.

module add_sub(
    add_sub, a, b, overflow, result
);
    //------------------------- Interface description   -----------------------------
    //This pin control the function of this module, 0 for add and 1for sub.
    input add_sub;
    //a,b are two 32-bit data input.
    input [31:0] a,b;
    //overflow is calculated for both signed and unsigned here, 
    //  but may be masked out by other part.
    output overflow;
    //32-bit data output.
    output [31:0] result;

    //--------------------------    Module implementation   -------------------------
    
    //Calculate result. 
    //Previous version of this module used a delicate adder with look head carry, but
    //  after synthesis and simulation, turns out the delicate adder is worse than 
    //  the simple "+". If someone has a better adder, can change it.
    assign result = add_sub ? a - b : a + b;

    //Calculate overflow.
    //Because of ALU doesn't know the operation is signed or unsigned, overflow should 
    //  generate for both, and then modified by other part.
    //For addition, overflow is high when both operators have same sign and the result 
    //  has different sign from the operator. When two operators have different sign, 
    //  addition never generate overflow.
    //For subtraction, overflow is high when signs of two operators are different, and
    //  the result of subtraction has the same sign from the second operator.
    //Truth table for overflow:
    //  add_sub  a[31]   b[31]  result[31]  |   overflow
    //  --------------------------------------------------
    //      0      0       0        1       |       1
    //      0      1       1        0       |       1
    //      1      0       1        1       |       1
    //      1      1       0        0       |       1
    assign overflow =   ~add_sub & ~a[31] & ~b[31] &  result[31] |
                        ~add_sub &  a[31] &  b[31] & ~result[31] |
                         add_sub & ~a[31] &  b[31] &  result[31] |
                         add_sub &  a[31] & ~b[31] & ~result[31] ;
endmodule //add_sub

