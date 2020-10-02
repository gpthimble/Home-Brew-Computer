module pipe_m_w_reg(
  M_RegWrite,M_M2Reg,M_MemOut,M_AluOut,M_TargetReg,
  clk,clrn,
  RegWrite,M2Reg,MemOut,AluOut,TargetReg
);
    input [31:0] M_MemOut,M_AluOut;
    input [ 4:0] M_TargetReg;
    input M_RegWrite,M_M2Reg;
    input clk,clrn;
    output reg [31:0] MemOut,AluOut;
    output reg [ 4:0] TargetReg;
    output reg RegWrite,M2Reg;
    always @(negedge clrn or posedge clk) begin
      if (clrn == 0) begin
        MemOut    <= 0;     AluOut    <= 0;
        TargetReg <= 0;     RegWrite  <= 0;
        M2Reg     <= 0;
      end else begin
        MemOut    <= M_MemOut   ;     AluOut    <= M_AluOut  ;
        TargetReg <= M_TargetReg;     RegWrite  <= M_RegWrite;
        M2Reg     <= M_M2Reg    ;        
      end
    end
    
endmodule // pipe_m_w_reg