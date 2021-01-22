//FILE:         control_unit.v
//DESCRIPTION   This is the control unit for the CPU. 
//              CU controls all the functional parts in CPU. 

module control_unit(
    //instruction from IF stage
    //op,rs,rt,rd,func, 
    instruction, canceled,
    //output to register files
    rs,rt,
    //input from register files
    qa,qb,

    //data output for next stage
    da,db,imm,TargetReg, 

    //signals for data forward
    M_TargetReg,M_m2reg,M_RegWrite,E_TargetReg,E_m2reg,E_RegWrite,
    E_AluOut,M_AluOut,M_MemOut,

    //signal for detecting self-modify code
    M_MemAddr, M_MemWrite,

    //output control signals for next stage
    RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt,sign,
        //for different load/store instructions
    StoreMask,LoadMask,B_HW,LoadSign,
        //for ALU
    AluFunc,ExeSelect,

    //control signals for pipeline control
    pc_source,
    CPU_stall, Stall_IF_ID, do_branch, BP_miss,ban_IF,ban_ID,ban_EXE,ban_MEM,


    //PC in different stage
    PC, ID_PC,EXE_PC, MEM_PC,

    //exception input from different stages
    exc_IF, exc_EXE,exc_MEM,
    //exception cause input from different stages
    IF_cause,EXE_cause,MEM_cause,
    //interrupt vector input from the interrupt controller
    int_num,
    //interrupt input
    int_in,
    //interrupt accept output 
    int_ack,
    //clock input
    clk,
    //synchronize clear signal
    clr,
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
    wire [5:0] op = canceled ? 6'b0 : instruction [31:26];
    output [4:0] rs ;
    assign rs = canceled ? 5'b0 : instruction [25:21];
    output [4:0] rt ;
    assign rt = canceled ? 5'b0 : instruction [20:16];
    wire [4:0] rd = canceled ? 5'b0 : instruction [15:11];
    wire [5:0] func = canceled ? 6'b0 : instruction [5:0];


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
    //pc_source controls the mux for next pc, this is important when handling branch,
    //interrupt and exception.
    output pc_source;
    //CPU_stall stalls cpu when cache is not ready
    output CPU_stall;
    //Stall_IF_ID disable the write enable of PC and IR register. This signal is active when
    //we need to pause the instruction fetch while other stages still go, e.g. a read
    //after write data hazard.
    output Stall_IF_ID;
    //BP_miss is active when branch predictor missed.
    //do_branch is active when a branch takes in place.
    //These two signal output is for the branch predictor to generate there history table. 
    output BP_miss;
    output do_branch;
    //These signals abandon the instruction in each stage. Instruction should be abandoned
    //when there's a pipe line event such as BP_miss, exception,etc.
    output reg ban_IF,ban_ID,ban_EXE,ban_MEM;

    //PC register from different stages. These inputs are used for control the pipeline
    //when there's a branch, interrupt or exception. 
    input [31:0] PC, ID_PC, EXE_PC, MEM_PC;

    //exceptions from different stages
    input exc_IF, exc_EXE,exc_MEM;
    input [2:0] IF_cause,EXE_cause,MEM_cause;

    //for interrupt
    input int_in;
    output int_ack;
    input [19:0] int_num;

    //-----------------for clock and synchronize clear------------------------------
    input clk,clr;


    //######################## Module Implementation ###########################

    //-----------------------Decode the Instructions------------------------------
    //the instruction is R-type if the op code is 000000(SPECIAL), 011100(SPECIAL2)
    //or 010000(CP0). 
    wire r_type  = ((op == 6'b000000)? 1:0);
    wire r_type_2 = ((op == 6'b011100)? 1:0);
    wire r_type_cp0 = ((op == 6'b010000)? 1:0);

    //supported instructions:
    //R_type
    wire i_eret = (r_type_cp0 && rs==5'b10000 && func==6'b011000)?1:0;
    wire i_mfc0 = (r_type_cp0 && rs==5'b00000) ? 1:0;
    wire i_mtc0 = (r_type_cp0 && rs==5'b00100) ? 1:0;

    wire i_syscall = (r_type && func ==6'b001100) ? 1:0;

    wire i_sll  = (r_type && func==6'b000000) ? 1:0;
    wire i_srl  = (r_type && func==6'b000010) ? 1:0;
    wire i_sra  = (r_type && func==6'b000011) ? 1:0;
    wire i_sllv = (r_type && func==6'b000100) ? 1:0;
    wire i_srlv = (r_type && func==6'b000110) ? 1:0;
    wire i_srav = (r_type && func==6'b000111) ? 1:0;
    wire i_jr   = (r_type && func==6'b001000) ? 1:0;
    wire i_jalr = (r_type && func==6'b001001) ? 1:0;
    wire i_add  = (r_type && func==6'b100000) ? 1:0;
    wire i_addu = (r_type && func==6'b100001) ? 1:0;
    wire i_sub  = (r_type && func==6'b100010) ? 1:0;
    wire i_subu = (r_type && func==6'b100011) ? 1:0;
    wire i_and  = (r_type && func==6'b100100) ? 1:0;
    wire i_or   = (r_type && func==6'b100101) ? 1:0;
    wire i_xor  = (r_type && func==6'b100110) ? 1:0;
    wire i_nor  = (r_type && func==6'b100111) ? 1:0;
    wire i_slt  = (r_type && func==6'b101010) ? 1:0;
    wire i_sltu = (r_type && func==6'b101011) ? 1:0;

    wire i_clz  = (r_type_2 && func==6'b100000) ? 1:0;
    wire i_clo  = (r_type_2 && func==6'b100001) ? 1:0;

    //I_type
    wire i_bgez   = (op==6'b000001 && rt==5'b00001) ? 1:0;
    wire i_bgezal = (op==6'b000001 && rt==5'b10001) ? 1:0;
    wire i_bltz   = (op==6'b000001 && rt==5'b00000) ? 1:0;
    wire i_bltzal = (op==6'b000001 && rt==5'b10000) ? 1:0;
    wire i_beq    = (op==6'b000100) ? 1:0;
    wire i_bne    = (op==6'b000101) ? 1:0; 
    wire i_blez   = (op==6'b000110) ? 1:0;
    wire i_bgtz   = (op==6'b000111) ? 1:0;
    wire i_addi   = (op==6'b001000) ? 1:0;
    wire i_addiu  = (op==6'b001001) ? 1:0;
    wire i_slti   = (op==6'b001010) ? 1:0;
    wire i_sltiu  = (op==6'b001011) ? 1:0;
    wire i_andi   = (op==6'b001100) ? 1:0;
    wire i_ori    = (op==6'b001101) ? 1:0;
    wire i_xori   = (op==6'b001110) ? 1:0;
    wire i_lui    = (op==6'b001111) ? 1:0;
    wire i_lb     = (op==6'b100000) ? 1:0;
    wire i_lh     = (op==6'b100001) ? 1:0;
    wire i_lw     = (op==6'b100011) ? 1:0;
    wire i_lbu    = (op==6'b100100) ? 1:0;
    wire i_lhu    = (op==6'b100101) ? 1:0;
    wire i_sb     = (op==6'b101000) ? 1:0;
    wire i_sh     = (op==6'b101001) ? 1:0;
    wire i_sw     = (op==6'b101011) ? 1:0;

    //J_type
    wire i_j   = (op==6'b000010) ? 1:0;
    wire i_jal = (op==6'b000011) ? 1:0;

    //for instructions which are not implemented. 
    wire i_unimp =0;
    //------------------------Multi-cycle instructions----------------------------
    //cycle implies number of cycles for a instruction
    //The width of this signal is variable. For now the maximum is 2 clock cycles,
    //so the cycle is 1 bit long.
    wire cycle = (i_sb|i_sh) ? 1 : 0;
    //upc is the micro program counter for multi-cycle instructions.
    //upc is cleared when a instruction is done.
    //As mentioned above the width of this counter is variable.
    reg upc;
    //New instruction is fetched only when last instruction is done.
    wire ins_done = (canceled | ban_ID_EXC) ? 1 : upc == cycle;
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
            else if (~Stall_RAW & ~CPU_stall) upc <= upc +1;
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
    always @(posedge clk)
    begin
        if (clr)
        begin
           integer i;
            for (i = 0; i < 5; i = i + 1)
                CP0_Reg[i] <= 0; 
        end
        else if (i_mtc0 & ~ban_ID)
            CP0_Reg[rd] <= regB;
            begin
            //write the STATUS register CP0_Reg[1]
                //when there's an exception or interrupt
                //This has a higher priority than mtc0. 
                if (update_STATUS_exc) begin
                    CP0_Reg[1] <= STATUS_exc_in;
                end 
                //when there's an eret instruction. 
                else if (i_eret & ~ban_ID) begin
                //when there's an eret, status register recovers it's previous value
                    CP0_Reg[1] <= CP0_Reg[4];
                end
                //when there's a mtc0 instruction. 
                else if (i_mtc0 & ~ban_ID & rd == 1) begin
                    CP0_Reg[1] <= regB;
                end

            //write the CAUSE register CP0_Reg[0]
                //when there's an exception or interrupt
                if (update_CAUSE_exc) begin
                    CP0_Reg[0] <= CAUSE_exc_in;
                end
                //when there's an eret instruction. 
                else if (i_eret & ~ban_ID) begin
                //when there's an eret, cause register is set to zeros. 
                    CP0_Reg[0] <= 32'b0;
                end
                //when there's a mtc0 instruction. 
                else if (i_mtc0 & ~ban_ID & rd == 0) begin
                    CP0_Reg[0] <= regB;
                end

            //write the EPC register CP0_Reg[3]
                //when there's an exception or interrupt
                if (update_EPC_exc) begin
                    CP0_Reg[3] <= EPC_exc_in;
                end
                //when there's an eret instruction. 
                else if (i_eret & ~ban_ID) begin
                //when there's an eret, EPC register is set to zeros.
                    CP0_Reg[3] <= 32'b0;
                end
                //when there's mtc0 instruction. 
                else if (i_mtc0 & ~ban_ID & rd == 3) begin  
                    CP0_Reg[3] <= regB;
                end
            
            //write the BASE register CP0_Reg[2]
            //BASE register is not changed by exceptions or interrupts
            //mtc0 instruction can change the value of it. 
                if (i_mtc0 & ~ban_ID & rd == 2) begin
                    CP0_Reg[2] <= regB;
                end

            //write the STATUS_bak register CP0_Reg[4]
                //when there's an exception or interrupt. 
                if (update_STATUS_exc) begin
                    CP0_Reg[4] <= STATUS_bak_in;
                end
                //when there's an eret instruction. 
                else if (i_eret & ~ban_ID) begin
                //when there's an eret, the STATUS_bak register is set to zeros. 
                    CP0_Reg[4] <= 32'b0;
                end
                //when there's mtc0 instruction. 
                else if (i_mtc0 & ~ban_ID & rd == 4) begin
                    CP0_Reg[4] <= regB;
                end
            end
    end
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
                    & ~ban_ID_EXC;
    //need_rt is active when a instruction needs rt as operand. 
    wire need_rt = ~(i_eret|i_syscall|i_bgez|i_bgezal|i_bltz|i_bltzal|i_blez|i_bgtz|i_j
                    |i_jal|i_jr|i_jalr) & ~ban_ID_EXC;
    
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
    assign ban_ID = ban_ID_RAW |ban_ID_EXC;
    
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

    //Target address for interrupt and exceptions.  CP0_Reg[2] is the base register. 
    wire [31:0] ipc = CP0_Reg[2];

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
    assign do_branch = (i_j|i_jal|i_jr|i_jalr|((i_bgez|i_bgezal)&(~rs_less_than_0))
                |((i_bltz|i_bltzal)&rs_less_than_0)|(i_blez&(rs_less_than_0|rs_equal_0))
                |(i_beq&rs_rt_equal)|(i_bne&(~rs_rt_equal))|i_eret)&~ban_ID;

    //If there's a branch, compare the branch target with the current PC, if the two
    //are not equal, then there's a BP miss, pre-fetched instruction should be 
    //canceled.  
    assign BP_miss = is_branch? (PC != br_target) : 1'b0;

    //Some of the branch instructions such as j and jal have fixed target, while
    //some branch instructions such as jr and jalr have  variable target. 
    //The branch predictor must understand these conditions when making predictions. 
    assign V_target = i_jr | i_jalr | i_eret;


    //------------------------Interrupt and Exceptions---------------------------
    //------------------------Interrupt allow signal-----------------------------
    //interrupt and exceptions module do following things:
    //1. determine when to respond to an interrupt request, also determine which
    //   exception should be responded. 
    //2. choose correct target to branch,
    //3. do the branch, change the status register and epc register 
    //    and generate instruction cancel signal simultaneously. 

    //1A. determine when to respond to an interrupt request. 
    //We have a status register (CP0_Reg[1]) which controls the overall interrupt
    //mask, but other situations should also be considered:
    //      1. Whether the instruction in ID stage is a branch instruction?
    //      2. Whether the instruction in ID stage is a multi-cycle instruction?
    //      3. Does the instruction in ID stage causes a pipeline hazard?
    //      4. Are there any exceptions?
    //      5. Whether the instruction in ID stage is mtc0?
    //As I mentioned before, one of the purpose of using branch predictor instead 
    //of delay slot is to reduce the complexity of the interrupt controller.
    //For a delay slot design, to implement aN interrupt controller, the controller
    //must know whether the instruction in ID stage is in delay slot. 
    //I hope the controller is simple, so I use a branch predictor, and don't 
    //response interrupt when the pipeline is not ready. 
    //If the current instruction in ID stage is a multi-cycle instruction and not 
    //finish it's execution yet, controller don't response interrupt ether, since
    //the ID and IF stages are stalled by the micro-PC. 
    //If current instruction in ID stage causes a pipeline hazard, controller don't
    //response interrupt either, because the ID and IF stages are stalled. 
    //Exceptions have higher priority than interrupts, when there's a exception,
    //the controller does not response interrupts.
    //Mtc0 is done in ID stage. It can change the value of registers in CU,
    //processing interrupt also changes the value of these registers, so they can
    //not happen at the same time. Mtc0 should be a high privilege instruction if
    //there's a protected mode. Mtc0 has a higher priority than interrupt. 
    //Simply put, the condition for accepting an interrupt request is that the 
    //processor is in a normal state, and the pipeline is not suspended due to a 
    //component inside the CPU.

    //When to response to an interrupt request
    wire int_mask = CP0_Reg[1][0];
    wire int_allow =  int_mask &~BP_miss & ~Stall_IF_ID & ~exc_ack & ~SMC_ack
                        &~i_mtc0 &~CPU_stall;

    //When there is an external interrupt and the external interrupt is enabled,
    //or a software interrupt 
    //or an exception occurs, the processor jumps to the base register
    //int_ack is HIGH to indicate that CPU is going to jump to base register at
    //next clock cycle. 
    assign int_ack = int_allow & int_in;

    //----------------------------self-modify code-------------------------------
    //self modify code  has an impact on IF ID and EXE stage. 
    wire IF_SMC, ID_SMC, EXE_SMC;
    assign IF_SMC = (PC == M_MemAddr) & M_MemWrite;
    assign ID_SMC = (ID_PC == M_MemAddr) & M_MemWrite;
    assign EXE_SMC = (EXE_PC == M_MemAddr) & M_MemWrite;

    //------------------------processing EXC br_miss SMC and INT----------------------
    //signals for update the STATUS register (CP1)
    reg update_STATUS_exc;
    reg [31:0] STATUS_exc_in,STATUS_bak_in;

    //signals for update the CAUSE register (CP0)
    reg update_CAUSE_exc;
    //Cause register is 32-bit. Each cause input has 3 bits, the cause register
    //is arranged as below:
    //      31    |28   |25   |22   |19             0|
    //        IF  | ID  | EXE | MEM |  interrupt     |
    reg [31:0] CAUSE_exc_in;
    //signals for update the EPC register (CP3)
    reg update_EPC_exc;
    reg [31:0] EPC_exc_in;
    //select the right npc
    //00 normal  (let the branch predictor decide)
    //01 base    (normal exceptions)
    //10 SMC_nPC (XPC for Self-modify code)
    //11 br_target (active if there's a BP miss)
    reg [1:0] nPC_sel;
    reg [31:0] SMC_nPC;

    //We have two ban signal at ID stage to avoid logic loop, ban_ID_RAW and ban_ID_EXC.
    //ban_ID_RAW has lower priority, it can't mask out the Stall_RAW but ban_ID_EXC can.
    //When a RAW hazard happens, Stall_RAW and Stall_ID_IF will be HIGH, so the IF and 
    //ID stage is stalled, and other stage can still run. But when ban_ID_EXC is high,
    //the RAW hazard in ID stage will be canceled. 
    reg ban_ID_EXC;


    always @(*) begin
        //If exception occurs at the MEM stage
        if (exc_MEM) begin
            //mask out the STATUS register to disable interrupt. 
            update_STATUS_exc =1;
            STATUS_exc_in = CP0_Reg[1] | 32'b11111111111111111111111111111110;
            STATUS_bak_in = CP0_Reg[1];
            //select the MEM stage's cause
            update_CAUSE_exc =1;
            CAUSE_exc_in = {9'b0,MEM_cause,20'b0};
            //save MEM_PC into epc
            update_EPC_exc =1;
            EPC_exc_in = MEM_PC;
            //select the next pc as BASE
            nPC_sel = 2'b01;
            //generate cancel signals
            //cancel IF ID EXE MEM here
            ban_IF = 1;
            ban_ID_EXC = 1;
            ban_EXE =1;
            ban_MEM=1;            
        end
        //for EXE stage, exception like overflow and self-modify code can happen at
        //the same time. 
        else if (exc_EXE | EXE_SMC) begin
            //如果两种异常同时发生，则优先处理自修改代码
            //事实上无论先处理那种异常，都不会产生错误，但是经过分析，不同的处理顺序影响
            //系统的效率：
            //处理SMC会忽略当前级的EXC，而处理EXC会忽略当前级的SMC。
            //处理SMC只会引入一次跳转，处理EXC会引入两次跳转；
            //由SMC产生的访存不可避免地会发生。
            //因此优先处理SMC的效率高于优先处理EXC。
            if (EXE_SMC) begin
                //no need to update the STATUS register
                update_STATUS_exc =0;
                //no need to update the cause register
                update_CAUSE_exc =0;
                //no need to update the epc register
                update_EPC_exc =0;
                //select the next pc as EXE_PC
                nPC_sel = 2'b10;
                SMC_nPC = EXE_PC;
                //generate cancel signals
                //cancel IF ID EXE here
                ban_IF =1;
                ban_ID_EXC =1;
                ban_EXE =1;
                ban_MEM = 0;
            end
            //only has exc in exe stage
            else   begin
                //update the status register
                update_STATUS_exc =1;
                STATUS_exc_in = CP0_Reg[1] | 32'b11111111111111111111111111111110;
                STATUS_bak_in = CP0_Reg[1];
                //select the EXE stage's cause
                update_CAUSE_exc =1;
                CAUSE_exc_in = {6'b0,EXE_cause,23'b0}; 
                //save EXE_PC into epc
                update_EPC_exc =1;
                EPC_exc_in = EXE_PC;
                //select the next pc as BASE
                nPC_sel = 2'b01;
                //generate cancel signals
                //cancel IF ID EXE here
                ban_IF =1;
                ban_ID_EXC =1;
                ban_EXE =1;
                ban_MEM = 0;
            end
        end
        else if (exc_ID | ID_SMC) begin
            //self-modify code has higher priority as mentioned above
            if (ID_SMC) begin
                //no need to update the STATUS register
                update_STATUS_exc =0;
                //no need to update the cause register
                update_CAUSE_exc =0;
                //no need to update the epc register
                update_EPC_exc =0;
                //select the next pc as ID_PC
                nPC_sel = 2'b10;
                SMC_nPC = ID_PC;
                //generate cancel signals
                //cancel IF ID here
                ban_IF =1;
                ban_ID_EXC =1;
                ban_EXE = 0;
                ban_MEM = 0;                   
            end
            //only has exc in ID stage
            else begin
                //update the status register
                update_STATUS_exc =1;
                STATUS_exc_in = CP0_Reg[1] | 32'b11111111111111111111111111111110;
                STATUS_bak_in = CP0_Reg[1];
                //select the ID stage's cause
                update_CAUSE_exc =1;
                CAUSE_exc_in = {3'b0,ID_cause,26'b0};
                //save ID_PC into epc
                update_EPC_exc = 1;
                EPC_exc_in = ID_PC;
                //select the next pc as BASE
                nPC_sel = 2'b01;
                //generate cancel signals
                //cancel IF ID here
                ban_IF =1;
                ban_ID_EXC =1;
                ban_EXE = 0;
                ban_MEM = 0;   
            end
        end
        //for IF stage, EXC SMC and BP miss can happen at the same time. 
        //Priority of these different situations must be considered. 
        //IF级的异常处理最复杂，除了有分支预测错误之外，还受到ID级产生的多周期、写后读引起
        //的IF ID级暂停影响。
        //首先确定EXC\SMC\BP_miss三者的优先级，BP miss的优先级最高，因为我们处理异常的的第
        //一原则是不能丢失正确的处理顺序，后两者的优先级对于程序运行的正确性来说是无所谓的
        //但正如上面所说，优先处理SMC会带来更好的性能。
        //然后要考虑这三种情况与ID级多周期、写后读之间可能发生的冲突:
        /*
            1.对于BP miss
                BP miss不会与多周期同时发生，因为当前的跳转指令均是单周期指令。但是他会和
                写后读同时发生，如果不正确处理，正确的跳转目标会因为写后读引起的ID IF级暂
                停被错过。因此这里在is branch信号中加入了&~ban_ID，只有当ID级的跳转指令
                是有效的，也就是说写后读被数据旁路和流水线暂停解决后，才可能触发BP miss，这
                样有效的目标就不会因为流水线部分暂停而错过。
            2.对于SMC
                SMC会与多周期和写后读同时发生，SMC异常因为MEM级的写入请求产生，而多周期和
                写后读仅会暂停IF和ID级，因此当他们同时发生时，如果不进行特殊的处理IF级就会
                错过SMC，将受MEM级写入影响的旧指令送入下一级流水线。这里的处理是结合cache
                中引入的cancel机制。cache中引入cancel机制原本的目的是规避总线无法处理撤销
                请求的缺陷，但是考虑到SMC信号生成的时机恰好是新的请求写入MEM级的流水线寄存
                器的时刻，在这个时候CPU是没有Stall的，I cache的请求已经完成，根据cache的撤
                销机制，可以知道此时req_sent清零，在这个时刻，cache的请求尚未向总线发出，
                可以直接撤销。因此，撤销机制可以保证在IF和ID级寄存器写入受阻时，仍能撤销当
                前受到SMC影响的请求，而SMC请求将npc设置成当前pc，PC的值不需要改变，这和IF
                级暂停并不冲突。之前对于cache同步机制的要求是总线事务至少需要两个周期，这
                是因为需要一个周期比对总线上的请求是否在cache中，但是现在SMC由CU进行检测，
                当MEM级存在一个使当前IF级受影响的请求时，可以在下一个时钟上跳直接废弃改指
                令而与此同时cache内部也将监听到总线的请求在下一个时钟上跳即可进行valid bit
                清零操作。
            3.对于EXC
                由于EXC只和当前IF级有关，因此，由于ID级产生的IF和ID级暂停不会修改IF级的内
                容，EXC也不会因为多周期和RAW被错过。
        */
        else if (exc_IF | IF_SMC | BP_miss)begin
            //If there's a branch prediction miss, handle it first
            if (BP_miss) begin
                //no need to update the STATUS register
                update_STATUS_exc =0;
                //no need to update the cause register
                update_CAUSE_exc =0;                
                //no need to update the epc register
                update_EPC_exc =0;
                //select the next pc as correct branch target
                nPC_sel = 2'b11;
                //generate cancel signals
                //only cancel IF stage
                ban_IF =1;
                ban_ID_EXC =0;
                ban_EXE = 0;
                ban_MEM = 0;                   
            end
            //otherwise, if there's a SMC in IF stage
            else if (IF_SMC) begin
                //no need to update the STATUS register
                update_STATUS_exc =0;
                //no need to update the cause register
                update_CAUSE_exc =0;                
                //no need to update the epc register
                update_EPC_exc =0;  
                //select the next pc as PC
                nPC_sel = 2'b10;
                SMC_nPC = PC;
                //generate cancel signals
                //only cancel IF stage
                //ban_IF can work with the cancel mechanism within the cache
                ban_IF =1;
                ban_ID_EXC =0;
                ban_EXE = 0;
                ban_MEM = 0;                    
            end
            //only has exc in IF stage
            else begin
                //update the status register
                update_STATUS_exc =1;
                STATUS_exc_in = CP0_Reg[1] | 32'b11111111111111111111111111111110;
                STATUS_bak_in = CP0_Reg[1];
                //select the IF stage's cause
                update_CAUSE_exc =1;
                CAUSE_exc_in = {IF_cause,29'b0};
                //save PC into epc
                update_EPC_exc = 1;
                EPC_exc_in = PC; 
                //select the next pc as BASE
                nPC_sel = 2'b01;
                //generate cancel signals
                //only cancel IF here
                ban_IF =1;
                ban_ID_EXC = 0;
                ban_EXE = 0;
                ban_MEM = 0;
            end
        end
        //interrupt only answered when the system is ready
        else if (int_ack) begin
                //update the status register
                update_STATUS_exc =1;
                STATUS_exc_in = CP0_Reg[1] | 32'b11111111111111111111111111111110;
                STATUS_bak_in = CP0_Reg[1];
                //select interrupt number as cause
                update_CAUSE_exc =1;
                CAUSE_exc_in = {12'b0,int_num};
                //when there's an external interrupt and the interrupt is allowed
                //no need to discard instructions in ID stage to handle interrupts  
                //and when the system returns from interrupt, the difference from 
                //the exception is that the next instruction after the interrupted 
                //instruction is executed. So we save PC into epc and ban IF when
                //the interrupt is processed. 
                //save PC into epc
                update_EPC_exc = 1;
                EPC_exc_in = PC;
                //select the next pc as BASE
                nPC_sel = 2'b01;
                //generate cancel signals
                //only cancel IF here
                ban_IF =1;
                ban_ID_EXC = 0;
                ban_EXE = 0;
                ban_MEM = 0;     
        end
        //Or the system is in normal state
        //This is necessary because we need a default value of these signals
        else begin
                //no need to update the STATUS register
                update_STATUS_exc =0;
                //no need to update the cause register
                update_CAUSE_exc =0;                
                //no need to update the epc register
                update_EPC_exc =0;  
                //select the next pc as normal (let the branch predictor decide)
                nPC_sel =2'b00;
                //set all cancel signal to zero
                ban_IF =0;
                ban_ID_EXC = 0;
                ban_EXE = 0;
                ban_MEM = 0;                       
        end
    end

    //These two signals are used to determine whether interrupts are allowed
    wire exc_ack = exc_IF | exc_ID | exc_EXE | exc_MEM;
    wire SMC_ack = EXE_SMC | ID_SMC | IF_SMC;

    //system call and unimplemented instruction will cause exception in ID stage. 
    wire exc_ID = i_syscall | i_unimp;
    //Cause of exception in ID stage is generated in ID stage itself. 
    reg [2:0] ID_cause;
    always @(*)
    begin
        if  (i_syscall)
            ID_cause = 3'b001;
        else if (i_unimp)
            ID_cause = 3'b010;
        else 
            ID_cause = 3'b000;
    end
endmodule