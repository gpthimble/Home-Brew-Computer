module pipe_d_e_reg(
  ID_RegWrite,ID_M2Reg,ID_MemWrite,ID_AluImm,
  ID_shift,ID_link,ID_HiWrite,ID_LoWrite,ID_Hi,
  ID_stl,ID_sign,ID_pc4,ID_a,ID_b,ID_imm,
  ID_AluFunc,ID_ExeSelect,ID_TargetReg,
  clk,clrn,
  RegWrite,M2Reg,MemWrite,AluImm,
  shift,link,HiWrite,LoWrite,Hi,
  stl,sign,pc4,a,b,imm,
  AluFunc,ExeSelect,TargerReg
);

    input clk,clrn;
    input ID_RegWrite,ID_M2Reg,ID_MemWrite,ID_AluImm,
          ID_shift,ID_link,ID_HiWrite,ID_LoWrite,ID_Hi,
          ID_stl,ID_sign;
    input [31:0] ID_pc4,ID_a,ID_b,ID_imm;
    input [ 4:0] ID_TargetReg;
    input [ 3:0] ID_AluFunc;
    input [ 1:0] ID_ExeSelect;

    output reg RegWrite,M2Reg,MemWrite,AluImm,
               shift,link,HiWrite,LoWrite,Hi,
               stl,sign;
    output reg [31:0] pc4,a,b,imm;
    output reg [ 4:0] TargerReg;
    output reg [ 3:0] AluFunc;
    output reg [ 1:0] ExeSelect;

    always @ ( negedge clrn or posedge clk) begin
        if (clrn == 0) begin
          RegWrite <= 0 ;       M2Reg   <= 0 ;
          MemWrite <= 0 ;       AluImm  <= 0 ;
          shift    <= 0 ;       link    <= 0 ;
          HiWrite  <= 0 ;       LoWrite <= 0 ;
          Hi       <= 0 ;       stl     <= 0 ;
          sign     <= 0 ;       

          pc4      <= 0 ;       a       <= 0 ;
          b        <= 0 ;       imm     <= 0 ;
          TargerReg<= 0 ;       AluFunc <= 0 ;
          ExeSelect<= 0 ;

        end else begin
          RegWrite <= ID_RegWrite ;     M2Reg   <= ID_M2Reg   ;
          MemWrite <= ID_MemWrite ;     AluImm  <= ID_AluImm  ;
          shift    <= ID_shift    ;     link    <= ID_link    ;
          HiWrite  <= ID_HiWrite  ;     LoWrite <= ID_LoWrite ;
          Hi       <= ID_Hi       ;     stl     <= ID_stl     ;
          sign     <= ID_sign     ; 

          pc4      <= ID_pc4      ;     a       <= ID_a      ;
          b        <= ID_b        ;     imm     <= ID_imm    ;
          TargerReg<= ID_TargetReg;     AluFunc <= ID_AluFunc;
          ExeSelect<= ID_ExeSelect;
        end
    end

endmodule // pipe_DEreg