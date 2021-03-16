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
    PC, next_PC_o,instruction_o,I_cache_ready,
    ID_PC,BP_miss,CPU_stall,stall_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
    da,db,imm,
    E_PC,E_AluOut,
    M_PC,D_cache_dout_o,D_cache_ready,
    W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg
    
);
//for debugging
output [31:0] PC,ID_PC,E_PC,M_PC, next_PC_o,instruction_o,D_cache_dout_o,W_RegDate_in
        ,E_AluOut,da,db,imm;
output I_cache_ready,BP_miss,stall_IF_ID,W_canceled,W_RegWrite,
        W_M2Reg,D_cache_ready,CPU_stall,ban_IF,ban_ID,ban_EXE,ban_MEM;
output [4:0] W_TargetReg;
assign next_PC_o = next_PC_in;
assign instruction_o = I_cache_out;

assign D_cache_dout_o =M_MemOut;
//######################## Interface description ###########################
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
    output int_ack;
    //20-bit interrupt vector number input.
    input [19:0] int_num;
//--------------------- clock and clear-------------------------------------
    input clk,clr;

//--------------------- for debugging -------------------------------------
//maybe pipeline registers output 


//######################## Module Implementation ###########################
//-----------------------declare names--------------------------------------

    //instruction read out from the cache. 
    wire [31:0] I_cache_out;

    //PC register is the address register inside the cache. 
    wire [31:0] PC;
    //next_PC is determined in CU
    wire [31:0] next_PC;

    //pipeline register between IF and ID stage
    reg [31:0] instruction, ID_PC;
    reg ID_canceled;

    //for the register file
    //two read index
    wire [4:0] rs,rt;
    //two read data out
    wire [31:0] qa,qb;
    //write index
    wire [4:0] reg_w_num;
    //write data in
    wire [31:0] reg_d_in;
    //write enable from WB stage
    wire reg_w_en;

    //for the control unit
    //data output to next stage
    wire [31:0] da,db,imm;
    wire [4:0] TargetReg;
    //control output to next stage
    wire RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt,sign,slt_sign;
    wire StoreMask,LoadMask,B_HW,LoadSign;
    wire [3:0] AluFunc;
    wire [1:0] ExeSelect;
    //stall signal generated from CU
    wire CPU_stall;
    //stall signal for IF and ID stage generated from CU
    wire stall_IF_ID;
    //I cache ready signal
    wire I_cache_ready;
    //D cache ready signal
    wire D_cache_ready;
    //cancel signal from CU
    wire ban_IF,ban_ID,ban_EXE,ban_MEM;
    //exception signal from different stages
    wire exc_IF, exc_EXE,exc_MEM;
    //exception number 
    reg [2:0] IF_cause,EXE_cause,MEM_cause;
    //signals for branch predictor
    wire BP_miss;
    wire [31:0] epc,BP_target,bpc,no_br_pc;
    reg  [31:0] br_target;
    wire i_j,i_jal,i_jr,i_jalr,i_eret,i_bgez,i_bgezal,i_bltz,i_bltzal,i_blez,
            i_bgtz,i_beq,i_bne;

    wire int_rec;

    //pipeline registers between ID and EXE stage
    reg E_canceled;
    reg [31:0] E_da,E_db,E_imm, E_PC;
    reg [4:0] E_TargetReg;
    reg E_RegWrite,E_M2Reg,E_MemReq,E_MemWrite,E_AluImm,E_ShiftImm,E_link,E_slt,E_sign,E_slt_sign ;
    reg E_StoreMask,E_LoadMask,E_B_HW,E_LoadSign;
    reg [3:0] E_AluFunc;
    reg [1:0] E_ExeSelect;
    reg [31:0] E_ins, E_epc,E_bpc,E_no_br_pc;

    reg E_i_j,E_i_jal,E_i_jr,E_i_jalr,E_i_eret,E_i_bgez,E_i_bgezal,
            E_i_bltz,E_i_bltzal,E_i_blez,E_i_bgtz,E_i_beq,E_i_bne;

    //EXE stage output
    reg [31:0] E_AluOut;
    wire [4:0] E_TargetReg_out;

    //pipeline registers between EXE and MEM stage
    reg M_canceled;
    reg [31:0] M_AluOut, M_db, M_PC;
    reg [4:0] M_TargetReg;
    reg M_RegWrite,M_M2Reg,M_MemReq,M_MemWrite;
    reg M_StoreMask,M_LoadMask,M_B_HW,M_LoadSign;

    //MEM stage
    wire[31:0] M_MemAddr,M_MemOut;

    //pipeline registers between MEM and WB stage
    reg W_canceled;
    reg [31:0] W_da, W_db;
    reg [4:0] W_TargetReg;
    reg W_M2Reg, W_RegWrite;

    //WB stage
    wire[31:0] W_RegDate_in;


//------------------------IF stage------------------------------------------
    //stall signal for IF stage is CPU_stall|stall_IF_ID
    wire stall_IF = CPU_stall | stall_IF_ID;
    //static branch predictor, always predicts that the branch will not happen. 
    assign BP_target = PC+4;

    //Address input of I cache needs special treatment when clear signal is 
    //active. When clear is active, the input of I cache should be zero, this
    //makes the CPU run from address zero when clr. 
    wire [31:0] next_PC_in = clr ? 32'b0 : next_PC;

    //Instantiate the instruction cache
    cache I_cache(stall_IF, next_PC_in, 32'b0, 1'b1, 1'b0, 1'b0,
                    I_cache_out, I_cache_ready,
                    PC,
                    BUS_addr,BUS_data,BUS_req_I,BUS_RW,BUS_grant_I,BUS_ready,
                    ban_IF,
                    clr,
                    clk,
                    ,,,,,,,,);

//--------------------Register between IF and ID stage----------------------
    always @(posedge clk)
    begin
        if (clr)
            begin
                ID_canceled <=  1'b0;
                ID_PC       <= 32'b0;
                instruction <= 32'b0;
            end
        else if (~(stall_IF_ID|CPU_stall)) begin
                ID_canceled <= ban_IF;
                ID_PC       <= PC;
                instruction <= ban_IF ? 32'b0 : I_cache_out;
        end
    end
//--------------------------------ID stage---------------------------------- 
//instantiate the register file
regfile RegFile_0 (rs,rt,qa,qb,
                W_TargetReg,W_RegDate_in, ~W_canceled & W_RegWrite,
                clk,clr);

//instantiate the CU
control_unit CU_0 (
    instruction,ID_canceled, rs,rt, qa,qb,
    da,db,imm,TargetReg,
    RegWrite,M2Reg,MemReq,MemWrite,AluImm,ShiftImm,link,slt,sign,slt_sign,
    StoreMask,LoadMask,B_HW,LoadSign,
    AluFunc,ExeSelect,
    M_TargetReg,M_M2Reg,M_RegWrite, E_TargetReg_out, E_M2Reg,E_RegWrite,
    E_AluOut, M_AluOut, M_MemOut ,
    M_MemAddr, M_MemWrite &~M_canceled,
    I_cache_ready,D_cache_ready,
    CPU_stall,stall_IF_ID,
    BP_miss,epc,BP_target,br_target,bpc,no_br_pc,
    i_j,i_jal,i_jr,i_jalr,i_eret,i_bgez,i_bgezal,i_bltz,i_bltzal,i_blez,
            i_bgtz,i_beq,i_bne,
    next_PC,
    PC,ID_PC,E_PC,M_PC,
    exc_IF,exc_EXE,exc_MEM,
    IF_cause,EXE_cause,MEM_cause,
    ban_IF,ban_ID,ban_EXE,ban_MEM,
    int_num,int_in,int_rec,
    clk,clr
);
assign int_ack = int_rec & ~CPU_stall;
//---------------------register between ID and EXE stage---------------------
    always @(posedge clk) begin
        if (clr)begin
            E_canceled <=  1'b0;
            E_PC       <= 32'b0;
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
            E_AluFunc  <=  4'b0;

            E_ins      <= 32'b0;
            E_epc      <= 32'b0;
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

        end
        else if(~CPU_stall) begin
            E_canceled <= ID_canceled | ban_ID;
            E_PC       <= ID_PC;
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
            E_AluFunc  <= AluFunc  ;

            E_ins      <=  instruction;
            E_epc      <=  epc;
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
            

   
        end
    end
//-----------------------------EXE stage-------------------------------------
//calculate branch target
    //Jump target for J/Jal instruction. Different with the original MIPS 32 instruction. 
    //This CPU don't have delay slot, so upper bit of the target is the corresponding
    //bits of the address of the branch instruction itself. 
    wire [31:0] jpc = {E_PC[31:28],E_ins[25:0],2'b00};


    //Target address for jump register instructions
    wire [31:0] rpc = E_da;


    wire   rs_equal_0,rs_rt_equal,rs_less_than_0;
    assign rs_equal_0 = (E_da ==  32'b0);
    assign rs_rt_equal = (E_da == E_db);
    assign rs_less_than_0 = E_da[31];
    //select the correct branch target

    always @(*) begin
         //unconditional branch instructions
        if (E_i_j|E_i_jal)          br_target = jpc;
        //unconditional branch register instructions
        else if (E_i_jr|E_i_jalr)   br_target = rpc;
        //return from exception
        else if (E_i_eret)        br_target = E_epc;
        //conditional branch instructions
        else if (((E_i_bgez|E_i_bgezal)&(~rs_less_than_0))|((E_i_bltz|E_i_bltzal)&rs_less_than_0)
            |(E_i_blez&(rs_less_than_0|rs_equal_0))|(E_i_beq&rs_rt_equal)|(E_i_bne&(~rs_rt_equal))
             |(E_i_bgtz&(~rs_less_than_0 & ~ rs_equal_0)))
                                br_target = E_bpc;
        //normal target
        else                    br_target = E_no_br_pc;
    
    end

    //These signals are used for the branch predictor. 
    //is_branch is HIGH if current instruction in ID stage is a branch instruction. 
    //This signal with ID_PC together, can let the branch predictor know that
    //an address holds a branch instruction, then the BP can assign a slot for
    //that address.
    assign is_branch =(E_i_j|E_i_jal|E_i_jr|E_i_jalr|E_i_bgez|E_i_bgezal|E_i_bltz
               |E_i_bltzal|E_i_blez|E_i_bgtz|E_i_beq|E_i_bne|E_i_eret)&~E_canceled;
    //Some of the branch instructions such as j and jal have fixed target, while
    //some branch instructions such as jr and jalr have  variable target. 
    //The branch predictor must understand these conditions when making predictions. 
    assign V_target = E_i_jr | E_i_jalr | E_i_eret;
//generate BP_miss
assign BP_miss = is_branch ? (ID_PC != br_target) : 1'b0;


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

//exe stage overflow exception
assign exc_EXE = E_sign & ~E_canceled & ~E_slt & ~E_link & AluOverflow;
//EXE_cause = 001 when alu has overflowed
always @(*) begin
    if (exc_EXE) begin
        EXE_cause = 3'b001;
    end
    else 
        EXE_cause = 3'b000;
end

//change the target register index if there's a jump and link instruction
assign E_TargetReg_out = E_link ? 5'b11111 : E_TargetReg;

//---------------------register between EXE and MEM stage--------------------
always @(posedge clk) begin
    if (clr) begin
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
        M_RegWrite <=  1'b0;
        M_M2Reg    <=  1'b0;
    end
    else if (~CPU_stall) begin
        M_canceled <= E_canceled | ban_EXE;
        M_PC       <= E_PC;
        M_AluOut   <= E_AluOut;
        M_db       <= E_db;
        M_TargetReg<= E_TargetReg_out;
        M_MemReq   <= E_MemReq;
        M_MemWrite <= E_MemWrite;
        M_StoreMask<= E_StoreMask;
        M_LoadMask <= E_LoadMask;
        M_B_HW     <= E_B_HW;
        M_LoadSign <= E_LoadSign;
        M_RegWrite <= E_RegWrite;
        M_M2Reg    <= E_M2Reg;
    end
end

//-----------------------------MEM stage-------------------------------------
//instantiate D cache
wire [31:0] D_cache_din,D_cache_dout;
assign M_MemAddr = M_AluOut;
cache D_cache (CPU_stall,E_AluOut,D_cache_din,E_MemReq & ~(E_canceled|ban_EXE),E_MemWrite,1'b0,
                D_cache_dout,D_cache_ready,
                ,
                BUS_addr,BUS_data,BUS_req_D,BUS_RW,BUS_grant_D,BUS_ready,
                ban_MEM,
                clr,
                clk,
                ,,,,,,,,
            );
//load store half word and byte support
//byte offset for load/store byte/half word instructions
wire [1:0] offset = M_AluOut[1:0];
//the mask is determined by M_B_HW and offset
reg [31:0] mask;
always @(*) begin
    if(M_B_HW) begin
        case (offset)
            2'b00  : mask = 32'h0000ffff;
            2'b10  : mask = 32'hffff0000;
            default: mask = 32'h00000000;
        endcase 
    end
    else begin
        case (offset)
            2'b00 : mask = 32'h000000ff;
            2'b01 : mask = 32'h0000ff00;
            2'b10 : mask = 32'h00ff0000;
            2'b11 : mask = 32'hff000000;
        endcase
    end
end
//shift amount is determined by the offset
reg [5:0] shift;
always @(*) begin
    case (offset)
        2'b00: shift = 0;
        2'b01: shift = 8;
        2'b10: shift =16;
        2'b11: shift =24;
    endcase
end
//this register is used for holding the value read out of the cache for SB/SHW
reg [31:0] D_cache_dout_R;
always @(posedge clk) begin
    if (clr) begin
        D_cache_dout_R <= 32'b0;
    end
    else if (~CPU_stall) begin
        D_cache_dout_R <= D_cache_dout;
    end
end
//shift and mask mechanism for store byte and half word instructions
wire [31:0] StoreMask_in;
assign StoreMask_in = (D_cache_dout_R & ~mask)|( (M_db<<shift) & mask);
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
assign D_cache_din = M_StoreMask ? StoreMask_in : E_db;
//connect masked result to the next stage
assign M_MemOut = LoadMask_out;

//for MEM stage exceptions
//Misaligned exceptions
wire M_misaligned = (M_LoadMask | M_StoreMask) & M_B_HW & offset[0];
//add other exceptions here
//...
//signal the exception to CU. 
assign exc_MEM = M_misaligned & ~M_canceled;
//set the cause of exception
always @(*) begin
    if (M_misaligned) begin
        MEM_cause = 3'b001;
    end
    //add other cause here
    //...

    else 
        MEM_cause = 3'b000;
end

//---------------------register between MEM and WB stage---------------------
always @(posedge clk) begin
    if (clr) begin
        W_canceled <=  1'b0;
        W_da       <= 32'b0;
        W_db       <= 32'b0;
        W_TargetReg<=  4'b0;
        W_M2Reg    <=  1'b0;
        W_RegWrite <=  1'b0;
    end
    else if (~CPU_stall) begin
        W_canceled <= M_canceled | ban_MEM;
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