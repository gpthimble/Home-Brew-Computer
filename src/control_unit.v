//FILE:         control_unit.v
//DESCRIPTION   This is the control unit for the CPU. 
//              CU controls all the functional parts in CPU. 

module control_unit(
    //protected mode signals
        mmuEN, Vpage_I, Ppage_I, Vpage_D, Ppage_D,
    //instruction from IF stage
    //op,rs,rt,rd,func, 
        instruction, ID_canceled,
    //output to register files
        rs,rt,
    //input from register files
        qa,qb,

    //data output for next stage
        da, db, imm, TargetReg, 
    
    //output control signals for next stage
        RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt,sign,slt_sign,
        //for different load/store instructions
        StoreMask,LoadMask,B_HW,LoadSign, NotAlign,
        //for ALU
        AluFunc,ExeSelect,AllowOverflow ,
        //signal for mtc0 and mfc0 at EXC stage
        i_mtc0,i_mfc0, rd,
        //signal for multi-cycle instruction done
        ins_done,
        //signal used for branch target calculation
        bpc,no_br_pc,
        i_j,i_jal,i_jr,i_jalr,i_eret,i_bgez,i_bgezal,i_bltz,i_bltzal,i_blez,
        i_bgtz,i_beq,i_bne,
        rs_equal_0, rs_rt_equal, rs_less_than_0,
        //ID stage exception outputs
        i_syscall,i_unimp,i_not_allow,

    //for Pipeline control
        //input signals for data forward
        E_TargetReg,   E_m2reg,   E_RegWrite,
        EXC_TargetReg, EXC_m2reg, EXC_RegWrite,
        M_TargetReg,   M_m2reg,   M_RegWrite,
        EXC_AluOut,    M_AluOut,      
        //Input canceled signals
        E_canceled, EXC_canceled, M_canceled,
        //control signals for pipeline stall
        //inputs
        I_cache_R, D_cache_R,
        //outputs
        CPU_stall, Stall_IA_IF_ID, 
    //next PC is calculated within CU
        next_PC,
        //use these values as next PC in different situations
        BP_target,EXC_Br_target,
    //for exception and interrupt
        //ban signal output for different stages
        ban_IA, ban_IF, ban_ID, ban_EXE, ban_EXC,
        //PC in different stage
        ID_PC,EXE_PC,EXC_PC,
        //exception input from different stages
        EXC_code,EXC,
        EXC_BP_miss, EXC_SMC, EXC_ERET,
        //instruction done signal from EXC stage for exception interrupt control
        EXC_ins_done,

        //signal from EXC stage for write request to control registers
        EXC_mtc0, EXC_rd, CP0_reg_in, CP0_reg_out,
        //interrupt vector input from the interrupt controller
        int_num,
        //interrupt input
        int_in,
        //interrupt accept output 
        int_rec,
    //clock input
        clk
);
    //######################## Interface description ###########################
    //protected mode flag output for IA stage
    output mmuEN;
    assign mmuEN = protected_mode;
    //mmu update signals
    parameter PAGE_NUM_WIDTH = 20;
    output [PAGE_NUM_WIDTH-1: 0] Vpage_I, Ppage_I, Vpage_D, Ppage_D;
    assign Vpage_I = CP0_Reg[5][PAGE_NUM_WIDTH-1: 0];
    assign Ppage_I = CP0_Reg[6][PAGE_NUM_WIDTH-1: 0];
    assign Vpage_D = CP0_Reg[7][PAGE_NUM_WIDTH-1: 0];
    assign Ppage_D = CP0_Reg[8][PAGE_NUM_WIDTH-1: 0];

    //-------------------------Instruction from IF stage -----------------------
    //instruction input from IF stage
    //input [5:0] op, func;
    //input [4:0] rs, rt, rd;
    input [31:0] instruction;
    input ID_canceled;
    //If the pre-fetched instruction has been canceled at IF stage, CU treats it
    //as a nop instruction. 
    wire [5:0] op =   instruction [31:26];
    //output to register files
    output [4:0] rs ;
    assign rs = instruction [25:21];
    output [4:0] rt ;
    assign rt = instruction [20:16];
    wire [5:0] func = instruction [5:0];
    
    
    //--------------------Input from Register File------------------------------
    input [31:0] qa,qb;
    
    //--------------------Data Output to Next Stage-----------------------------
    output [31:0] da,db,imm;
    output [4:0] TargetReg;


    //-------------------------Control Signals to next stage---------------------
    //These signals is the decoded signal for next stage driving different part
    //in the CPU.
    //RegWrite  : instruction needs to write a register
    //M2Reg     : instruction needs to read memory into a register
    //MemReq    : instruction needs to read or write memory
    //MemWrite  : instruction needs to write memory
    //AluImm    : one of the input of ALU is a immediate number
    //shift     : operation of EXE stage is shift operation
    //link      : instruction is a jump and link instruction
    //stl       : instruction is a condition testing and conditional move operation
    output     RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt;

    //This signal controls the sign extension in ID stage, it's used for instructions
    //that needs immediate operand. It is also used in EXE stage for mask the overflow
    //signal. 
    output sign;
    output slt_sign;
    //These signals are used for load/store byte and half word instructions
    output StoreMask,LoadMask,B_HW,LoadSign,NotAlign;

    //ExeSelect : select the output of EXE stage 这个向量目前需要修改。
    //  00  :  pc8;
    //  01  :  HL_out;
    //  10  :  arith_out;
    //  11  :  32'b0   
    //我撤掉了乘法除法的支持，因此HL_out这个需要改
    //从延时槽改成了分支预测，因此pc8也需要改动
    output reg [1:0] ExeSelect;

    //AluFunc   : Alu function code when the instruction needs to use the ALU
    //               |Unit 00    | Unit 01    | Unit 10    | Unit 11    |
    //               |---------------------------------------------------
    //               |code  func | code  func | code  func | code  func |
    //               |--------------------------------------------------|
    //               |0000  ADD  | 0100  AND  | 1000  SLL  | 1100  MULT |
    //               |0001  SUB  | 0101  XOR  | 1001  LUI  | 1101  MULTU|
    //               |0010  CLZ  | 0110  OR   | 1010  SRL  | 1110  DIV  |
    //               |0011  CLO  | 0111  NOR  | 1011  SRA  | 1111  DIVU |
    output reg [3:0] AluFunc;
    output AllowOverflow ;
    //signals for mtc0 and mfc0 at EXC stage
    output i_mtc0,i_mfc0;
    //This vector is for mtc0 and mfc0 at EXC stage
    output [4:0] rd;
    assign rd =  instruction [15:11];
    //signal for indicate multi-cycle instruction done
    output ins_done;
    
    //signal used for branch target calculation
    output [31:0] bpc,no_br_pc;
    output i_j,i_jal,i_jr,i_jalr,i_eret,i_bgez,i_bgezal,i_bltz,i_bltzal,i_blez,
            i_bgtz,i_beq,i_bne;
    output   rs_equal_0,rs_rt_equal,rs_less_than_0;

    //ID stage exception outputs
    output i_syscall,i_unimp,i_not_allow;

    //------------------for pipeline control--------------------------------------
    //--------------------------For data forward---------------------------------
    //signals for data forward. They are used for solving data hazard.
    //M_m2reg indicates there is a memory to register operation in the MEM stage
    //M_RegWrite indicates there is a register write operation in the MEM stage
    //E_m2reg and E_RegWrite are the same but for EXE stage.
    input  M_m2reg,M_RegWrite,E_m2reg,E_RegWrite,EXC_m2reg,EXC_RegWrite;

    //These signals tell CU target register number in register write operations
    input  [ 4:0] M_TargetReg,EXC_TargetReg,E_TargetReg;

    //These signals are the data in different stages.
    input  [31:0] EXC_AluOut,M_AluOut;
    
    //Canceled signals for data forward
    input E_canceled, EXC_canceled, M_canceled;
    //cache ready inputs
    input I_cache_R, D_cache_R;
    //CPU_stall stalls cpu when cache is not ready
    output CPU_stall;
    assign CPU_stall = ~(I_cache_R & D_cache_R);
    //Stall_IA_IF_ID disable the write enable of PC and IR register. This signal is active when
    //we need to pause the instruction fetch while other stages still go, e.g. a read
    //after write data hazard.
    output Stall_IA_IF_ID;

    //next PC is calculated within CU
    output reg [31:0] next_PC;
    //next_PC in normal state
    input [31:0] BP_target;
    //next_PC in BP_miss
    input [31:0] EXC_Br_target;

    //These signals abandon the instruction in each stage. Instruction should be abandoned
    //when there's a pipe line event such as EXC_BP_miss, exception,etc.
    output  ban_IA,ban_IF,ban_ID,ban_EXE;
    output reg ban_EXC;
    assign ban_IA = ban_IA_IF_ID_EXE;
    assign ban_IF = ban_IA_IF_ID_EXE;
    assign ban_EXE = ban_IA_IF_ID_EXE;

    //PC register from different stages. These inputs are used for control the pipeline
    //when there's a branch, interrupt or exception. 
    input [31:0] ID_PC, EXE_PC, EXC_PC;

    //signal from EXC stage for exception and  interrupt control
    //exception input from EXC stages
    input [3:0] EXC_code;
    input EXC;
    //bpmiss, SMC and Eret signal
    input EXC_BP_miss;
    input EXC_SMC;
    input EXC_ERET;
    //ins done from EXC stage for interrupt control
    input EXC_ins_done;

    //signal from EXC stage for write request to control registers
    input EXC_mtc0;
    input [4:0] EXC_rd;
    input [31:0] CP0_reg_in;
    output [31:0] CP0_reg_out;

    //for interrupt
    input int_in;
    output int_rec;
    input [19:0] int_num;

    //-----------------for clock and synchronize clear------------------------------
    input clk;


    //######################## Module Implementation ###########################

    //-----------------------Decode the Instructions------------------------------
    //the instruction is R-type if the op code is 000000(SPECIAL), 011100(SPECIAL2)
    //or 010000(CP0). 
    wire r_type  = ((op == 6'b000000)? 1'b1:1'b0);
    wire r_type_2 = ((op == 6'b011100)? 1'b1:1'b0);
    wire r_type_cp0 = ((op == 6'b010000)? 1'b1:1'b0);

    //supported instructions:
    //R_type
    wire i_eret = (r_type_cp0 && rs==5'b10000 && func==6'b011000)?1'b1:1'b0;
    wire i_mfc0 = (r_type_cp0 && rs==5'b00000) ? 1'b1:1'b0;
    wire i_mtc0 = (r_type_cp0 && rs==5'b00100) ? 1'b1:1'b0;

    wire i_syscall = (r_type && func ==6'b001100) ? 1'b1:1'b0;

    wire i_sll  = (r_type && func==6'b000000) ? 1'b1:1'b0;
    wire i_srl  = (r_type && func==6'b000010) ? 1'b1:1'b0;
    wire i_sra  = (r_type && func==6'b000011) ? 1'b1:1'b0;
    wire i_sllv = (r_type && func==6'b000100) ? 1'b1:1'b0;
    wire i_srlv = (r_type && func==6'b000110) ? 1'b1:1'b0;
    wire i_srav = (r_type && func==6'b000111) ? 1'b1:1'b0;
    wire i_jr   = (r_type && func==6'b001000) ? 1'b1:1'b0;
    wire i_jalr = (r_type && func==6'b001001) ? 1'b1:1'b0;
    wire i_add  = (r_type && func==6'b100000) ? 1'b1:1'b0;
    wire i_addu = (r_type && func==6'b100001) ? 1'b1:1'b0;
    wire i_sub  = (r_type && func==6'b100010) ? 1'b1:1'b0;
    wire i_subu = (r_type && func==6'b100011) ? 1'b1:1'b0;
    wire i_and  = (r_type && func==6'b100100) ? 1'b1:1'b0;
    wire i_or   = (r_type && func==6'b100101) ? 1'b1:1'b0;
    wire i_xor  = (r_type && func==6'b100110) ? 1'b1:1'b0;
    wire i_nor  = (r_type && func==6'b100111) ? 1'b1:1'b0;
    wire i_slt  = (r_type && func==6'b101010) ? 1'b1:1'b0;
    wire i_sltu = (r_type && func==6'b101011) ? 1'b1:1'b0;

    wire i_clz  = (r_type_2 && func==6'b100000) ? 1'b1:1'b0;
    wire i_clo  = (r_type_2 && func==6'b100001) ? 1'b1:1'b0;

    //I_type
    wire i_bgez   = (op==6'b000001 && rt==5'b00001) ? 1'b1:1'b0;
    wire i_bgezal = (op==6'b000001 && rt==5'b10001) ? 1'b1:1'b0;
    wire i_bltz   = (op==6'b000001 && rt==5'b00000) ? 1'b1:1'b0;
    wire i_bltzal = (op==6'b000001 && rt==5'b10000) ? 1'b1:1'b0;
    wire i_beq    = (op==6'b000100) ? 1'b1:1'b0;
    wire i_bne    = (op==6'b000101) ? 1'b1:1'b0; 
    wire i_blez   = (op==6'b000110) ? 1'b1:1'b0;
    wire i_bgtz   = (op==6'b000111) ? 1'b1:1'b0;
    wire i_addi   = (op==6'b001000) ? 1'b1:1'b0;
    wire i_addiu  = (op==6'b001001) ? 1'b1:1'b0;
    wire i_slti   = (op==6'b001010) ? 1'b1:1'b0;
    wire i_sltiu  = (op==6'b001011) ? 1'b1:1'b0;
    wire i_andi   = (op==6'b001100) ? 1'b1:1'b0;
    wire i_ori    = (op==6'b001101) ? 1'b1:1'b0;
    wire i_xori   = (op==6'b001110) ? 1'b1:1'b0;
    wire i_lui    = (op==6'b001111) ? 1'b1:1'b0;
    wire i_lb     = (op==6'b100000) ? 1'b1:1'b0;
    wire i_lh     = (op==6'b100001) ? 1'b1:1'b0;
    wire i_lw     = (op==6'b100011) ? 1'b1:1'b0;
    wire i_lbu    = (op==6'b100100) ? 1'b1:1'b0;
    wire i_lhu    = (op==6'b100101) ? 1'b1:1'b0;
    wire i_sb     = (op==6'b101000) ? 1'b1:1'b0;
    wire i_sh     = (op==6'b101001) ? 1'b1:1'b0;
    wire i_sw     = (op==6'b101011) ? 1'b1:1'b0;

    //J_type
    wire i_j   = (op==6'b000010) ? 1'b1:1'b0;
    wire i_jal = (op==6'b000011) ? 1'b1:1'b0;

    //for instructions which are not implemented. 
    wire i_unimp =~(i_eret | i_mfc0 | i_mtc0 | i_syscall |i_sll | i_srl | 
                    i_sra | i_sllv | i_srlv | i_srav | i_jr | i_jalr | i_add | 
                    i_addu | i_sub | i_subu | i_and  | i_or | i_xor | i_nor | 
                    i_slt | i_sltu | i_clz | i_clo | i_bgez | i_bgezal | i_bltz|
                    i_bltzal | i_beq | i_bne | i_blez | i_bgtz | i_addi | i_addiu |
                    i_slti | i_sltiu | i_andi | i_ori | i_xori | i_lui | i_lb |
                    i_lh | i_lw | i_lbu | i_lhu | i_sb | i_sh | i_sw | i_j | i_jal);
  
    wire protected_mode = CP0_Reg[1][1];
    wire i_not_allow = protected_mode & (i_eret | i_mfc0 | i_mtc0);

    //------------------------Multi-cycle instructions----------------------------
    //cycle implies number of cycles for a instruction
    //The width of this signal is variable. For now the maximum is 2 clock cycles,
    //so the cycle is 1 bit long.
    wire cycle = (i_sb|i_sh) ? 1'b1 : 1'b0;
    //upc is the micro program counter for multi-cycle instructions.
    //upc is cleared when a instruction is done.
    //As mentioned above the width of this counter is variable.
    reg upc;
    //New instruction is fetched only when last instruction is done.
    wire ins_done = (ID_canceled | ban_ID_EXC) ? 1'b1 : upc == cycle;
    initial begin
        upc <=0;
    end
    always @(posedge clk)
    begin

            if (ins_done &~Stall_RAW & ~CPU_stall) upc <= 0;
            //If there's a read after write hazard, the ID and IF stage must be wait
            //for one clock cycle, so does the update of upc. 
            //Use a separate stall signal from Stall_ID_IF is necessary, because 
            //when a multi-cycle instruction is not finished, we use Stall_ID_IF
            //to stall the ID and IF stage, but the upc should still update. 
            else if (~Stall_RAW & ~CPU_stall) upc <= upc +1'b1;
    end


    //-------------------------generate control signals---------------------------
    //RegWrite is High when instruction needs to write registers.
    //This signal is used as write enable signal of the register file at WB stage.
    assign RegWrite = (i_mfc0|(i_bgezal & (~rs_less_than_0))|(i_bltzal & rs_less_than_0)
                    |i_addi|i_addiu|i_slti|i_sltiu|i_andi|i_ori|i_xori|i_lui|i_lb|i_lh
                    |i_lw|i_lbu|i_lhu|i_jal|i_sll|i_srl|i_sra|i_sllv|i_srlv|i_srav|i_jalr
                    |i_add|i_addu|i_sub|i_subu|i_and|i_or|i_xor|i_nor|i_slt|i_sltu|i_clz
                    |i_clo) & ~ban_ID;

    //Memory to Register is active when the instruction is a load operate. 
    //This signal is used for selecting input of register file at WB stage. 
    assign M2Reg = (i_lb|i_lh|i_lw|i_lbu|i_lhu) & ~ban_ID;

    //Memory request signal is active when the instruction needs to access the memory,
    //This signal is used at MEM stage. If accessing the memory is not needed, MEM can
    //be skipped BASEd on this signal. 
    //Store byte and Store half-word request memory access at both two cycle.
    assign MemReq = (i_lb|i_lh|i_lw|i_lbu|i_lhu|i_sb|i_sh|i_sw) & ~ban_ID;
    
    //Memory Write is active when the instruction is a store operate.
    //Store byte and Store half-word need two cycle, second cycle of these two instruction
    //need to write the memory
    assign MemWrite = (i_sb & (upc == 1)|i_sh & (upc ==1)|i_sw) & ~ban_ID;

    //AluImm indicates that operand B of ALU is an immediate operand, it is used at EXE 
    //stage.
    //For load and store instructions, memory address is calculated by alu with an 
    //16-bit immediate offset and rs.
    //Branch instructions have 16-bit immediate offset, but the target address is 
    //calculated at ID stage, so AluImm signal is zero for branch instructions.
    assign AluImm = i_addi|i_addiu|i_slti|i_sltiu|i_andi|i_ori|i_xori|i_lui|i_lb|i_lh
                    |i_lw|i_lbu|i_lhu|i_sb|i_sh|i_sw;
    
    //ShiftImm is used at EXE stage. For shift word operations, rs is 5-bit zeros, and
    //the shift amount is after rd, ShiftImm selected the correct sa into operand A of 
    //ALU. For shift word variable operations, This signal is low, since the shift amount 
    //is rs, like a normal R type instruction.
    assign ShiftImm = i_sll|i_srl|i_sra;

    //link signal is for branch and link operations. This signal is used at EXE stage,
    //link means that save corresponding pc into register 31, so when this signal is 
    //active, EXE stage will override the output of ALU with corresponding PC and select
    //31 as the target register number.
    assign link = i_bgezal|i_bltzal|i_jalr|i_jal;

    //slt is for set less than operations. When this signal is HIGH, the corresponding
    //comparator in EXE stage is active, and the output of EXE stage will be selected 
    //as the output of these comparators.
    assign slt =  i_slt|i_sltu|i_slti|i_sltiu;

    assign slt_sign = i_slt | i_slti;

    //Sign indicates that weather the immediate operand is sign or unsigned. It is used
    //in ID stage for sign extension of the immediate operand, and in EXE stage for 
    //overflow exception selecting corresponding comparator for set less than operations.
    //All the offset in the instructions are signed.
    assign sign = i_bgez|i_bgezal|i_bltz|i_bltzal|i_beq|i_bne|i_blez|i_bgtz|i_addi|i_slti
                    |i_lb|i_lh|i_lw|i_lbu|i_lhu|i_sb|i_sh|i_sw|i_addiu|i_sltiu;

    //StoreMask select the masked value as the input of memory. This signal is active
    //at the second cycle of store byte and store half word. 
    assign StoreMask = (i_sb & upc==1) | (i_sh & upc==1);
    assign NotAlign =  (i_sh & upc==0) | (i_sb & upc==0);

    //LoadMask select the masked value as the output of MEM stage. This signal is active
    //for Load byte and Load half word instruction.
    assign LoadMask = i_lb|i_lbu|i_lh|i_lhu;

    //for load/store byte/half word, B_HW is HIGH for load/store half word, and LOW for
    //load/store byte. 
    assign B_HW = i_lh|i_lhu|i_sh;

    //This is for load byte/half word signed instructions.
    assign LoadSign = i_lh|i_lb;

    //Most instructions use rd as target register, but some use rt as target. 
    //TargetRegSel is active when a instruction uses rt as target register.
    //This signal is used in ID stage. 
    wire TargetRegSelect = i_mfc0|i_addi|i_addiu|i_slti|i_sltiu|i_andi|i_ori|i_xori
                    |i_lui|i_lb|i_lh|i_lw|i_lbu|i_lhu;
    assign TargetReg = TargetRegSelect ? rt : rd;

    wire AllowOverflow = i_add | i_addi | i_sub;
    //alu function code generate
    //AluFunc   : Alu function code when the instruction needs to use the ALU
    //               |Unit 00    | Unit 01    | Unit 10    | Unit 11    |
    //               |---------------------------------------------------
    //               |code  func | code  func | code  func | code  func |
    //               |--------------------------------------------------|
    //               |0000  ADD  | 0100  AND  | 1000  SLL  | 1100  MULT |
    //               |0001  SUB  | 0101  XOR  | 1001  LUI  | 1101  MULTU|
    //               |0010  CLZ  | 0110  OR   | 1010  SRL  | 1110  DIV  |
    //               |0011  CLO  | 0111  NOR  | 1011  SRA  | 1111  DIVU |
    always @ (*) begin
      if (i_subu|i_sub)                 AluFunc = 4'b0001;
      else if (i_clz)                   AluFunc = 4'b0010;
      else if (i_clo)                   AluFunc = 4'b0011;
      else if (i_and|i_andi)            AluFunc = 4'b0100;
      else if (i_xor|i_xori)            AluFunc = 4'b0101;
      else if (i_or|i_ori)              AluFunc = 4'b0110;
      else if (i_nor)                   AluFunc = 4'b0111;
      else if (i_sll|i_sllv)            AluFunc = 4'b1000;
      else if (i_lui)                   AluFunc = 4'b1001;
      else if (i_srl|i_srlv)            AluFunc = 4'b1010;
      else if (i_sra|i_srav)            AluFunc = 4'b1011;
      //for all other situations alu performs add operation.
      else                              AluFunc = 4'b0000;
    end

    //------------------Immediate operand output---------------------------------
    //sign extension controlled by sign signal. 
    wire e = sign & instruction[15];
    wire [15:0] ext16 = {16{e}};
    assign imm = ID_canceled ? 32'b0 : { ext16, instruction[15:0] };



    //------------------------CP0 Registers--------------------------------------
    //CP0 Reg is the register group for control the CPU. 
    //CP0_Reg[0] is Cause Register, stores the number of interrupt or exception.
    //Cause register is 32-bit. Each cause input has 3 bits, the cause register
    //is arranged as below:
    //       -----------------------------------------
    //       |            CAUSE     REGISTER          |
    //       ------------------------------------------
    //       |31                     |3             0|
    //       -----------------------------------------
    //       |        interrupt      |      EXC      |
    //       -----------------------------------------
    //CP0_Reg[1] is Status Register, controls the interrupt mask. 
    //For now we use the lowest bit of this register for interrupt mask, other bit
    //of this register is currently reserved. 
    //      -------------------------------------------
    //      |           STATUS   REGISTER             |
    //      -------------------------------------------
    //      |31              2|           1   |  0     |
    //      -------------------------------------------
    //      |    reserved     | protect mode  |INT mask|
    //      -------------------------------------------
    //CP0_Reg[2] is Base Register, stores the entry of the interrupt /exception
    //  service program. 
    //CP0_REG[3] is EPC Register, stores the return address for eret instruction. 
    //This group of control registers is accessed by mfc0 and mtc0, and indexed
    //by the rd field of the instructions. 
    //CP0_REG[4] is the backup of STATUS register. 
    //CP0_REG[5] stores the virtual page number for instruction MMU
    //CP0_REG[6] stores the physical page number for instruction MMU
    //CP0_REG[7] stores the virtual page number for data MMU
    //CP0_REG[8] stores the physical page number for data MMU
    reg [31:0] CP0_Reg[9];
    
    //Alies of control registers
    wire [31:0] BASE;
    assign BASE = CP0_Reg[2];
    wire [31:0] STATUS;
    assign STATUS = CP0_Reg[1];
    wire [31:0] CAUSE;
    assign CAUSE = CP0_Reg[0];
    wire [31:0] STATUS_bak;
    assign STATUS_bak = CP0_Reg[4];
    wire [31:0] EPC;
    assign EPC = CP0_Reg[3];


    integer i;
    always @(posedge clk)
    begin
            //write the CAUSE register CP0_Reg[0]
                //when there's an exception or interrupt
                if (update_CAUSE_exc) begin
                    CP0_Reg[0] <= CAUSE_exc_in;
                end
                //when there's a mtc0 instruction. 
                else if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 0) 
                begin
                    CP0_Reg[0] <= CP0_reg_in;
                end
            //write the STATUS register CP0_Reg[1]
                //when there's an exception or interrupt
                //This has a higher priority than mtc0. 
                if (update_STATUS_exc) begin
                    CP0_Reg[1] <= STATUS_exc_in;
                end 
                //when there's a mtc0 instruction. 
                else if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 1) 
                begin
                    CP0_Reg[1] <= CP0_reg_in;
                end
            //write the BASE register CP0_Reg[2]
                //BASE register is not changed by exceptions or interrupts
                //mtc0 instruction can change the value of it. 
                if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 2) 
                begin
                    CP0_Reg[2] <= CP0_reg_in;
                end
            //write the EPC register CP0_Reg[3]
                //when there's an exception or interrupt
                if (update_EPC_exc) begin
                    CP0_Reg[3] <= EPC_exc_in;
                end
                //when there's mtc0 instruction. 
                else if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 3) 
                begin  
                    CP0_Reg[3] <= CP0_reg_in;
                end
            //write the STATUS_bak register CP0_Reg[4]
                //when there's an exception or interrupt. 
                if (update_STATUS_exc) begin
                    CP0_Reg[4] <= STATUS_bak_in;
                end
                //when there's mtc0 instruction. 
                else if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 4) 
                begin
                    CP0_Reg[4] <= CP0_reg_in;
                end
            //following control registers is for I mmu and D mmu
            //write CP0_Reg[5]
                if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 5) 
                begin
                    CP0_Reg[5] <= CP0_reg_in;
                end
            //write CP0_Reg[6]
                if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 6) 
                begin
                    CP0_Reg[6] <= CP0_reg_in;
                end
            //write CP0_Reg[7]
                if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 7) 
                begin
                    CP0_Reg[7] <= CP0_reg_in;
                end
            //write CP0_Reg[8]
                if (EXC_mtc0 & ~EXC_canceled & ~ban_EXC & EXC_rd == 8) 
                begin
                    CP0_Reg[8] <= CP0_reg_in;
                end
    end
    wire [31:0] CP0_reg_out;
    assign CP0_reg_out = CP0_Reg[EXC_rd];

    //implement of mfc0 and mtc0
    //mtc0 is done in ID stage itself, The output of register file feed into 
    //CU's CP0_reg_in, rd field as index, i_mtc0 signal controls the write enable.
    //mfc0 is done at WB stage. rd as index, the output of CP0 register group is
    //selected by the I_MFC0; At EXE stage, the output of CP0 register add 
    //rs which is zero, then skip MEM stage, send to target register in WB stage. 
    //assign db = i_mfc0 &~ban_ID ? CP0_reg_out : regB;
    
    //now mfc0 and mtc0 is done at EXC stage
    assign db = regB;
    assign da = regA;

    //------------------------Data Forward Logic--------------------------------
    //need_rs is active when a instruction needs rs as operand. 
    wire need_rs = ~(i_eret|i_mfc0|i_mtc0|i_syscall|i_lui|i_j|i_jal|i_sll|i_srl|i_sra)
                    & ~ban_ID_EXC;
    //need_rt is active when a instruction needs rt as operand. 
    wire need_rt = ~(i_eret|i_syscall|i_bgez|i_bgezal|i_bltz|i_bltzal|i_blez|i_bgtz|i_j
                    |i_jal|i_jr|i_jalr) & ~ban_ID_EXC;
    
    // When there's a read after 
    //write hazard, the IA, IF and ID stage need to stop for one or two clock cycles to wait
    //the data reach to the EXC or MEM stage. Current instruction in ID stage will be executed
    //multiple times, so there should be a cancel signal to abandon the current instruction. 
    //A read after write hazard happens when the last instruction is a load instruction,
    //and the followed instruction use the target register of the previous load 
    //instruction. Or the followed instruction used the targeted register of the last
    //instruction as its source. 
    //ID stage can spot this hazard by compare the EXE, EXC and MEM stage's situations. 
    //Situation 1:
    //  "E_RegWrite" in EXE stage are high means that there's a instruction will write 
    //  register file in EXE stage now, and if the source of current instruction is as
    //  same as the target of the instruction in EXE stage (E_TargetReg == rs or rt), 
    //  "Stall_RAW" is HIGH, and the IA, ID and IF stage will stall for one cycle.
    //Situation 2:
    //  If there's a Load instruction in EXC stage (EXC_M2Reg is high), and the target of 
    //  this instruction is the same one of the source register of the current instruction
    //  (EXC_TargetReg == rs or rt), "Stall_RAW" is HIGH, and the ID and IF stage will
    //  stall for one cycle.
    //Situation 3:
    //  If there's a Load instruction in MEM stage (M_m2reg is high), and the target of
    //  this instruction is the same one of the source register of the current instruction
    //  (M_TargetReg == rs or rt), "Stall_RAW" is HIGH, and the ID and IF stage will 
    //  stall for one cycle.
    //If IF and ID stage Stalled by RAW hazard, the update of upc is also stopped. 

    wire Stall_RAW =//situation 1
                        (E_RegWrite & ~E_canceled &  (E_TargetReg!=0) &
                        (need_rs & (E_TargetReg==rs)| need_rt & (E_TargetReg==rt))) |
                    //situation 2
                        (EXC_m2reg & ~EXC_canceled & (EXC_TargetReg != 0) &
                        (need_rs & (EXC_TargetReg==rs)| need_rt & (EXC_TargetReg==rt)))|
                    //situation 3
                        (M_m2reg & ~M_canceled & (M_TargetReg != 0) &
                        (need_rs & (M_TargetReg==rs)| need_rt & (M_TargetReg==rt)));


    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    //When a RAW hazard happens, Stall_RAW and Stall_ID_IF will be HIGH, so the IF and 
    //ID stage is stalled, and other stage can still run. But when ban_ID_EXC is high,
    //the RAW hazard in ID stage will be canceled. 
    wire ban_ID_RAW = Stall_RAW;

    reg [31:0] regA, regB;
    //data forward for rs
    always @(*) begin
        //current instruction's first operand is the same as the target register
        //of the EXC stage, and the EXC stage is not a load instruciton, the Pipeline
        //has already stalled for 1 cycle, for Situation 1 described above. 
        if (need_rs & EXC_RegWrite & (EXC_TargetReg!=0) & (EXC_TargetReg == rs) & ~EXC_m2reg & ~EXC_canceled)
            regA = EXC_AluOut;
        //current instruction's first operand is the same as the target register 
        //of the MEM stage, and the Mem stage is not a load instruction, the Pipeline has
        //already stalled for 2 cycle, for Situation 2 described above.
        else if (need_rs & M_RegWrite & (M_TargetReg!=0) & (M_TargetReg == rs) & ~M_m2reg & ~M_canceled)
            regA = M_AluOut;
        //For other situations, if there is no RAW hazard, no bypass needed.
        //If the pipeline has stalled for two cycles for situation 2 described above, or
        //the RAW hazard happened between ID and WB stage, the bypass is in the regfile.
        else regA = qa;
    end 

    //data forward for rt
    always @(*) begin
        //Since it is similar to rs, the comments are omitted here. 
        if (need_rt & EXC_RegWrite & (EXC_TargetReg!=0) & (EXC_TargetReg == rt) & ~EXC_m2reg & ~EXC_canceled)
            regB = EXC_AluOut;
        else if (need_rt & M_RegWrite & (M_TargetReg !=0) & (M_TargetReg == rt) & ~M_m2reg & ~M_canceled)
            regB =M_AluOut;
        else regB = qb;
    end

    //--------------generate cancel and stall signals for ID ------------------
    assign Stall_IA_IF_ID = (~ins_done | Stall_RAW );
    
    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    assign ban_ID = ban_ID_RAW |ban_ID_EXC;
    

    //------------------------Interrupt and Exceptions---------------------------
    //------------------------Interrupt allow signal-----------------------------
    //When to response to an interrupt request
    wire int_mask = CP0_Reg[1][0];

    //When there is an external interrupt and the external interrupt is enabled,
    //or a software interrupt 
    //or an exception occurs, the processor jumps to the BASE register
    //int_rec is HIGH to indicate that CPU is going to jump to BASE register at
    //next clock cycle. 
    assign int_rec = int_mask & int_in;


    //------------------------processing EXC br_miss EXC_SMC and INT----------------------
    //signals for update the STATUS register (CP1)
    reg update_STATUS_exc;
    reg [31:0] STATUS_exc_in,STATUS_bak_in;

    //signals for update the CAUSE register (CP0)
    reg update_CAUSE_exc;
    //Cause register is 32-bit. Each cause input has 3 bits, the cause register
    //is arranged as below:
    //      31          |3         0|
    //        interrupt |    EXC    |
    reg [31:0] CAUSE_exc_in;
    //signals for update the EPC register (CP3)
    reg update_EPC_exc;
    reg [31:0] EPC_exc_in;

    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    //When a RAW hazard happens, Stall_RAW and Stall_ID_IF will be HIGH, so the IF and 
    //ID stage is stalled, and other stage can still run. But when ban_ID_EXC is high,
    //the RAW hazard in ID stage will be canceled. 
    wire ban_ID_EXC;
    assign ban_ID_EXC = ban_IA_IF_ID_EXE;

    //generated ban signals
    reg ban_IA_IF_ID_EXE;


    //calculate branch target
    //Branch offset for conditional branch instructions. 
    wire [31:0] br_offset = imm;
    //Target address for conditional branch instructions. 
    assign bpc = br_offset + ID_PC;

    assign no_br_pc = ID_PC +4;

    //signals for conditional branch. 
    assign rs_equal_0 = (regA ==  32'b0);
    assign rs_rt_equal = (regA == regB);
    assign rs_less_than_0 = regA[31];

    //Dealing with EXC \EXC_ERET\BPmiss\EXC_SMC\INT
    always @(*) begin
        //EXC has the highest priority
        if (EXC & ~EXC_canceled) begin
            //If there's an exception, 
            //EPC <- EXC_PC, STATUS: turn INT off and backup
            //CAUSE <- EXC_code, next_PC <- BASE
            //bansignal: ban IA IF ID EXE EXC
            //update EPC
                update_EPC_exc = 1;
                EPC_exc_in = EXC_PC;
            //update STATUS
                update_STATUS_exc = 1;
                //turn off interrupt
                STATUS_exc_in = 
                        STATUS | 32'b11111111111111111111111111111110;
                //backup current STATUS
                STATUS_bak_in = STATUS;
            //update CAUSE
                update_CAUSE_exc = 1;
                CAUSE_exc_in = {28'b0,EXC_code};
            //select next_PC (BASE)
                next_PC = BASE;
            //generating ban signals
                ban_IA_IF_ID_EXE = 1;
                ban_EXC =1;
        end
        //EXC_ERET and BP miss can happen at the same time
        //EXC_ERET has higher priority
        else if (EXC_ERET & ~EXC_canceled)begin
            //If there's an EXC_ERET instruction
            //EPC: no update, STATUS <- backup
            //CAUSE: no update, next_PC <- EPC
            //bansignal: ban IA IF ID EXE
            //no update EPC
                update_EPC_exc = 0;
                EPC_exc_in = 32'b0;
            //update STATUS
                update_STATUS_exc = 1;
                //turn off interrupt
                STATUS_exc_in = STATUS_bak;
                //backup current STATUS
                STATUS_bak_in = STATUS;
            //no update CAUSE
                update_CAUSE_exc = 0;
                CAUSE_exc_in = 32'b0;
            //select next_PC (EPC)
                next_PC = EPC;
            //generating ban signals
                ban_IA_IF_ID_EXE = 1;
                ban_EXC =0;
        end
        //BP miss and EXC_SMC can't happen at the same time
        //the priority between BP miss and EXC_SMC is not important
        else if (EXC_BP_miss & ~EXC_canceled)begin
            //If there's an BP miss, internel status of the processor
            //is not changed, select Br_target as next_PC
            //bansignal: ban IA IF ID EXE
            //no update EPC
                update_EPC_exc = 0;
                EPC_exc_in = 32'b0;
            //no update STATUS
                update_STATUS_exc = 0;
                STATUS_exc_in = 32'b0;
                STATUS_bak_in = 32'b0;
            //no update CAUSE
                update_CAUSE_exc = 0;
                CAUSE_exc_in = 32'b0;
            //select next_PC (Br_Target)
                next_PC = EXC_Br_target;
            //generating ban signals
                ban_IA_IF_ID_EXE = 1;
                ban_EXC =0;

        end
        else if (EXC_SMC & ~EXC_canceled)begin
            //If there's an EXC_SMC, internel status of the processor
            //is not changed, select EXE_PC as next_PC
            //bansignal: ban IA IF ID EXE
            //no update EPC
                update_EPC_exc = 0;
                EPC_exc_in = 32'b0;
            //no update STATUS
                update_STATUS_exc = 0;
                STATUS_exc_in = 32'b0;
                STATUS_bak_in = 32'b0;
            //no update CAUSE
                update_CAUSE_exc = 0;
                CAUSE_exc_in = 32'b0;
            //select next_PC (EXE_PC)
                next_PC = EXE_PC;
            //generating ban signals
                ban_IA_IF_ID_EXE = 1;
                ban_EXC =0;
        end
        //If every thing is normal in EXC stage and the INT is allowed
        //accept interrupt request
        else if (int_in & int_mask & EXC_ins_done & ~EXC_mtc0)begin
            //When dealing with interrupt
            //EPC <- EXE_PC, STATUS: turn INT off and backup
            //CAUSE <- INT vector, next_PC <- BASE
            //bansignal: ban IA IF ID EXE
            //update EPC
                update_EPC_exc = 1;
                EPC_exc_in = EXE_PC;
            //update STATUS
                update_STATUS_exc = 1;
                //turn off interrupt
                STATUS_exc_in = 
                            STATUS | 32'b11111111111111111111111111111110;
                //back up status register
                STATUS_bak_in = STATUS;
            //update CAUSE
                update_CAUSE_exc = 1;
                CAUSE_exc_in = {int_num,4'b0000};
            //select next_PC (BASE)
                next_PC = BASE;
            //generating ban signals
                ban_IA_IF_ID_EXE = 1;
                ban_EXC =0;
        end
        //Normal state
        else begin
            //do nothing
            //no update EPC
                update_EPC_exc = 0;
                EPC_exc_in = 32'b0;
            //no update STATUS
                update_STATUS_exc = 0;
                STATUS_exc_in = 32'b0;
                STATUS_bak_in = 32'b0;
            //no update CAUSE
                update_CAUSE_exc = 0;
                CAUSE_exc_in = 32'b0;
            //select next_PC (BP_Traget)
                next_PC = BP_target;
            //generating ban signals
                ban_IA_IF_ID_EXE = 0;
                ban_EXC =0;
        end
    end
endmodule