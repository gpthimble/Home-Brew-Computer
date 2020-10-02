 module pipe_id(
   M_TargetReg, M_m2reg,M_RegWrite,E_TargetReg,E_m2reg,E_RegWrite,
   E_AluOut,M_AluOut,M_MemOut,                      //data forward
   pc4,inst,
   clk,clrn,W_DataIn,W_TargetReg,W_RegWrite,        //regfile
   ConditBranch_pc,JumpReg_pc,JumpImm_pc,pc_source, //next pc source
   nostall,                                         //stall pipeline due to lw
   RegWrite,M2Reg,MemWrite,AluFunc,AluImm,pc4_out,a,b,imm,TargetReg,shift,link,
   HiWrite,LoWrite,Hi,stl,sign,ExeSelect    //support for MTHI MTLO MFHI MFLO
 );
    //32 bits data
    input [31:0] pc4,inst,W_DataIn,E_AluOut,M_AluOut,M_MemOut;
    //5 bits reg ports
    input [ 4:0] M_TargetReg,E_TargetReg,W_TargetReg;       
    //feedback signal for data forward
    input        M_m2reg,M_RegWrite,E_RegWrite,E_m2reg,W_RegWrite;
    //clock and clear when negtive for regfile 
    input        clk, clrn;
    //32 bits output for next pc source
    output [31:0] ConditBranch_pc,JumpReg_pc,JumpImm_pc;
    //32 bits output for alu oprands
    output [31:0] a,b,imm;
    //5 bits reg port
    output [ 4:0] TargetReg;
    //alu function code
    output [ 3:0] AluFunc;
    //next pc source select signal
    output [ 1:0] pc_source;

    output [31:0] pc4_out;

    assign pc4_out = pc4;

    output [ 1:0] ExeSelect;
    //other control signals
    output nostall,RegWrite,M2Reg,MemWrite,AluImm,
           shift,link,HiWrite,LoWrite,Hi,stl,sign;

    wire [ 5:0] func,op;  
    wire [ 4:0] rs,rt,rd;
    wire [31:0] qa,qb,ConditBranch_offset;
    wire [15:0] ext16;
    wire [ 1:0] fwda,fwdb;
    wire        TargetRegSelect,e;
    //split the instruction word into several parts
    assign func = inst [5:0];
    assign op   = inst [31:26];
    assign rs   = inst [25:21];
    assign rt   = inst [20:16];
    assign rd   = inst [15:11];
    assign JumpImm_pc = {pc4[31:28],inst[25:0],2'b00};
    assign JumpReg_pc = a;


    //connect the register file
    regfile regfile0 (rs,rt,qa,qb,W_TargetReg,W_DataIn,W_RegWrite,~clk,clrn);
    //mux for data forwarding,control by fwda and fwdb
    reg [31:0] a , b;
    always @(*)begin
      case (fwda)
        2'b00 : a = qa;
        2'b01 : a = E_AluOut;
        2'b10 : a = M_AluOut;
        2'b11 : a = M_MemOut; 
        default: $display("Error in data forward a ");
      endcase
      case (fwdb)
        2'b00 : b = qb; 
        2'b01 : b = E_AluOut;
        2'b10 : b = M_AluOut;
        2'b11 : b = M_MemOut; 
        default: $display("Error in data forward b ");
      endcase
    end
    //mux for target register number,controlled by TargetRegSelect
    reg [ 4:0] TargetReg;
    always @(*)begin
      case (TargetRegSelect)
        1'b0 : TargetReg = rd;
        1'b1 : TargetReg = rt;
        default: $display("Error in target register select ");
      endcase
    end
    
    //immediate number signed extension
    assign e = sign & inst [15];
    assign ext16 = {16{e}};
    assign imm = {ext16,inst[15:0]};

    //conditional branch address generate
    assign ConditBranch_offset = {imm[29:0],2'b00};
    assign ConditBranch_pc = pc4 + ConditBranch_offset;

    //signals for conditional branch 
    assign rs_less_than_0 = a[31];
    assign rs_equal_0     = (a == 32'b0);
    assign rs_rt_equal    = (a==b);
    //############################################
    pipe_id_cu cu(
      M_TargetReg,M_m2reg,M_RegWrite,E_TargetReg,E_m2reg,E_RegWrite,
      E_AluOut,M_AluOut,M_MemOut,
      func,op,rs,rt,
      RegWrite,M2Reg,MemWrite,AluFunc,AluImm,shift,link,
      HiWrite,LoWrite,Hi,stl,sign,ExeSelect,
      rs_equal_0,rs_rt_equal,rs_less_than_0,pc_source, 
      TargetRegSelect,fwda,fwdb,
      nostall     ) ; //to be implemented
    //###########################################


 endmodule // pipe_id

 module pipe_id_cu(
   //signals for data forward
   M_TargetReg,M_m2reg,M_RegWrite,E_TargetReg,E_m2reg,E_RegWrite,
   E_AluOut,M_AluOut,M_MemOut,
   //instruction input
   func,op,rs,rt,
   //output control signals
   RegWrite,M2Reg,MemWrite,AluFunc,AluImm,shift,link,
   HiWrite,LoWrite,Hi,stl,sign,ExeSelect,
   //inner ID stage control input
   rs_equal_0,rs_rt_equal,rs_less_than_0,pc_source,
   //inner ID stage control output
   TargetRegSelect,fwda,fwdb,
   nostall
 );
    // signals for data forward
    input  M_m2reg,M_RegWrite,E_m2reg,E_RegWrite;
    input  [ 4:0] M_TargetReg,E_TargetReg;
    input  [31:0] E_AluOut,M_AluOut,M_MemOut;
    output reg [ 1:0] fwda,fwdb;

    // output signals for next stage
    output RegWrite,M2Reg,MemWrite,AluImm,shift,link,
           HiWrite,LoWrite,Hi,stl,sign,TargetRegSelect;
    output reg [3:0] AluFunc;
    output reg [1:0] ExeSelect;

    //IR input
    input [5:0] func,op;
    input [4:0] rs,rt;

    //conditional branch signal input
    input rs_equal_0,rs_rt_equal,rs_less_than_0;

    //pcsource select output
    output reg [1:0] pc_source;

    //pipeline stall signal;
    output nostall;

    assign r_type  = ((op == 6'b000000)? 1:0);
    assign r_type2 = ((op == 6'b011100)? 1:0);


    //supported instructions:
    //R_type
    assign i_sll = (r_type && func==6'b000000)?1:0;
    assign i_srl = (r_type && func==6'b000010)?1:0;
    assign i_sra = (r_type && func==6'b000011)?1:0;
    assign i_jr  = (r_type && func==6'b001000)?1:0;
    assign i_jalr= (r_type && func==6'b001001)?1:0;
    assign i_mfhi= (r_type && func==6'b010000)?1:0;
    assign i_mthi= (r_type && func==6'b010001)?1:0;
    assign i_mflo= (r_type && func==6'b010010)?1:0;
    assign i_mtlo= (r_type && func==6'b010011)?1:0;
    assign i_mult= (r_type && func==6'b011000)?1:0;
    assign i_multu=(r_type && func==6'b011001)?1:0;
    assign i_div = (r_type && func==6'b011010)?1:0;
    assign i_divu= (r_type && func==6'b011011)?1:0;
    assign i_add = (r_type && func==6'b100000)?1:0;
    assign i_addu= (r_type && func==6'b100001)?1:0;
    assign i_clz = (r_type2&& func==6'b100000)?1:0;
    assign i_clo = (r_type2&& func==6'b100001)?1:0;
    assign i_sub = (r_type && func==6'b100010)?1:0;
    assign i_subu= (r_type && func==6'b100011)?1:0;
    assign i_and = (r_type && func==6'b100100)?1:0;
    assign i_or  = (r_type && func==6'b100101)?1:0;
    assign i_xor = (r_type && func==6'b100110)?1:0;
    assign i_nor = (r_type && func==6'b100111)?1:0;
    assign i_slt = (r_type && func==6'b101010)?1:0;
    assign i_sltu= (r_type && func==6'b101011)?1:0;
    
    //other_type
    assign i_bgez = (op==6'b000001 && rt==5'b00001)?1:0;
    assign i_bgezal=(op==6'b000001 && rt==5'b10001)?1:0;
    assign i_bltz = (op==6'b000001 && rt==5'b00000)?1:0;
    assign i_bltzal=(op==6'b000001 && rt==5'b10000)?1:0;
    assign i_j    = (op==6'b000010)?1:0;
    assign i_jal  = (op==6'b000011)?1:0;
    assign i_beq  = (op==6'b000100)?1:0;
    assign i_bne  = (op==6'b000101)?1:0;
    assign i_blez = (op==6'b000110)?1:0;
    assign i_bgtz = (op==6'b000111)?1:0;
    assign i_addi = (op==6'b001000)?1:0;
    assign i_addiu= (op==6'b001001)?1:0;
    assign i_slti = (op==6'b001010)?1:0;
    assign i_sltiu= (op==6'b001011)?1:0;
    assign i_andi = (op==6'b001100)?1:0;
    assign i_ori  = (op==6'b001101)?1:0;
    assign i_xori = (op==6'b001110)?1:0;
    assign i_lui  = (op==6'b001111)?1:0;
    assign i_lw   = (op==6'b100011)?1:0;
    assign i_sw   = (op==6'b101011)?1:0;


    assign RegWrite = (i_sll|i_srl|i_sra|i_jalr|i_mfhi|i_mflo|i_add|i_clz|i_addu|
             i_clo|i_sub|i_subu|i_and|i_or|i_xor|i_nor|i_slt|i_sltu|i_jal|i_addi|
             i_addiu|i_slti|i_sltiu|i_andi|i_ori|i_xori|i_lui|i_lw|
             (i_bgezal&&(~rs_less_than_0))|(i_bltzal&&rs_less_than_0))&nostall;
    assign M2Reg    = i_lw;
    assign MemWrite = i_sw & nostall;
    assign AluImm   = i_sw|i_addi|i_addiu|i_slti|i_sltiu|i_andi|i_ori|i_xori|i_lui|i_lw;
    assign shift    = i_sll|i_srl|i_sra;
    assign link     = i_bgezal|i_bltzal|i_jalr|i_jal;
    assign HiWrite  = i_mthi|i_mult|i_multu|i_div|i_divu;
    assign LoWrite  = i_mtlo|i_mult|i_multu|i_div|i_divu;
    assign Hi       = i_mfhi|i_mthi;
    assign stl      = i_slt|i_sltu|i_slti|i_sltiu;
    assign sign     = i_add|i_sub|i_bgez|i_bltz|i_beq|i_bne|i_blez|i_bgtz|i_sw|i_addi|
              i_lw|i_bgezal|i_bltzal|i_mult|i_div|i_slt|i_slti;
    assign TargetRegSelect = i_addiu|i_andi|i_ori|i_xori|i_lui|i_sltiu|i_addi|i_lw|i_slti;
    

    //alu function code generate
    always @ (*) begin
      AluFunc = 4'b0000;
      if (i_subu|i_sub)       AluFunc = 4'b0001;
      else if (i_clz)         AluFunc = 4'b0010;
      else if (i_clo)         AluFunc = 4'b0011;
      else if (i_and|i_andi)  AluFunc = 4'b0100;
      else if (i_xor|i_xori)  AluFunc = 4'b0101;
      else if (i_or|i_ori)    AluFunc = 4'b0110;
      else if (i_nor)         AluFunc = 4'b0111;
      else if (i_sll)         AluFunc = 4'b1000;
      else if (i_lui)         AluFunc = 4'b1001;
      else if (i_srl)         AluFunc = 4'b1010;
      else if (i_sra)         AluFunc = 4'b1011;
      else if (i_mult)        AluFunc = 4'b1100;
      else if (i_multu)       AluFunc = 4'b1101;
      else if (i_div)         AluFunc = 4'b1110;
      else if (i_divu)        AluFunc = 4'b1111;
    end

    //EXE stage select code generate
    always @ (*) begin
      ExeSelect = 2'b10;
      if (link)               ExeSelect = 2'b00;
      else if (i_mflo|i_mfhi) ExeSelect = 2'b01;                  
      //more option for mfc0 mtc0 need to be implement;
    end


    //pc source select code generate
    always @ (*) begin
      pc_source = 2'b00;
      if (i_j|i_jal)          pc_source = 2'b11;
      else if (i_jr|i_jalr)   pc_source = 2'b10;
      else if (((i_bgez|i_bgezal)&(~rs_less_than_0))|((i_bltz|i_bltzal)&rs_less_than_0)
        |(i_blez&(rs_less_than_0|rs_equal_0))|(i_beq&rs_rt_equal)|(i_bne&(~rs_rt_equal)))
                              pc_source = 2'b01;
    end

    //data forward logic
      // rs is needed
    assign i_rs = ~(i_sll|i_srl|i_sra|i_mfhi|i_mflo|i_j|i_jal|i_lui);
      // rt is needed
    assign i_rt = i_sll|i_srl|i_sra|i_mult|i_multu|i_div|i_divu|i_add|i_clz|i_addu|
            i_clo|i_sub|i_subu|i_and|i_or|i_xor|i_nor|i_slt|i_sltu|i_beq|i_bne|i_sw;

    assign nostall = ~(E_RegWrite & E_m2reg & (E_TargetReg != 0) 
                        &(i_rs&(E_TargetReg==rs)|i_rt&(E_TargetReg==rt)));
    
    always @(*) begin
      fwda = 2'b00;
      if (i_rs & E_RegWrite & (E_TargetReg!=0) & (E_TargetReg==rs) & ~E_m2reg) 
              fwda = 2'b01;
      else if (i_rs & M_RegWrite & (M_TargetReg!=0) & (M_TargetReg == rs) & ~M_m2reg)
              fwda = 2'b10;
      else if (i_rs & M_RegWrite & (M_TargetReg!=0) & (M_TargetReg == rs) & M_m2reg)
              fwda = 2'b11;
    end
    
    always @(*) begin
      fwdb = 2'b00;
      if (i_rt & E_RegWrite & (E_TargetReg!=0) & (E_TargetReg==rt) & ~E_m2reg) 
              fwdb = 2'b01;
      else if (i_rt & M_RegWrite & (M_TargetReg!=0) & (M_TargetReg == rt) & ~M_m2reg)
              fwdb = 2'b10;
      else if (i_rt & M_RegWrite & (M_TargetReg!=0) & (M_TargetReg == rt) & M_m2reg)
              fwdb = 2'b11;
    end



 endmodule // pipe_id_cu