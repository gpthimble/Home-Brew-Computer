//FILE:         alu.v
//DESCRIPTION:  Module for ALU. This module is total combinational logic.
//              ALU is divided into four part: 
//                Unit 00 is for add sub clz clo
//                Unit 01 is for bit wise logic
//                Unit 10 is for shift operation including lui
//                Unit 11 is for mult and div and not implemented yet.
//              ALU function codes:
//               |Unit 00    | Unit 01    | Unit 10    | Unit 11    |
//               |---------------------------------------------------
//               |code  func | code  func | code  func | code  func |
//               |--------------------------------------------------|
//               |0000  ADD  | 0100  AND  | 1000  SLL  | 1100  MULT |
//               |0001  SUB  | 0101  XOR  | 1001  LUI  | 1101  MULTU|
//               |0010  CLZ  | 0110  OR   | 1010  SRL  | 1110  DIV  |
//               |0011  CLO  | 0111  NOR  | 1011  SRA  | 1111  DIVU |
//
//DATE:         2020-10-03
//AUTHOR:       Thimble Liu
//
//INTERFACE:    I/O     NAME          DESCRIPTION
//              input : dataa, datab  two 32-bit data input
//                      alufunc       input for alu function selection
//                                    as shown above
//              output: overflow
//                      zero          zero is HIGH if result is zero
//                      result        32-bit result output
//                      HI            reserved for multiply (not 
//                                     implemented yet)

module alu(
  dataa,datab,alufunc,overflow,zero,result
//  HI for multiply is not implemented yet.
//  ,HI
);

    //------------------------- Interface description  -----------------------------
    //two 32-bit data inputs 
    input [31:0] dataa, datab;
    //4-bit alu function selection code, detailed in description above.
    input [3:0] alufunc;
    //only add, sub, and divided by zero can cause overflow.
    //zero is HIGH when the result is all zero.
    output overflow, zero;
    reg overflow;
    output reg [31:0]  result;
    //HI is reserved for multiply operation.    
    //output reg [31:0]  HI;

    //--------------------------    Module implementation  -------------------------
    wire [31:0] r_sub_add,r_clo_clz,r_shift;
    //reserved for divide and multiply.
    //wire [31:0] r_div,q_div,r_divu,q_divu;
    //wire [63:0] r_mult,r_multu;
    wire overflow_add_sub;
    wire [31:0] a,b;

    //unit 00 from add_sub.v and clo_clz.v
    add_sub add_sub0 (~alufunc[0],dataa,datab,overflow_add_sub,r_sub_add);
    clo_clz clo_clz0 (dataa,alufunc[0],r_clo_clz);
    
    //unit 10 from shifter.v
    shifter shifter0 (datab,dataa,alufunc[1],alufunc[0],r_shift);
    
    //unit 11 for multiply and divide is not implemented yet.
    //mult mult0 (dataa,datab,r_mult);
    //multu multu0 (dataa,datab,r_multu);
    //div div0(datab,dataa,q_div,r_div);
    //divu divu0(datab,dataa,q_divu,r_divu);
    
    //output is multiplexed by alufunc
    always @ (*)begin
      casez(alufunc)
        4'b000? : result = r_sub_add;
        4'b001? : result = r_clo_clz;

        //bit wise operator is implemented directly
        4'b0100 : result = dataa & datab;
        4'b0101 : result = dataa ^ datab;
        4'b0110 : result = dataa | datab;
        4'b0111 : result = ~(dataa | datab);

        4'b10?? : result = r_shift;
        
        //div and mult are not implemented yet.
        //4'b1100 : result = r_mult[31:0];
        //4'b1101 : result = r_multu[31:0];
        //4'b1110 : result = q_div;
        //4'b1111 : result = q_divu;
//      //4'b1110 : result = $signed(dataa)/$signed(datab);
//      //4'b1111 : result = dataa/datab;
        default : result =32'b0;
      endcase
    end

//   HI is reserved for mult and div.
//  always @(*) begin
//    casez(alufunc)
//      4'b1100 : HI = r_mult[63:32];
//      4'b1101 : HI = r_multu[63:32];
//      4'b1110 : HI = r_div;
//      4'b1111 : HI = r_divu;
////      4'b1110 : HI = $signed(dataa)%$signed(datab);
////      4'b1111 : HI = dataa%datab;
//      default : HI = 32'b0;
//    endcase
//  end
    
    //overflow selection
    always @(*) begin

      //use add_sub's overflow when alufunc is 000X
      if (alufunc[3:1] == 3'b000) overflow=overflow_add_sub;

      //dividing  zero cause overflow. not implemented yet.
      //else if ( alufunc[3:1] == 3'b111 ) begin
      //  if (dataa == 32'b0) overflow = 1'b1;
      //  else overflow = 0;
      //end
      else overflow = 1'b0;
    end

    //If all bit of result is zero, zero is HIGH.
    assign zero = ~|result;
endmodule // alu