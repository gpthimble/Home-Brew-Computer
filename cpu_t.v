//This is the test bench of the CPU

module cpu_t (
    clk,clr,    
    int_in, 
    int_ack, 
    int_num,
    TxD,TxD_ready,

    BUS_addr, BUS_data,
    BUS_req, BUS_ready, BUS_RW,
    DMA, grant,
    PC, next_PC,instruction_o,I_cache_ready,
    ID_PC,BP_miss,CPU_stall,stall_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
    da,db,imm,
    E_PC,E_AluOut,
    M_PC,D_cache_dout_o,D_cache_ready,
    W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg
);
    input clk,clr;
    input int_in;
    output int_ack;
    input [19:0] int_num;
    output TxD,TxD_ready;

    output [31:0] BUS_addr, BUS_data;
    output BUS_req, BUS_ready, BUS_RW;
    output [7:0] DMA, grant;

    output [31:0] PC,ID_PC,E_PC,M_PC, next_PC,instruction_o,D_cache_dout_o,W_RegDate_in
        ,E_AluOut,da,db,imm;
    output I_cache_ready,BP_miss,stall_IF_ID,W_canceled,W_RegWrite,
        W_M2Reg,D_cache_ready,CPU_stall,ban_IF,ban_ID,ban_EXE,ban_MEM;
    output [4:0] W_TargetReg;

    wire [31:0] BUS_addr, BUS_data;
    wire BUS_req, BUS_ready, BUS_RW;
    wire [7:0] DMA, grant;

    cpu cpu0(BUS_addr,BUS_data,BUS_RW,BUS_ready,DMA[0],DMA[1],grant[0],
                grant[1],int_in, int_ack, int_num, clr, clk,
                PC, next_PC,instruction_o,I_cache_ready,
                ID_PC,BP_miss,CPU_stall,stall_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
                da,db,imm,
                E_PC,E_AluOut,
                M_PC,D_cache_dout_o,D_cache_ready,
                W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg);
    bus_control bus_control0(DMA,grant,BUS_req, BUS_ready,clk);
    dummy_slave ram0 (clk,{2'b00,BUS_addr[31:2]},BUS_data,BUS_req,BUS_ready,BUS_RW);

    uart_tx tx_0 (clk, {2'b00,BUS_addr[31:2]}, BUS_data,BUS_req,BUS_ready,BUS_RW, TxD, TxD_ready);


endmodule