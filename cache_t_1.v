//testbench b for cache
//this test tests the replacement policy

module cache_t(
clk,clr,
BUS_addr_o, BUS_data_o, BUS_req_o, BUS_ready_o,BUS_RW_o,
DMA_o,grant_o,
CPU_stall_o, CPU_addr_o, CPU_data_o, CPU_ready_o,CPU_stall_in,
next_pc_o,we_a,we_b,we_c,needupdate,tag,hitA,hitB,RAM_A_out,next_data,next_req,
,mem_o,mem_ready,
);

input clk,clr,CPU_stall_in;

//These ports are used for testbench output.
output [31:0] BUS_addr_o, BUS_data_o, CPU_addr_o, CPU_data_o,next_pc_o,RAM_A_out, next_data;
output BUS_req_o, BUS_ready_o,BUS_RW_o,CPU_stall_o,CPU_ready_o,we_a,we_b,we_c,needupdate,hitA,hitB,next_req;
output [7:0] DMA_o, grant_o;
output [23:0] tag;
output [31:0] mem_o;
output mem_ready;
//These wires are internal bus signal.
wire [31:0] BUS_addr, BUS_data;
wire BUS_req, BUS_ready, BUS_RW;
wire [7:0] DMA, grant;

//These wires are used to simulate CPU.

wire [31:0] PC,next_pc,CPU_data;

wire  CPU_ready;

//hook up the bus controller
bus_control bus_control_0 (DMA,grant,BUS_req, BUS_ready,clk);

//hook up the simulated memory
dummy_slave memory(clk,BUS_addr,BUS_data,BUS_req,BUS_ready,BUS_RW);

//hook up the simulated instruction cache

//shrink the size of the cache
defparam I_cache.INDEX = 1;
cache I_cache (CPU_stall,next_pc , 32'b0 , 1'b1, rw[i], 1'b0, CPU_data, CPU_ready, PC,
                BUS_addr, BUS_data, DMA[0], BUS_RW, grant[0], BUS_ready, clr, clk,
                we_a,we_b,we_c,needupdate,tag,hitA,hitB,RAM_A_out);

//hook up the simulated data cache
//cache D_cache (CPU_stall,exe_address[i],data[i], exe_req[i], rw[i],1'b0,mem_o,mem_ready,,
//                BUS_addr,BUS_data,DMA[1],BUS_RW, grant[1],BUS_ready ,clr,clk);


//
reg [31:0] address [0:7] ;
initial
begin
    address[0]= 0 ;
    address[1]= 4 ;
    address[2]= 28 ; 
    address[3]= 8 ;
    address[4]= 16 ;
    address[5]= 4 ; 
    address[6]= 4 ; 
    address[7]= 4 ; 
end

reg [31:0] exe_address [0:7];
initial
begin
    exe_address[0]= 0 ;
    exe_address[1]= 20;
    exe_address[2]= 0 ;
    exe_address[3]= 20;
    exe_address[4]= 20;
    exe_address[5]= 24;
    exe_address[6]= 24;
    exe_address[7]= 24;
end

reg [31:0] exe_req [0:7];
initial
begin
    exe_req[0]=0;
    exe_req[1]=1;
    exe_req[2]=0;
    exe_req[3]=1;
    exe_req[4]=1;
    exe_req[5]=1;
    exe_req[6]=1;
    exe_req[7]=1;
end

reg [31:0] data [0:7];
initial
begin
    data[0]= 32'hab2112a ;
    data[1]= 32'hab2112b ;
    data[2]= 32'hab2112c ;
    data[3]= 32'hab21123 ;
    data[4]= 32'hab21124 ;
    data[5]= 32'hab21128 ;
    data[6]= 32'hab21129 ;
    data[7]= 32'hab21121 ;
end

reg [7:0] rw;
initial
begin
    rw[0]= 0 ;
    rw[1]= 0 ;
    rw[2]= 0 ;
    rw[3]= 0 ;
    rw[4]= 0 ;
    rw[5]= 1 ;
    rw[6]= 1 ;
    rw[7]= 0 ;
end

////start register is needed for the real cpu instance. since our special address
////input has additional combinational logic, This register can make sure that
////first instruction fetched by I cache after clear signal is at 0;
//reg start;
//always @(posedge clk)
//begin
//    if (clr)
//        start <=1;
//    else start <=0;
//end

integer i =0;
always @(posedge clk)
begin
    if (clr ) 
        i <= 0;
    else if (~CPU_stall) 
        i <=i+1;
end


assign next_pc = address[i] ;
assign next_data = data[i];
assign next_req = rw[i];

//reg CPU_stall;
//always@(negedge clk)
//begin
//   // if (clr) CPU_stall<=0;
//    //else 
//    CPU_stall<=~CPU_ready;
//end
wire CPU_stall = clr ? 0: ~(CPU_ready && 1);

assign BUS_addr_o=BUS_addr;
assign BUS_data_o= BUS_data;
assign CPU_addr_o = PC;
assign CPU_data_o = CPU_data;
assign BUS_req_o = BUS_req;
assign BUS_ready_o = BUS_ready;
assign BUS_RW_o = BUS_RW;
assign CPU_stall_o = CPU_stall;
assign CPU_ready_o = CPU_ready;

assign DMA_o= DMA;
assign grant_o = grant;
assign next_pc_o = next_pc;



endmodule