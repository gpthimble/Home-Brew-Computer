module pipe_exe(
  AluImm,shift,link,HiWrite,LoWrite,Hi,stl,sign,clk,clrn,
  pc4,AluFunc,a,b,imm,ExeSelect,TargetReg,
  EXE_Result,EXE_b,EXE_TargetReg
);
    input  AluImm,shift,link,HiWrite,LoWrite,Hi,stl,sign,clk,clrn;
    input [31:0] pc4,a,b,imm;
    input [ 3:0] AluFunc;
    input [ 4:0] TargetReg;
    input [ 1:0] ExeSelect;

    output [31:0] EXE_Result,EXE_b;
    output [ 4:0] EXE_TargetReg;

    assign EXE_b = b;
    wire [31:0] pc8;
    assign pc8 = pc4 + 4 ;
    


    wire [31:0] dataa,datab;

    assign dataa = shift ? imm : a;
    assign datab = AluImm ? imm: b;
    
    
    wire LessThanSigned,LessThanUnsigned;
    comp_signed compare_signed (dataa,datab,LessThanSigned);
    comp_unsigned compare_unsigned(dataa,datab,LessThanUnsigned);
    
    wire [31:0] comp_out ;
    assign comp_out = sign ? {31'b0,LessThanSigned} 
                        : {31'b0,LessThanUnsigned};
    

    wire [31:0] Hi_from_alu,alu_out;
    alu alu0 (dataa,datab,AluFunc,,,Hi_from_alu,alu_out);

    wire [31:0] arith_out;
    assign arith_out = stl ? comp_out : alu_out;

    wire [31:0] Hi_to_reg;
    assign Hi_to_reg = Hi ? alu_out : Hi_from_alu;

    wire [31:0] Hi_out,Lo_out;
    dffe32 Hi_reg (Hi_to_reg,HiWrite,clk,clrn,Hi_out);
    dffe32 Lo_reg (alu_out,LoWrite,clk,clrn,Lo_out);

    wire [31:0] HL_out;
    assign HL_out = Hi ? Hi_out : Lo_out;

    reg [31:0] EXE_Result;
    always @ (*) begin
      case (ExeSelect)
        2'b00 : EXE_Result = pc8;
        2'b01 : EXE_Result = HL_out;
        2'b10 : EXE_Result = arith_out;
        2'b11 : EXE_Result = 32'b 0 ;  //need to be implement.
        default: $display("exe result select error");
      endcase
    end

    assign EXE_TargetReg = link ? 5'b11111 : TargetReg;

endmodule // pipe_exe