//FILE:         control_unit.v
//DESCRIPTION   This is the control unit for the CPU. 
//              CU controls all the functional parts in CPU. 

module control_unit_2stage(
    //instruction from IF stage
    //op,rs,rt,rd,func, 
    instruction, canceled,
    //output to register files
    rs,rt,
    //input from register files
    qa,qb,

    //data output for next stage
    da,db,imm,TargetReg, 
    
    //output control signals for next stage
    RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt,sign,
        //for different load/store instructions
    StoreMask,LoadMask,B_HW,LoadSign,
        //for ALU
    AluFunc,ExeSelect,
    //signals for data forward
    M_TargetReg,M_m2reg,M_RegWrite,E_TargetReg,E_m2reg,E_RegWrite,
    E_AluOut,M_AluOut,M_MemOut,
    //signal for detecting self-modify code
    M_MemAddr, M_MemWrite,
    //control signals for pipeline control
    I_cache_R, D_cache_R,
    CPU_stall, Stall_IF_ID, 
    //signals for branch predictor
    BP_miss,is_branch,do_branch,V_target,BP_target,
    //next PC is calculated within CU
    next_PC,
    //PC in different stage
    PC, ID_PC,EXE_PC, MEM_PC,
    //exception input from different stages
    exc_IF, exc_EXE,exc_MEM,
    //exception cause input from different stages
    IF_cause,EXE_cause,MEM_cause,
    //cancel signal from CU
    ban_IF,ban_ID,ban_EXE,ban_MEM,

    //interrupt vector input from the interrupt controller
    int_num,
    //interrupt input
    int_in,
    //interrupt accept output 
    int_rec,
    //clock input
    clk,
    //synchronize clear signal
    clr
);
    //######################## Interface description ###########################
    //-------------------------Instruction from IF stage -----------------------
    //instruction input from IF stage
    //input [5:0] op, func;
    //input [4:0] rs, rt, rd;
    input canceled;
    input [31:0] instruction;
    //If the pre-fetched instruction has been canceled at IF stage, CU treats it
    //as a nop instruction. 
    wire [5:0] op =   instruction [31:26];
    output [4:0] rs ;
    assign rs = instruction [25:21];
    output [4:0] rt ;
    assign rt = instruction [20:16];
    wire [4:0] rd =  instruction [15:11];
    wire [5:0] func = instruction [5:0];


    //--------------------Input from Register File------------------------------
    input [31:0] qa,qb;

    //--------------------Data Output to Next Stage-----------------------------
    output [31:0] da,db,imm;
    output [4:0] TargetReg;

    //--------------------------For data forward---------------------------------
    //signals for data forward. They are used for solving data hazard.
    //M_m2reg indicates there is a memory to register operation in the MEM stage
    //M_RegWrite indicates there is a register write operation in the MEM stage
    //E_m2reg and E_RegWrite are the same but for EXE stage.
    input  M_m2reg,M_RegWrite,E_m2reg,E_RegWrite;

    //This two signals tell CU target register number in register write operations
    input  [ 4:0] M_TargetReg,E_TargetReg;

    //This three signals are the data output in different stage.
    input  [31:0] E_AluOut,M_AluOut,M_MemOut;

    //-------------------------For self-modify code------------------------------
    input [31:0] M_MemAddr;
    input M_MemWrite;

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

    //These signals are used for load/store byte and half word instructions
    output StoreMask,LoadMask,B_HW,LoadSign;

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

    //------------------for pipeline control--------------------------------------
    //next PC is calculated within the CU
    output reg [31:0] next_PC;
    //cache ready inputs
    input I_cache_R, D_cache_R;
    //CPU_stall stalls cpu when cache is not ready
    output CPU_stall;
    assign CPU_stall = ~(I_cache_R & D_cache_R);
    //Stall_IF_ID disable the write enable of PC and IR register. This signal is active when
    //we need to pause the instruction fetch while other stages still go, e.g. a read
    //after write data hazard.
    output Stall_IF_ID;
    //BP_miss is active when branch predictor missed.
    //do_branch is active when a branch takes in place.
    //These two signal output is for the branch predictor to generate there history table. 
    output BP_miss;
    output do_branch;
    output is_branch,V_target;
    input [31:0] BP_target;
    //These signals abandon the instruction in each stage. Instruction should be abandoned
    //when there's a pipe line event such as BP_miss, exception,etc.
    output reg ban_IF,ban_EXE,ban_MEM;
    output ban_ID;

    //PC register from different stages. These inputs are used for control the pipeline
    //when there's a branch, interrupt or exception. 
    input [31:0] PC, ID_PC, EXE_PC, MEM_PC;

    //exceptions from different stages
    input exc_IF, exc_EXE,exc_MEM;
    input [2:0] IF_cause,EXE_cause,MEM_cause;

    //for interrupt
    input int_in;
    output int_rec;
    input [19:0] int_num;

    //-----------------for clock and synchronize clear------------------------------
    input clk,clr;


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
    wire i_unimp =0;
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
    wire ins_done = (canceled) ? 1'b1 : upc == cycle;
    always @(posedge clk)
    begin
        if (clr)
            upc <=0;
        else begin
            if (ins_done) upc <= 0;
            //If there's a read after write hazard, the ID and IF stage must be wait
            //for one clock cycle, so does the update of upc. 
            //Use a separate stall signal from Stall_ID_IF is necessary, because 
            //when a multi-cycle instruction is not finished, we use Stall_ID_IF
            //to stall the ID and IF stage, but the upc should still update. 
            else if (~Stall_RAW & ~CPU_stall) upc <= upc +1'b1;
        end
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
    //be skipped based on this signal. 
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

    //Sign indicates that weather the immediate operand is sign or unsigned. It is used
    //in ID stage for sign extension of the immediate operand, and in EXE stage for 
    //overflow exception selecting corresponding comparator for set less than operations.
    //All the offset in the instructions are signed.
    assign sign = i_bgez|i_bgezal|i_bltz|i_bltzal|i_beq|i_bne|i_blez|i_bgtz|i_addi|i_slti
                    |i_lb|i_lh|i_lw|i_lbu|i_lhu|i_sb|i_sh|i_sw|i_add|i_sub|i_slt;

    //StoreMask select the masked value as the input of memory. This signal is active
    //at the second cycle of store byte and store half word. 
    assign StoreMask = (i_sb & upc==1) | (i_sh & upc==1);

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
    assign imm = canceled ? 32'b0 : { ext16, instruction[15:0] };



    //------------------------CP0 Registers--------------------------------------
    //CP0 Reg is the register group for control the CPU. 
    //CP0_Reg[0] is Cause Register, stores the number of interrupt or exception.
    //Cause register is 32-bit. Each cause input has 3 bits, the cause register
    //is arranged as below:
    //       -----------------------------------------
    //       |            CAUSE     REGISTER          |
    //       ------------------------------------------
    //       |31   |28   |25   |22   |19             0|
    //       -----------------------------------------
    //       | IF  | ID  | EXE | MEM |  interrupt     |
    //       -----------------------------------------
    //CP0_Reg[1] is Status Register, controls the interrupt mask. 
    //For now we use the lowest bit of this register for interrupt mask, other bit
    //of this register is currently reserved. 
    //      -------------------------------------------
    //      |           STATUS   REGISTER             |
    //      -------------------------------------------
    //      |31                             1|  0     |
    //      -------------------------------------------
    //      |        reserved                |INT mask|
    //      -------------------------------------------
    //CP0_Reg[2] is Base Register, stores the entry of the interrupt /exception
    //  service program. 
    //CP0_REG[3] is EPC Register, stores the return address for eret instruction. 
    //This group of control registers is accessed by mfc0 and mtc0, and indexed
    //by the rd field of the instructions. 
    //CP0_REG[4] is the backup of STATUS register. 
    reg [31:0] CP0_Reg[5];

    wire [31:0] CP0_reg_out = CP0_Reg[rd];

    //implement of mfc0 and mtc0
    //mtc0 is done in ID stage itself, The output of register file feed into 
    //CU's CP0_reg_in, rd field as index, i_mtc0 signal controls the write enable.
    //mfc0 is done at WB stage. rd as index, the output of CP0 register group is
    //selected by the I_MFC0; At EXE stage, the output of CP0 register add 
    //rs which is zero, then skip MEM stage, send to target register in WB stage. 
    assign db = i_mfc0 &~ban_ID ? CP0_reg_out : regB;
    assign da = regA;

    //------------------------Data Forward Logic--------------------------------
    //need_rs is active when a instruction needs rs as operand. 
    wire need_rs = ~(i_eret|i_mfc0|i_mtc0|i_syscall|i_lui|i_j|i_jal|i_sll|i_srl|i_sra)
                    ;
    //need_rt is active when a instruction needs rt as operand. 
    wire need_rt = ~(i_eret|i_syscall|i_bgez|i_bgezal|i_bltz|i_bltzal|i_blez|i_bgtz|i_j
                    |i_jal|i_jr|i_jalr) ;
    
    // When there's a read after 
    //write hazard, the IF and ID stage need to stop for one clock cycle to wait
    //the data at the MEM stage. Current instruction in ID stage will be executed
    //twice, so there should be a cancel signal to abandon the current instruction. 
    //A read after write hazard happens when the last instruction is a load instruction,
    //and the followed instruction use the target register of the previous load 
    //instruction. ID stage can spot this hazard by compare the EXE stage's situation. 
    //E_RegWrite and E_m2reg in EXE stage are high means that there's a load instruction
    //in EXE stage now, and if the target of this instruction (E_TargetReg) is the same
    //as one of the operand (rs or rt) of the current instruction, Stall_RAW is HIGH,
    //The instruction fetch is paused for one clock cycle. 
    //The update of upc is also stopped. 
    wire Stall_RAW = E_RegWrite & E_m2reg & (E_TargetReg!=0) 
                        &(need_rs & (E_TargetReg==rs)| need_rt & (E_TargetReg==rt));
    
    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    //When a RAW hazard happens, Stall_RAW and Stall_ID_IF will be HIGH, so the IF and 
    //ID stage is stalled, and other stage can still run. But when ban_ID_EXC is high,
    //the RAW hazard in ID stage will be canceled. 
    wire ban_ID_RAW = Stall_RAW;

    reg [31:0] regA, regB;
    //data forward for rs
    always @(*) begin
        //case 1：current instruction's first operand is the same as the target register 
        //of the EXE stage, and the EXE stage is not a load instruction, the pipeline
        //doesn't need to stop. 
        if (need_rs & E_RegWrite & (E_TargetReg!=0) & (E_TargetReg == rs) & ~E_m2reg)
            regA = E_AluOut;
        //case 2: current instruction's first operand is the same as the target register
        //of the MEM stage, and the MEM stage is not a load instruction, the pipeline
        //doesn't need to stop. 
        else if (need_rs & M_RegWrite & (M_TargetReg !=0) & (M_TargetReg == rs) & ~M_m2reg)
            regA = M_AluOut;
        //case 3: current instruction's first operand is the same as the target register
        //of the last instruction, and the last instruction is a load instruction.
        //As mentioned above, the IF and ID stage have been stopped for one clock cycle,
        //after the stop, the following if statement can become true, and the the memory
        //read is done, the data can be cast on the current instruction in ID stage. 
        else if (need_rs & M_RegWrite & (M_TargetReg !=0) & (M_TargetReg == rs) & M_m2reg)
            regA = M_MemOut;
        //case 0: default situation, there's no data forward. 
        else regA = qa;
    end 

    //data forward for rt
    always @(*) begin
        //Since it is similar to rs, the comments are omitted here. 
        if (need_rt & E_RegWrite & (E_TargetReg !=0) & (E_TargetReg == rt) & ~E_m2reg)
            regB =E_AluOut;
        else if (need_rt & M_RegWrite & (M_TargetReg !=0) & (M_TargetReg == rt) & ~M_m2reg)
            regB = M_AluOut;
        else if (need_rt & M_RegWrite & (M_TargetReg !=0) & (M_TargetReg == rt) & M_m2reg)
            regB =M_MemOut;
        else regB = qb;
    end

    //--------------generate cancel and stall signals for ID ------------------
    assign Stall_IF_ID = ~ins_done | Stall_RAW;
    
    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    assign ban_ID = ban_ID_RAW ;
    
    //------------------------Branch and Branch Prediction----------------------
    //I have implement a simple static branch predictor, which always 
    //predicts the branch not happen. When a branch instruction is decoded and
    //the result of branch is calculated, CU compare the branch result with PC,
    //if prediction is wrong, abandon the pre-fetched instruction. 

    //Jump target for J/Jal instruction. Different with the original MIPS 32 instruction. 
    //This CPU don't have delay slot, so upper bit of the target is the corresponding
    //bits of the address of the branch instruction itself. 
    wire [31:0] jpc = {ID_PC[31:28],instruction[25:0],2'b00};

    //Branch offset for conditional branch instructions. 
    wire [31:0] br_offset = {imm[29:0],2'b00};
    //Target address for conditional branch instructions. 
    wire [31:0] bpc = br_offset + ID_PC;

    //Target address for jump register instructions
    wire [31:0] rpc = regA;

    //Target address for eret instruction. 
    wire [31:0] epc = CP0_Reg[3];

    
    //signals for conditional branch. 
    wire   rs_equal_0,rs_rt_equal,rs_less_than_0;
    assign rs_equal_0 = (regA ==  32'b0);
    assign rs_rt_equal = (regA == regB);
    assign rs_less_than_0 = regA[31];

    //select the correct branch target
    reg [31:0] br_target;
    always @(*) begin
         //unconditional branch instructions
        if (i_j|i_jal)          br_target = jpc;
        //unconditional branch register instructions
        else if (i_jr|i_jalr)   br_target = rpc;
        //return from exception
        else if (i_eret)        br_target = epc;
        //conditional branch instructions
        else if (((i_bgez|i_bgezal)&(~rs_less_than_0))|((i_bltz|i_bltzal)&rs_less_than_0)
            |(i_blez&(rs_less_than_0|rs_equal_0))|(i_beq&rs_rt_equal)|(i_bne&(~rs_rt_equal)))
                                br_target = bpc;
        //normal target
        else                    br_target = ID_PC + 4;
    end
        //These signals are used for the branch predictor. 
    //is_branch is HIGH if current instruction in ID stage is a branch instruction. 
    //This signal with ID_PC together, can let the branch predictor know that
    //an address holds a branch instruction, then the BP can assign a slot for
    //that address.
    assign is_branch =(i_j|i_jal|i_jr|i_jalr|i_bgez|i_bgezal|i_bltz|i_bltzal
                |i_blez|i_beq|i_bne|i_eret)&~ban_ID;
    //do_branch is HIGH if a branch takes place. 
    //This signal together with is_branch and BP_miss, can let the branch predictor 
    //know when to update the history table. 
    //assign do_branch = (i_j|i_jal|i_jr|i_jalr|((i_bgez|i_bgezal)&(~rs_less_than_0))
    //            |((i_bltz|i_bltzal)&rs_less_than_0)|(i_blez&(rs_less_than_0|rs_equal_0))
    //            |(i_beq&rs_rt_equal)|(i_bne&(~rs_rt_equal))|i_eret)&~ban_ID;

    //If there's a branch, compare the branch target with the current PC, if the two
    //are not equal, then there's a BP miss, pre-fetched instruction should be 
    //canceled.  
    assign BP_miss =  (PC != br_target) ;

    //Some of the branch instructions such as j and jal have fixed target, while
    //some branch instructions such as jr and jalr have  variable target. 
    //The branch predictor must understand these conditions when making predictions. 
    assign V_target = i_jr | i_jalr | i_eret;
endmodule