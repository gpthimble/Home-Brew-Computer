module pipe_e_m_reg(
  EXE_RegWrite,EXE_M2Reg,EXE_MemWrite,
  EXE_result,EXE_b,EXE_TargetReg,
  clk,clrn,
  RegWrite,M2Reg,MemWrite,
  result,b,TargetReg
);
    input EXE_RegWrite,EXE_M2Reg,EXE_MemWrite;
    input clk,clrn;
    input [31:0] EXE_result,EXE_b;
    input [ 4:0] EXE_TargetReg;

    output reg RegWrite,M2Reg,MemWrite;
    output reg [31:0] result, b;
    output reg [ 4:0] TargetReg;

    always @(negedge clrn or posedge clk) begin
      if (clrn == 0) begin
        RegWrite  <= 0 ;        M2Reg    <= 0 ;
        MemWrite  <= 0 ;        result   <= 0 ;
        b         <= 0 ;        TargetReg<= 0 ;
      end else begin
        RegWrite  <= EXE_RegWrite ;   M2Reg    <= EXE_M2Reg     ;
        MemWrite  <= EXE_MemWrite ;   result   <= EXE_result    ;
        b         <= EXE_b        ;   TargetReg<= EXE_TargetReg ;        
      end
    end
    
endmodule // pipe_e_m_reg