//cpu.v
//This module implements the CPU. 
module cpu (
    //interface to the BUS
    BUS_addr, BUS_data, BUS_RW, BUS_ready,
    //interface to the BUS controller
    BUS_req_I, BUS_req_D, BUS_grant_I, BUS_grant_D,
    //interface to the interrupt controller
    int_in, 
    int_ack, 
    int_num,
    //clock and synchronized clear
    clr, clk,

    //for debugging
    //PC, next_PC_o,instruction_o,I_cache_ready,
    //ID_PC,BP_miss,CPU_stall,stall_IA_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
    //da,db,imm,
    //E_PC,E_AluOut,
    //M_PC,D_cache_dout_o,D_cache_ready,
    //W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg
    //
);
//for debugging
//output [31:0] PC,ID_PC,E_PC,M_PC, next_PC_o,instruction_o,D_cache_dout_o,W_RegDate_in
//        ,E_AluOut,da,db,imm;
//output I_cache_ready,BP_miss,stall_IA_IF_ID,W_canceled,W_RegWrite,
//        W_M2Reg,D_cache_ready,CPU_stall,ban_IF,ban_ID,ban_EXE,ban_MEM;
//output [4:0] W_TargetReg;
//assign next_PC_o = next_PC_in;
//assign instruction_o = I_cache_out;
//
//assign D_cache_dout_o =M_MemOut;
//######################## Interface description ###########################

//use mmu for address translation
//determin the size of page
parameter PAGE_NUM_WIDTH = 20;

//------------------------ interface to the bus -----------------------------
    //32-bit address BUS
    inout [31:0] BUS_addr;
    //32-bit data BUS
    inout  [31:0] BUS_data;
    // R/W line
    inout BUS_RW;
    // ready line
    input BUS_ready;
//----------------------- interface to the BUS controller------------------
//Both I cache and D cache is in CPU, the BUS interface is for two caches, since
//only these two part interact with BUS in CPU. 
    //DMA0 for I cache
    output BUS_req_I;
    //DMA1 for D cache
    output BUS_req_D;
    //grant for I cache
    input BUS_grant_I;
    //grant for D cache
    input BUS_grant_D;
    //maybe bus error in future
    //input BUS_error
//--------------------- interface to the interrupt controller--------------
    //External interrupt in. Interrupt controller send this signal to CPU and
    //tells CPU to process the interrupt.
    input int_in;
    //Interrupt ack. If the interrupt is processed by CPU, CPU send this signal
    //to the interrupt controller, and the controller withdraw the request after
    //interrupt ack.
    output reg int_ack;
    //20-bit interrupt vector number input.
    input [19:0] int_num;
//--------------------- clock and clear-------------------------------------
    input clk,clr;

//--------------------- for debugging -------------------------------------
//maybe pipeline registers output 


//######################## Module Implementation ###########################
//-----------------------declare names--------------------------------------
//all names that referrenced in different stages appears here
    //BP stage
        //mmu_en_CU is read from control registers
            wire mmu_en_CU;
        //next_PC is calculated in CU
            wire [31:0] next_PC;
        //BP_target is feed into the CU to generate next_PC
            wire [31:0] BP_target;

    //Pipleline registers between BP and IA stage
            reg IA_mmuEN;
            reg [31:0] IA_PC;

    //IA stage
        //These two vector come from the control registers, they can be modified
        //by mtc0 instruction. 
            wire [PAGE_NUM_WIDTH - 1 : 0] vpage_in_I, ppage_in_I;
        //calculated I cache request signal
            wire Icache_req;
        //ban signal from CU
            wire ban_IA;
        //This is the translated physical address for instruction. 
        //This address is feed into the instruction cache
            wire [31:0] paddr_I;

    //Pipeline registers between IA and IF stage
            reg IF_canceled, IF_mmuEN;
            reg [31:0] IF_PC;
            reg [3:0]  IF_EXC;

    //IF stage
        //ban signal from CU
            wire ban_IF;
    //pipeline register between IF and ID stage
            reg [31:0] ID_instruction, ID_PC;
            reg ID_canceled,ID_mmuEN;
            reg [3:0]  ID_EXC;

    //ID stage
        //for the register file
        //two read index
            wire [4:0] rs,rt;
        //two read data out
            wire [31:0] qa,qb;

        //for the control unit
        //data output to next stage
            wire [31:0] da,db,imm;
            wire [4:0] TargetReg;
        //control output to next stage
            wire RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,
                                        link,slt,sign,slt_sign;
            wire StoreMask,LoadMask,B_HW,LoadSign,NotAlign;
            wire [3:0] AluFunc;
            wire [1:0] ExeSelect;
            wire AllowOverflow;
        //signal for mtc0 and mfc0 at EXC stage
            wire i_mtc0, i_mfc0;
            wire [4:0] rd;
        //signal for multi-cycle instruction done
            wire ins_done;
        ////signal used for branch target calculation
            //target PC for conditional branch when branch or not
            wire [31:0] bpc,no_br_pc;
            wire i_j,i_jal,i_jr,i_jalr,i_eret,i_bgez,i_bgezal,i_bltz,
                    i_bltzal,i_blez, i_bgtz,i_beq,i_bne;
            wire rs_equal_0, rs_rt_equal, rs_less_than_0;
        //syscall, unimp, eret is generated in CU
        //these four kind of exception can not happen at the same time
            wire syscall,unimp, not_allow;
        //stall signal generated from CU
            wire CPU_stall;
        //stall signal for IF and ID stage generated from CU
            wire stall_IA_IF_ID;
        //I cache ready signal
            wire I_cache_ready;
        //D cache ready signal
            wire D_cache_ready;
        //cancel signal from CU
            wire ban_ID;
        //exception signal from different stages
            wire exc_IF, exc_EXE,exc_MEM;

        //interupt signal and vector
            wire int_in;
            wire [19:0] int_num;
            wire int_rec;

    //pipeline registers between ID and EXE stage
            reg E_canceled,E_mmuEN;
            reg [31:0] E_da,E_db,E_imm, E_PC;
            reg [4:0] E_TargetReg, E_EXC;
            reg E_RegWrite,E_M2Reg,E_MemReq,E_MemWrite,E_AluImm,
                E_ShiftImm,E_link,E_slt,E_sign,E_slt_sign ,E_NotAlign;
            reg E_StoreMask,E_LoadMask,E_B_HW,E_LoadSign;
            reg [3:0] E_AluFunc;
            reg [1:0] E_ExeSelect;
            reg [31:0] E_ins,E_bpc,E_no_br_pc;
            reg E_AllowOverflow;

            reg E_i_j,E_i_jal,E_i_jr,E_i_jalr,E_i_eret,E_i_bgez,E_i_bgezal,
                E_i_bltz,E_i_bltzal,E_i_blez,E_i_bgtz,E_i_beq,E_i_bne,E_ins_done;
            reg E_rs_equal_0,E_rs_rt_equal,E_rs_less_than_0;
            reg [4:0] E_rd; 
            reg E_mtc0, E_mfc0;
    
    //EXE stage
        //ban signal for EXE stage
            wire ban_EXE;
    //Pipeline registers between EXE and EXC stage
            reg EXC_canceled,EXC_mmuEN;
            reg [ 3:0] EXC_EXC;
            reg [31:0] EXC_PC,EXC_AluOut,EXC_db, EXC_BrTarget;
            reg [ 4:0] EXC_TargetReg;
            reg EXC_RegWrite,EXC_M2Reg,EXC_MemReq,EXC_MemWrite;
            reg EXC_StoreMask,EXC_LoadMask,EXC_B_HW,EXC_LoadSign,EXC_NotAlign;
            reg EXC_isBranch, EXC_VTarget,EXC_BP_miss, EXC_eret,EXC_ins_done;
            reg [4:0] EXC_rd;
            reg EXC_mtc0, EXC_mfc0;
        
    //EXC stage
        //These two vector come from the control registers, they can be modified
        //by mtc0 instruction. 
            wire [PAGE_NUM_WIDTH - 1 : 0] vpage_in_D, ppage_in_D;
        //ban signal for EXC stage
            wire  ban_EXC;
        //This is the translated physical address for data. 
        //This address is feed into the data cache
            wire [31:0] paddr_D;
        //for mtc0 and mfc0
            wire[31:0] EXC_AluOut_mux,CP0_reg_out;

        //SMC signal is generated here
            reg EXC_SMC;
        //ERET signal is generated here
        //EXC_BP_miss is generated here
        //Generate EXC_code and EXC signal, then feed them into CU
            reg [3 : 0] EXC_code;
            wire EXC;
    
    //pipeline registers between EXC and MEM stage
            reg M_canceled;
            reg [31:0] M_AluOut, M_db, M_PC;
            reg [4:0] M_TargetReg;
            reg M_RegWrite,M_M2Reg,M_MemReq,M_MemWrite;
            reg M_StoreMask,M_LoadMask,M_B_HW,M_LoadSign,M_NotAlign;

    //MEM stage
    //pipeline registers between MEM and WB stage
            reg W_canceled;
            reg [31:0] W_da, W_db;
            reg [4:0] W_TargetReg;
            reg W_M2Reg, W_RegWrite;

    //WB stage
            wire[31:0] W_RegDate_in;


//------------------------BP stage------------------------------------------
//This stage is for the branch predictor    
    //stall signal for BP stage
    wire stall_BP = CPU_stall | stall_IA_IF_ID;


    
    //Branch Predictor implemented here
    //.................................
    //now is the simple static branch predictor
    //BP_target is feed into the CU to generate next_PC
    assign BP_target = IA_PC + 4;
    //End of Branch Predictor

//Pipeline registers between BP and IA stage
    initial begin
        IA_mmuEN    <=  1'b0;
        IA_PC       <= 32'b0;
    end
    always @(posedge clk) begin
        if (~stall_BP) begin
            //mmu_en_CU is read from control registers
            IA_mmuEN    <= mmu_en_CU;
            //next_PC is calculated in CU
            IA_PC       <= next_PC;
        end
    end


//------------------------IA stage------------------------------------------
//This stage is for the instruction MMU
    //stall signal for IA stage
    wire stall_IA = CPU_stall | stall_IA_IF_ID;
    
    //These two vector come from the control registers, they can be modified
    //by mtc0 instruction. 
    //wire [PAGE_NUM_WIDTH - 1 : 0] vpage_in_I, ppage_in_I;
    //This is the mmu error exception signal for fetching instructions
    wire mmu_error_I;

    //address alingn exc in IA stage
    wire  IA_misaligned = IA_PC[0] | IA_PC[1];
    
    //connect mmu
    //paddr_I is the translated physical address for instruction. 
    //This address is feed into the instruction cache
    mmu mmu_I (IA_mmuEN, IA_mmuEN,IA_PC,vpage_in_I,
              ppage_in_I,mmu_error_I,paddr_I,clk,CPU_stall );

    //determine the EXC type in IA stage
    //mmu error and misaligned can happen in the same time
    //misaligned has higher priority. 
    reg [3:0] IA_EXC_in ;
    always @(*) begin
        if (IA_misaligned) 
            //code 4'b0001 for Instruction address not aligned exception
            IA_EXC_in = 4'b0001;
        else if (mmu_error_I)
            //code 4'b0010 for Instruction MMU not hit exception
            IA_EXC_in = 4'b0010;
        else
            IA_EXC_in = 4'b0000;
    end

    //reqest signal to I cache
    //when there's no error in IA stage and IA stage is not banned
    //request the I cache. 
    assign Icache_req = ~IA_misaligned & ~mmu_error_I & ~ban_IA;

//Pipeline registers between IA and IF stage
    initial begin
        IF_canceled <=  1'b0;
        IF_mmuEN    <=  1'b0;
        IF_PC       <= 32'b0;
        IF_EXC      <=  4'b0;
    end

    always @(posedge clk) begin
        if (~stall_IA) begin
            IF_canceled <= ban_IA;
            IF_mmuEN    <= IA_mmuEN;
            IF_PC       <= IA_PC;
            IF_EXC      <= IA_EXC_in;
        end
    end    

//------------------------IF stage------------------------------------------
    //stall signal for IF stage is CPU_stall|stall_IA_IF_ID
    wire stall_IF = CPU_stall | stall_IA_IF_ID;

    //instruction read out from the cache. 
    wire [31:0] I_cache_out;

    //Instantiate the instruction cache
    cahce I_cache(stall_IF, 
                    paddr_I, 32'b0, Icache_req, 1'b0, 1'b0,
                    I_cache_out, I_cache_ready,
                    //don't need the internel address in cache, since this
                    //register register the physical address, but we need
                    //virtual address inside the pipeline.
                    //PC
                    ,
                    BUS_addr,BUS_data,BUS_req_I,BUS_RW,BUS_grant_I,BUS_ready,
                    ban_IF,
                    clr,
                    clk
                    //,
                    //,,,,,,,,
                    );

//--------------------Register between IF and ID stage----------------------
    initial begin
        ID_canceled <=  1'b0;
        ID_mmuEN    <=  1'b0;
        ID_PC       <= 32'b0;
        ID_EXC      <=  4'b0;
        ID_instruction <= 32'b0;
    end
    always @(posedge clk)
    begin
        if (~stall_IF) begin
                ID_canceled <= ban_IF | IF_canceled;
                ID_mmuEN    <= IF_mmuEN;
                ID_PC       <= IF_PC;
                //no new exc in IF stage, ues value in ID stage 
                ID_EXC      <= IF_EXC;
                ID_instruction <= (ban_IF | IF_canceled | ~Icache_req) ? 
                                32'b0 : I_cache_out;
        end
    end
//--------------------------------ID stage---------------------------------- 
//instantiate the register file
regfile RegFile_0 (rs,rt,qa,qb,
                W_TargetReg,W_RegDate_in, ~W_canceled & W_RegWrite,
                clk,clr);

//instantiate the CU
control_unit CU_0 (
    //protected mode signals
        .mmuEN(mmu_en_CU), 
        .Vpage_I(vpage_in_I) , .Ppage_I(ppage_in_I), 
        .Vpage_D(vpage_in_D), .Ppage_D(ppage_in_D),
    //instruction from IF stage
        .instruction(ID_instruction), .ID_canceled(ID_canceled),
    //index outputs to register files
        .rs(rs), .rt(rt),
    //data input from register files
        .qa(qa), .qb(qb),
    //data output for next stage
        .da(da), .db(db), .imm(imm), .TargetReg(TargetReg),
    //output control signals for next stage
        .RegWrite(RegWrite), .M2Reg(M2Reg), .MemReq(MemReq), 
        .MemWrite(MemWrite), .AluImm(AluImm),
        .ShiftImm(ShiftImm), .link(link), .slt(slt), 
        .sign(sign), .slt_sign(slt_sign),
        //for different load/store instructions
        .StoreMask(StoreMask), .LoadMask(LoadMask), 
        .B_HW(B_HW), .LoadSign(LoadSign), .NotAlign(NotAlign),
        //for ALU
        .AluFunc(AluFunc), .ExeSelect(ExeSelect), 
        .AllowOverflow(AllowOverflow),
        //signal for mtc0 and mfc0 at EXC stage
        .i_mtc0(i_mtc0), .i_mfc0(i_mfc0), .rd(rd),
        //signal for multi-cycle instruction done
        .ins_done(ins_done),
        //signal used for branch target calculation
        .bpc(bpc), .no_br_pc(no_br_pc),
        .i_j(i_j), .i_jal(i_jal), .i_jr(i_jr), .i_jalr(i_jalr), 
        .i_eret(i_eret), .i_bgez(i_bgez),
        .i_bgezal(i_bgezal), .i_bltz(i_bltz), .i_bltzal(i_bltzal), 
        .i_blez(i_blez), .i_bgtz(i_bgtz), .i_beq(i_beq), .i_bne(i_bne),
        .rs_equal_0(rs_equal_0), .rs_rt_equal(rs_rt_equal),
        .rs_less_than_0(rs_less_than_0),
        //ID stage exception outputs
        .i_syscall(syscall), .i_unimp(unimp), .i_not_allow(not_allow),
    //pipeline control
        //input signals for data forward
        .E_TargetReg(E_TargetReg), .E_m2reg(E_M2Reg), .E_RegWrite(E_RegWrite),
        .EXC_TargetReg(EXC_TargetReg), .EXC_m2reg(EXC_M2Reg), .EXC_RegWrite(EXC_RegWrite),
        .M_TargetReg(M_TargetReg), .M_m2reg(M_M2Reg), .M_RegWrite(M_RegWrite),
        .EXC_AluOut(EXC_AluOut_mux), .M_AluOut(M_AluOut),   
        //input canceled signals
        .E_canceled(E_canceled), .EXC_canceled(EXC_canceled), 
        .M_canceled(M_canceled),
        //control signals for pipeline stall
        //inputs
        .I_cache_R(I_cache_ready), .D_cache_R(D_cache_ready),
        //outputs
        .CPU_stall(CPU_stall), .Stall_IA_IF_ID(stall_IA_IF_ID), 
    //next PC is calculated within CU
        .next_PC(next_PC),
        //use these values as next PC in different situations
        .BP_target(BP_target), .EXC_Br_target(EXC_BrTarget),
    //for exception, interrupt and control registers
        //ban signal output for different stages
        .ban_IA(ban_IA), .ban_IF(ban_IF), .ban_ID(ban_ID),
        .ban_EXE(ban_EXE), .ban_EXC(ban_EXC),
        //PC in different stage
        .ID_PC(ID_PC), .EXE_PC(E_PC), .EXC_PC(EXC_PC),
        //exception input from different stages
        .EXC_code(EXC_code), .EXC(EXC),
        .EXC_BP_miss(EXC_BP_miss), .EXC_SMC(EXC_SMC), .EXC_ERET(EXC_eret),
        //instruction done signal from EXC stage for exception interrupt control
        .EXC_ins_done(EXC_ins_done),  
        //signal from EXC stage for write request to control registers
        .EXC_mtc0(EXC_mtc0), .EXC_rd(EXC_rd), 
        .CP0_reg_in(EXC_AluOut_mux), .CP0_reg_out(CP0_reg_out),
        //interrupt vector input from the interrupt controller
        .int_num(int_num),
        //interrupt input
        .int_in(int_in),
        //interrupt accept output 
        .int_rec(int_rec),       
    //clock input
        .clk(clk)

);

    //determine the EXC type in 
    reg [3:0] ID_EXC_in;
    //syscall, unimp, eret is generated in CU
    //these four kind of exception can not happen at the same time
    //wire syscall,unimp, eret, not_allow;
    always @(*) begin
        //if there is exception in ID stage, store ID stage EXC cause
        if (syscall) 
            //4'b0011 is for syscall instruction
            //syscall instruction is treated as a spectial exception
            ID_EXC_in = 4'b0011;
        else if (unimp)
            //4'b0100 is for unimplemented instruction exception
            ID_EXC_in = 4'b0100;
        else if (not_allow)
            //4'b0110 is for not allow instructions
            //This is used for the protected mode
            ID_EXC_in = 4'b0110;
        else
        //if there is no exception in ID stage, store IF stage EXC cause
            ID_EXC_in = ID_EXC;
    end

    //assign int_ack = int_rec & ~CPU_stall;

//---------------------register between ID and EXE stage---------------------
    initial begin
                E_canceled <=  1'b0;
                E_mmuEN    <=  1'b0;
                E_PC       <= 32'b0;
                E_EXC      <=  4'b0;
                E_da       <= 32'b0;
                E_db       <= 32'b0;
                E_imm      <= 32'b0;
                E_TargetReg<=  5'b0;
                E_RegWrite <=  1'b0;
                E_M2Reg    <=  1'b0;
                E_MemReq   <=  1'b0;
                E_MemWrite <=  1'b0;
                E_AluImm   <=  1'b0;
                E_ShiftImm <=  1'b0;
                E_link     <=  1'b0;
                E_slt      <=  1'b0;
                E_sign     <=  1'b0;
                E_slt_sign <=  1'b0;
                E_StoreMask<=  1'b0;
                E_LoadMask <=  1'b0;
                E_B_HW     <=  1'b0;
                E_LoadSign <=  1'b0;
                E_NotAlign <=  1'b0;
                E_AluFunc  <=  4'b0;
                E_AllowOverflow <= 1'b0;
    
                E_ins      <= 32'b0;
                E_i_j      <=  1'b0;
                E_i_jal    <=  1'b0;
                E_i_jr     <=  1'b0;
                E_i_jalr   <=  1'b0;
                E_i_eret   <=  1'b0;
                E_i_bgez   <=  1'b0;
                E_i_bgezal <=  1'b0;
                E_i_bltz   <=  1'b0;
                E_i_bltzal <=  1'b0;
                E_i_blez   <=  1'b0;
                E_i_bgtz   <=  1'b0;
                E_i_beq    <=  1'b0;
                E_i_bne    <=  1'b0;
                E_bpc      <= 32'b0;
                E_no_br_pc <= 32'b0;
                E_rs_equal_0     <= 1'b0;
                E_rs_rt_equal    <= 1'b0;
                E_rs_less_than_0 <= 1'b0;
                E_ins_done <=  1'b0;
                E_rd       <=  1'b0;
                E_mtc0   <=  1'b0;
                E_mfc0   <=  1'b0;
                
    end

    always @(posedge clk) begin
     if(~CPU_stall) begin
            E_canceled <= ID_canceled | ban_ID;
            E_mmuEN    <= ID_mmuEN;
            E_PC       <= ID_PC;
            E_EXC      <= ID_EXC_in;
            E_da       <= da;
            E_db       <= db;
            E_imm      <= imm;
            E_TargetReg<= TargetReg;
            E_RegWrite <= RegWrite ;
            E_M2Reg    <= M2Reg    ;
            E_MemReq   <= MemReq   ;
            E_MemWrite <= MemWrite ;
            E_AluImm   <= AluImm   ;
            E_ShiftImm <= ShiftImm ;
            E_link     <= link     ;
            E_slt      <= slt      ;
            E_sign     <= sign     ;
            E_slt_sign <= slt_sign ;
            E_StoreMask<= StoreMask;
            E_LoadMask <= LoadMask ;
            E_B_HW     <= B_HW     ;
            E_LoadSign <= LoadSign ;
            E_NotAlign <=  NotAlign;
            E_AluFunc  <= AluFunc  ;
            E_AllowOverflow <= AllowOverflow;
            
            E_ins      <=  ID_instruction;
            E_i_j      <=  i_j     ;
            E_i_jal    <=  i_jal   ;
            E_i_jr     <=  i_jr    ;
            E_i_jalr   <=  i_jalr  ;
            E_i_eret   <=  i_eret  ;
            E_i_bgez   <=  i_bgez  ;
            E_i_bgezal <=  i_bgezal;
            E_i_bltz   <=  i_bltz  ;
            E_i_bltzal <=  i_bltzal;
            E_i_blez   <=  i_blez  ;
            E_i_bgtz   <=  i_bgtz  ;
            E_i_beq    <=  i_beq   ;
            E_i_bne    <=  i_bne   ;
            E_bpc      <= bpc;
            E_no_br_pc <= no_br_pc;
            E_rs_equal_0     <= rs_equal_0;
            E_rs_rt_equal    <= rs_rt_equal;
            E_rs_less_than_0 <= rs_less_than_0;
            E_ins_done       <= ins_done;
            E_rd       <=  rd;
            E_mtc0     <=  i_mtc0  ;
            E_mfc0     <=  i_mfc0  ;
   
        end
    end
//-----------------------------EXE stage-------------------------------------
    //EXE stage output
    reg [31:0] E_AluOut;
    wire [4:0] E_TargetReg_out;

    //calculate branch target
    //Jump target for J/Jal instruction. Different with the original MIPS32 instruction. 
    //This CPU don't have delay slot, so upper bit of the target is the corresponding
    //bits of the address of the branch instruction itself. 
    wire [31:0] jpc = {E_PC[31:28],E_ins[25:0],2'b00};


    //Target address for jump register instructions
    wire [31:0] rpc = E_da;

    //select the correct branch target
    reg  [31:0] E_Br_target;
    always @(*) begin
         //unconditional branch instructions
        if (E_i_j|E_i_jal)          E_Br_target = jpc;
        //unconditional branch register instructions
        else if (E_i_jr|E_i_jalr)   E_Br_target = rpc;
        //conditional branch instructions
        else if (((E_i_bgez|E_i_bgezal)&(~E_rs_less_than_0))|((E_i_bltz|E_i_bltzal)&E_rs_less_than_0)
            |(E_i_blez&(E_rs_less_than_0|E_rs_equal_0))|(E_i_beq&E_rs_rt_equal)|(E_i_bne&(~E_rs_rt_equal))
             |(E_i_bgtz&(~E_rs_less_than_0 & ~ E_rs_equal_0)))
                                E_Br_target = E_bpc;
        //normal target
        else                    E_Br_target = E_no_br_pc;
    
    end

    //These signals are used for the branch predictor. 
    //is_branch is HIGH if current instruction in ID stage is a branch instruction. 
    //This signal with ID_PC together, can let the branch predictor know that
    //an address holds a branch instruction, then the BP can assign a slot for
    //that address.
    wire is_branch;
    assign is_branch =(E_i_j|E_i_jal|E_i_jr|E_i_jalr|E_i_bgez|E_i_bgezal|E_i_bltz
               |E_i_bltzal|E_i_blez|E_i_bgtz|E_i_beq|E_i_bne|E_i_eret)&~E_canceled;
    //Some of the branch instructions such as j and jal have fixed target, while
    //some branch instructions such as jr and jalr have  variable target. 
    //The branch predictor must understand these conditions when making predictions.
    wire V_target; 
    assign V_target = E_i_jr | E_i_jalr | E_i_eret;

    //generate BP_miss in EXC stage to increase frequency
    wire E_BP_miss;
    assign E_BP_miss = is_branch ? (ID_PC != E_Br_target) : 1'b0;


wire [31:0] alu_in_A, alu_in_B, alu_result;
assign alu_in_A = E_ShiftImm ? {27'b0,E_imm[10:6]} : E_da;
assign alu_in_B = E_AluImm ? E_imm : E_db;
wire AluOverflow;

//instantiate the ALU
alu alu_0 (alu_in_A,alu_in_B,E_AluFunc,AluOverflow,,alu_result);

//comparators for set less than instructions
wire comp_u_result, comp_s_result;
assign comp_u_result = $unsigned(alu_in_A) < $unsigned(alu_in_B);
assign comp_s_result = $signed(alu_in_A) < $signed(alu_in_B);

//Multiplexer at the output of EXE stage
always @(*) begin
    //for jump & link instructions
    if (E_link) E_AluOut = E_PC +4;
    //for set less than unsigned
    else if(~E_slt_sign & E_slt) E_AluOut = {31'b0,comp_u_result};
    //for set less than signed
    else if(E_slt_sign & E_slt) E_AluOut = {31'b0,comp_s_result};
    //for other instructions
    else E_AluOut =alu_result;
end

//determine EXC type in EXE stage
reg [3:0] E_EXC_in;
//exe stage overflow exception
wire overflow;
assign overflow =  ~E_canceled & E_AllowOverflow & AluOverflow;

always @(*) begin
    //If the alu overflowed then store EXE stage EXC cause
    if (overflow)
        //4'b0111 is for alu overflow
        E_EXC_in = 4'b0111;
    else 
        E_EXC_in = E_EXC;
    
end


//change the target register index if there's a jump and link instruction
assign E_TargetReg_out = E_link ? 5'b11111 : E_TargetReg;

//---------------------register between EXE and EXC stage--------------------
    initial begin

        EXC_canceled <=  1'b0;
        EXC_mmuEN    <=  1'b0;
        EXC_PC       <= 32'b0;
        EXC_EXC      <=  4'b0;
        EXC_AluOut   <= 32'b0;
        EXC_db       <= 32'b0;
        EXC_TargetReg<=  5'b0;
        EXC_MemReq   <=  1'b0;
        EXC_MemWrite <=  1'b0;
        EXC_StoreMask<=  1'b0;
        EXC_LoadMask <=  1'b0;
        EXC_B_HW     <=  1'b0;
        EXC_LoadSign <=  1'b0;
        EXC_NotAlign <=  1'b0;
        EXC_RegWrite <=  1'b0;
        EXC_M2Reg    <=  1'b0;
        EXC_BrTarget <= 32'b0;
        EXC_isBranch <=  1'b0;
        EXC_VTarget  <=  1'b0;
        EXC_BP_miss  <=  1'b0;
        EXC_eret     <=  1'b0;
        EXC_ins_done <=  1'b0;
        EXC_rd       <=  1'b0;
        EXC_mtc0     <=  1'b0;
        EXC_mfc0     <=  1'b0;

    end
    always @(posedge clk) begin
    if (~CPU_stall) begin
        EXC_canceled <= E_canceled | ban_EXE;
        EXC_mmuEN    <= E_mmuEN;
        EXC_PC       <= E_PC;
        EXC_EXC      <= E_EXC_in;
        EXC_AluOut   <= E_AluOut;
        EXC_db       <= E_db;
        EXC_TargetReg<= E_TargetReg_out;
        EXC_MemReq   <= E_MemReq;
        EXC_MemWrite <= E_MemWrite;
        EXC_StoreMask<= E_StoreMask;
        EXC_LoadMask <= E_LoadMask;
        EXC_B_HW     <= E_B_HW;
        EXC_LoadSign <= E_LoadSign;
        EXC_NotAlign <= E_NotAlign;
        EXC_RegWrite <= E_RegWrite;
        EXC_M2Reg    <= E_M2Reg;
        EXC_BrTarget <= E_Br_target;
        EXC_isBranch <= is_branch;
        EXC_BP_miss  <= E_BP_miss;
        EXC_VTarget  <= V_target;
        EXC_eret     <= E_i_eret;
        EXC_ins_done <= E_ins_done;
        EXC_rd       <= E_rd;
        EXC_mtc0     <= E_mtc0;
        EXC_mfc0     <= E_mfc0;
        end
    
    end
//--------------------------------EXC and DA stage----------------------------------
//This stage deal with all the exceptions, interrupts and data address translation
//All changes to the processor will be applied at this stage, including writing to
//control registers and dealling with exceptions or interrupts. 
    
    //Data MMU
    //These two vector come from the control registers, they can be modified
    //by mtc0 instruction. 
    //wire [PAGE_NUM_WIDTH - 1 : 0] vpage_in_D, ppage_in_D;

    //This is the mmu error exception signal for accessing memory
    wire mmu_error_D;
    
    //connect mmu
    //paddr_D is the translated physical address for data. 
    //This address is feed into the data cache
    mmu mmu_D (EXC_mmuEN, EXC_mmuEN, EXC_AluOut,vpage_in_D,
    ppage_in_D, mmu_error_D, paddr_D, clk, CPU_stall);

    //mfc0 instruction is done here
    assign EXC_AluOut_mux = EXC_mfc0 ? CP0_reg_out : EXC_AluOut;
    
    //Processing Exceptions
    //EXC and DA stage can have BP_miss, SMC, Data address not aligned, 
    //D_MMU not hit, e_ret
    
    //Generate EXC_BP_miss
 
    //Generate EXC_ERET
    
    //Generate EXC_SMC
    wire write_mem = EXC_MemWrite;
    always @(*) begin
        //check EXE stage
        if (//there's a memory write instruction in EXC stage
            write_mem 
            //address in EXC stage is identical with EXE stage 
            & E_PC == EXC_AluOut & E_canceled
            //there's no context change
            & E_mmuEN == EXC_mmuEN) 
                                            EXC_SMC = 1'b1;
        //check ID stage
        else if (//there's a memory write instruction in EXC stage
            write_mem
            //address in EXC stage is identical with ID stage
            & ID_PC == EXC_AluOut & ID_canceled
            //there's no contex change
            & ID_mmuEN == E_mmuEN == EXC_mmuEN
        ) 
                                            EXC_SMC = 1'b1;
        //check IF stage
        else if (//there's a memory write instruction in EXC stage
            write_mem
            //address in EXC stage is identical with IF stage
            & IF_PC == EXC_AluOut & IF_canceled
            //there's no contex change
            & IF_mmuEN == ID_mmuEN == E_mmuEN == EXC_mmuEN
            )
                                            EXC_SMC = 1'b1;
        //check IA stage
        else if (//there's a memory write instruction in EXC stage
            write_mem
            //address in EXC stage is identical with IA stage
            & IA_PC == EXC_AluOut 
            //there's no contex change
            & IA_mmuEN == IF_mmuEN == ID_mmuEN == E_mmuEN == EXC_mmuEN
            ) 
                                            EXC_SMC = 1'b1;
        else                                
                                            EXC_SMC = 1'b0;

    end

    //check data address alignment
    wire DA_misaligned;
    wire [1:0] DA_offset = EXC_AluOut[1:0];
    assign DA_misaligned = ((EXC_LoadMask | EXC_StoreMask|EXC_NotAlign) 
                            & EXC_B_HW & DA_offset[0] |
                            ~(EXC_LoadMask | EXC_StoreMask|EXC_NotAlign) 
                            & (DA_offset[1] | DA_offset[0]))& EXC_MemReq;
    
    //Generate EXC_code and EXC signal, then feed them into CU
    //CU will also need to know if there are SMC\BP miss\eret
    always @(*) begin
            //First deal with EXC stage exceptions
            //address not aligned has highest priority
            if (DA_misaligned)
                EXC_code = 4'b1000;
            //then deal with data mmu miss
            else if (mmu_error_D)
                EXC_code = 4'b1001;
            //otherwise use exc code adopted from last stage
            else 
                EXC_code = EXC_EXC;
    end
    assign EXC = EXC_code == 4'b0000 ? 1'b0 : 1'b1;   
                            

//---------------------register between EXC and MEM stage--------------------
initial begin

        M_canceled <=  1'b0;
        M_PC       <= 32'b0;
        M_AluOut   <= 32'b0;
        M_db       <= 32'b0;
        M_TargetReg<=  5'b0;
        M_MemReq   <=  1'b0;
        M_MemWrite <=  1'b0;
        M_StoreMask<=  1'b0;
        M_LoadMask <=  1'b0;
        M_B_HW     <=  1'b0;
        M_LoadSign <=  1'b0;
        M_NotAlign <=  1'b0;
        M_RegWrite <=  1'b0;
        M_M2Reg    <=  1'b0;

end
always @(posedge clk) begin
    if (~CPU_stall) begin
        M_canceled <= EXC_canceled | ban_EXC;
        M_PC       <= EXC_PC;
        M_AluOut   <= EXC_AluOut_mux;
        M_db       <= EXC_db;
        M_TargetReg<= EXC_TargetReg;
        M_MemReq   <= EXC_MemReq;
        M_MemWrite <= EXC_MemWrite;
        M_StoreMask<= EXC_StoreMask;
        M_LoadMask <= EXC_LoadMask;
        M_B_HW     <= EXC_B_HW;
        M_LoadSign <= EXC_LoadSign;
        M_NotAlign <= EXC_NotAlign;
        M_RegWrite <= EXC_RegWrite;
        M_M2Reg    <= EXC_M2Reg;
    end
end

//-----------------------------MEM stage-------------------------------------
//instantiate D cache
wire [31:0] D_cache_din,D_cache_dout;

wire[31:0] M_MemAddr,M_MemOut;
assign M_MemAddr = M_AluOut;
cahce D_cache (CPU_stall,paddr_D,D_cache_din,
                EXC_MemReq & ~(EXC_canceled|ban_EXC),
                EXC_MemWrite,1'b0,
                D_cache_dout,D_cache_ready,
                ,
                BUS_addr,BUS_data,BUS_req_D,BUS_RW,BUS_grant_D,BUS_ready,
                1'b0,
                clr,
                clk
                //,
                //,,,,,,,,
            );
//load store half word and byte support
//byte offset for load/store byte/half word instructions
wire [1:0] offset = M_AluOut[1:0];
//the mask is determined by M_B_HW and offset
reg [31:0] mask;
always @(*) begin
    if(M_B_HW) begin
        case (offset)
            2'b00  : mask = 32'hffff0000;
            2'b10  : mask = 32'h0000ffff;
            default: mask = 32'h00000000;
        endcase 
    end
    else begin
        case (offset)
            2'b00 : mask = 32'hff000000;
            2'b01 : mask = 32'h00ff0000;
            2'b10 : mask = 32'h0000ff00;
            2'b11 : mask = 32'h000000ff;
        endcase
    end
end
//shift amount is determined by the offset
reg [5:0] shift;
always @(*) begin
    if (M_B_HW) begin
    case (offset)
        2'b00: shift = 16;
        2'b10: shift = 0;
        default: shift = 0;
    endcase           
    end
    else begin
    case (offset)
        2'b00: shift = 24;
        2'b01: shift = 16;
        2'b10: shift =  8;
        2'b11: shift =  0;
    endcase        
    end
    
end

//shift and mask mechanism for store byte and half word instructions
wire [31:0] StoreMask_in;
assign StoreMask_in = (D_cache_dout & ~mask)|( (EXC_db<<shift) & mask);
//shift and mask mechanism for load byte and half word instructions
wire [31:0] LoadMask_no_ext;
assign LoadMask_no_ext = (D_cache_dout & mask) >> shift;
//sign extension for LB and LHW
wire e = M_LoadSign & (M_B_HW ? LoadMask_no_ext[15] : LoadMask_no_ext[7]);
wire [31:0] LoadMask_ext;
assign LoadMask_ext = M_B_HW ? 
                    ({ {16{e}},LoadMask_no_ext[15:0]}) : 
                    ({ {24{e}},LoadMask_no_ext[7:0]}) ;
wire [31:0] LoadMask_out;
assign LoadMask_out = M_LoadSign ? LoadMask_ext : LoadMask_no_ext;
//connect masked result to the cache
assign D_cache_din = EXC_StoreMask ? StoreMask_in : EXC_db;
//connect masked result to the next stage
assign M_MemOut = M_LoadMask?LoadMask_out : D_cache_dout;

//---------------------register between MEM and WB stage---------------------

initial begin
        W_canceled <=  1'b0;
        W_da       <= 32'b0;
        W_db       <= 32'b0;
        W_TargetReg<=  4'b0;
        W_M2Reg    <=  1'b0;
        W_RegWrite <=  1'b0;

end
always @(posedge clk) begin
    if (~CPU_stall) begin
        W_canceled <= M_canceled;
        W_da       <= M_AluOut;
        W_db       <= M_MemOut;
        W_TargetReg<= M_TargetReg;
        W_M2Reg    <= M_M2Reg;
        W_RegWrite <= M_RegWrite;
    end
end 
//-----------------------------WB stage--------------------------------------

assign W_RegDate_in = W_M2Reg ? W_db : W_da;

endmodule