/*
Alu function codes:
//unit 00 add_sub and count
0000 ADD
0001 SUB
0010 CLZ
0011 CLO
//unit 01 logic and lui
0100 AND
0101 XOR
0110 OR
0111 NOR
//unit 10  shift unit
1000 SLL
1001 LUI
1010 SRL
1011 SRA
//unit 11 mult and div
1100 MULT
1101 MULTU
1110 DIV
1111 DIVU
*/
module alu(
  dataa,datab,alufunc,overflow,zero,HI,result
);
    input [31:0] dataa, datab;
    input [3:0] alufunc;
    output overflow, zero;
    reg overflow;
    output reg [31:0]  result,HI;
    wire [31:0] r_sub_add,r_clo_clz,r_shift,r_div,q_div,r_divu,q_divu;
    wire [63:0] r_mult,r_multu;
    wire overflow_add_sub;
    wire [31:0] a,b;
    add_sub add_sub0 (~alufunc[0],dataa,datab,overflow_add_sub,r_sub_add);
    clo_clz clo_clz0 (dataa,alufunc[0],r_clo_clz);
    shifter shifter0 (datab,dataa,alufunc[1],alufunc[0],r_shift);
    mult mult0 (dataa,datab,r_mult);
    multu multu0 (dataa,datab,r_multu);
    div div0(datab,dataa,q_div,r_div);
    divu divu0(datab,dataa,q_divu,r_divu);
    always @ (*)begin
      casez(alufunc)
        4'b000? : result = r_sub_add;
        4'b001? : result = r_clo_clz;
        4'b0100 : result = dataa & datab;
        4'b0101 : result = dataa ^ datab;
        4'b0110 : result = dataa | datab;
        4'b0111 : result = ~(dataa | datab);
        4'b10?? : result = r_shift;
        4'b1100 : result = r_mult[31:0];
        4'b1101 : result = r_multu[31:0];
        4'b1110 : result = q_div;
        4'b1111 : result = q_divu;
//        4'b1110 : result = $signed(dataa)/$signed(datab);
//        4'b1111 : result = dataa/datab;
      endcase
    end
    always @(*) begin
      casez(alufunc)
        4'b1100 : HI = r_mult[63:32];
        4'b1101 : HI = r_multu[63:32];
        4'b1110 : HI = r_div;
        4'b1111 : HI = r_divu;
//        4'b1110 : HI = $signed(dataa)%$signed(datab);
//        4'b1111 : HI = dataa%datab;
        default : HI = 32'b0;
      endcase
    end
    
    always @(*) begin
      if ( alufunc[3:1] == 3'b111 ) begin
        if (dataa == 32'b0) overflow = 1'b1;
        else overflow = 0;
      end
      else if (alufunc[3:1] == 3'b000) overflow=overflow_add_sub;
      else overflow = 1'b0;
    end
    assign zero = ~|result;
endmodule // alu