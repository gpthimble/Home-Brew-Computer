//FILE:         cache.v
//VERSION:      0.3
//DESCRIPTION:  This file implemented the cache module.
//              
//              Features
//              *Cache is automatically synced from the BUS*
//              Cache will monitor all write requests on the bus (except write 
//              requests issued by itself). 
//
//              *Cache request can be canceled without causing a bus error*
//              The Bus controller is a simple one, it can't process the revoke
//              operation. The cancellation mechanism can ensure that when the 
//              request is sent to the bus, the request will not be cancelled but 
//              wait until the request is completed.
//
//              * Request on cached data only need one clock cycle *
//              This feature is adapted for our five-stage pipeline and delay 
//              slot for branch.
//
//              * 2-way set associate configuration *
//              The implementation here has a 2-way set associate configuration,
//              most of the storage should be implemented by on board RAM of FPGA,
//              the valid RAM is implemented by registers due to lack of clear
//              support of on board RAM.
//              
//              * Customize no cache range *
//              This feature is used for memory mapped IO and DMA access. Memory
//              in this range is not cached. (param no_cache_start & no_cache_end)
//
//              * Write Policy is Write through *
//
//              Some tricky problems.
//              1.How to make data ready in one clock.
//              If there's a cache hit, data is ready in only one clock; If there's
//              a cache miss, data is ready whenever the bus is ready. It is a 
//              little tricky to achieve this, but it is necessary. If cache hits,
//              CPU is not stalled, the data must be ready in one clock, since we 
//              have a five-stage pipeline, and only one delay slot when branch. 
//              If the data can't be ready when cache hits in one cycle, we have to
//              change the design of the pipeline and the number of delay slot. I 
//              don't want to change them, so I did my best to make the cache ready 
//              in one clock when there's a cache hit. 
//              To achieve this, the feature of the onboard RAM of FPGA must be 
//              considered, input ports of the onboard RAM have build-in registers.
//              This makes the timing task a little bit tricky. If we use a delicate
//              PC or EXE-MEM stage register, there will be a clock delay due to this
//              internal register; if we directly connect the onboard RAM to next pc
//              or exe stage, we can't handle the stall of cpu, since next pc changes
//              continuously, we can't stop that. So there must be an mechanism to 
//              help the cache to distinguish the state of CPU. If there's a new cpu
//              cycle, the input of onboard ram should be connected directly to the
//              next PC or EXE stage; if cpu is stalled, the input of onboard ram 
//              should be connected to the stage pipeline register, ie PC or EXE-MEM
//              stage register. So I use the cpu stall signal to select input of on
//              board ram. If the stall signal is HIGH, it means cpu is waiting, the
//              input of onboard ram should be the old (registered) value; if stall
//              signal is LOW, it means this is a new instruction, the input of onboard
//              ram should be the new value (directly connected to the next pc or exe).
//              2.Avoid logic loop
//              Because the address input has additional combinational logic to select
//              between direct or registered value, Stall signal is based on cache ready
//              design can easily trap in to combinational logic loop. To avoid this
//              I did some debug, Carefully distinguish which signals should be placed 
//              in registers.
//
//DATE:         2020-12-28
//AUTHOR:       Thimble Liu

module cache 
(
    CPU_stall,
    CPU_addr, CPU_data, CPU_req, CPU_RW, CPU_clr,
    data_o, ready_o,
    addr_reg_o,
    BUS_addr, BUS_data, BUS_req, BUS_RW, BUS_grant, BUS_ready,
    cancel,
    clr,
    clk
    //for debug 
    ,WE_A_o,WE_B_o,WE_C_o,need_update_o,TAG_A_out_o,HIT_A,HIT_B,RAM_A_out,TAG_A_sync
);

//------------------------- Interface description   -----------------------------
//This is the stall signal from CPU.This signal is HIGH when the cpu is paused.
//This pin is the write enable of all the input registers in this module, when
//CPU is stopped, values of these registers should not change. This input registers
//act as pipeline registers, because the on board RAM of FPGA must have a registered
//input.
    input CPU_stall;

//This is a 32-bit input for address. Altera on board RAM has a build-in register in
//address port, so address port of ram is directly connected to this signal. There
//also is a register in the cache to register this address for other part of cache and
//other stages of pipeline.
    input [31:0]    CPU_addr;

//This is a 32-bit input register for data write. This port is not used when this
//module is used for instruction cache, since the I-cache is read-only. When this
//module is used for data cache, this register is also a part of the pipeline
//register as described above.
    input [31:0]    CPU_data;

//This signal is HIGH if a data is requested from the cache. For I cache, This 
//signal should always be HIGH, since the processor always needs to be feeded by
//new instruction. For D cache, this register is part of the pipeline register,
//and if some instruction doesn't need memory access, this signal goes LOW, then
//nothing in the cache ,bus or memory are changed, cache ready signal set HIGH to
//Let the cpu continue.
    input CPU_req;

//This signal is control for read or write, High is for write.
    input CPU_RW;

//This signal is generated by CU (ID stage), when CPU_clr is HIGH, the valid RAM
//is cleared at the next positive edge of the clock. This signal is not registered
//in this module, so ID stage can directly control the clear of I cache and control
// D cache via the pipeline register between EXE and MEM stage.
    input CPU_clr;

//This is 32-bit data output into cpu.
    output reg [31:0] data_o;

//This is 32-bit addr register output for other stages of the pipeline.
    output[31:0] addr_reg_o;

//This is cache ready signal. When both I cache and D cache are ready, CPU can 
//continue.
    output reg ready_o;

//These signals are connected to the BUS, definitions of these signals are same
//as bus.
    inout [31:0] BUS_addr;
    inout  [31:0] BUS_data;
    output        BUS_req; 
    inout         BUS_RW;
    input         BUS_ready,BUS_grant;

//cancel the current request
    input cancel;

//clear signal
    input clr;

//clock input
    input clk;

//for debug
    output WE_A_o,WE_B_o,WE_C_o,need_update_o,HIT_A,HIT_B;    
    output [tag_size-1 : 0] TAG_A_out_o;
    output [31:0] RAM_A_out;

    wire WE_A_o = WE_A;
    wire WE_B_o = WE_B;
    wire WE_C_o = WE_C;
    wire need_update_o = need_update;
    assign TAG_A_out_o = TAG_A_out;
    output [31 : 0] TAG_A_sync;
    assign TAG_A_sync = cache_sync_A;


//--------------------------    Module implementation  -------------------------

//This pair of parameters describe the range of not cached memory.
parameter no_cache_start=32'hFFFFFFF8;
parameter no_cache_end =32'hFFFFFFFC;

//Number of Lines in each group.
localparam cache_lines = 2<< (INDEX -1);
localparam tag_size = 32-2- INDEX;
//default size of the cache is two 512 bytes (128 lines) set, total size is 1KB.
parameter INDEX=7;
parameter WIDTH=32;

//------------------------------    FROM CPU  -----------------------------------
//Altera on board RAM address port has a internal register, so the address port
//of ram is directly connected to the input, other part of cache and the pipeline
//still need a registered address.
//If instance of this module is a 
//instruction cache, this register is the -PC register-. And if the instance of 
//this module is a data cache, this register acts as part of the pipeline register
//between EXE and MEM stage.
reg [31:0] addr_reg, data_reg;
reg CPU_req_reg, CPU_RW_reg, CPU_clr_reg;
always @ (posedge clk)
begin
    if (clr)
        begin
            addr_reg <= 0;
            data_reg <= 0;  
            CPU_req_reg <= CPU_req;
            CPU_RW_reg  <= 0;
            CPU_clr_reg <= 0;
        end
    else if (~ CPU_stall) 
        begin
            addr_reg <= CPU_addr;   
            data_reg <= CPU_data;
            CPU_req_reg <= CPU_req;
            CPU_RW_reg  <= CPU_RW;
            CPU_clr_reg <= CPU_clr;
        end
end
//Output of addr_reg for other stages of the pipeline.
wire [31:0] addr_reg_o = addr_reg;

//As mentioned above, if cpu is not stalled, it means that there is a new instruction,
//the address to drive cache should be connected to next pc or exe stage directly. 
//If cpu is stalled, address should be the registered value to maintain the unfinished
//request. This is the key to achieve that data should be ready in one clock when there
//is a cache hit.
//Some part of this module must use registered value of below to avoid logic loop from
//CPU_stall to ready_o.
wire [31:0] addr = CPU_stall ? addr_reg : CPU_addr;

wire [31:0] data = CPU_stall ? data_reg : CPU_data;

wire        req  = CPU_stall ? CPU_req_reg : CPU_req;   
wire        RW   = CPU_stall ? CPU_RW_reg  : CPU_RW;
wire  cache_clr  = CPU_stall ? CPU_clr_reg : CPU_clr;

//NO_CACHE is HIGH if requested address is in no cache range.
//This signal is a registered value. Use a registered value to avoid logic loop.
reg NO_CACHE;
always@(posedge clk)
begin
    if (clr) 
        NO_CACHE <= 0;
    else if (~ CPU_stall) 
        NO_CACHE <= (addr <= no_cache_end) && (addr >=no_cache_start);
end

//vector index is for indexing the whole cache.
wire [INDEX-1:0] index = addr[INDEX+1 :2];
wire [INDEX-1:0] index_reg = addr_reg[INDEX+1 :2];

//vector tag is used to determined if there's a cache hit, if not, new tag is written
//in the tag storage. 
wire [tag_size-1:0] tag   = addr[31:INDEX+2];
wire [tag_size-1:0] tag_reg = addr_reg [31:INDEX+2];
//----------------------------------------------------------------------------------

//----------------------------sniffing from the BUS---------------------------------
//BUS_addr_reg registered the address bus
reg [31:0] BUS_addr_reg;
//BUS_RW_reg registered the write request of the BUS.
//BUS_grant_reg registered the grant signal for this cache. It is used to identify 
//whether the currently monitored bus request is issued by itself. The bus request 
//issued by itself does not need to be monitored. 
reg BUS_RW_reg, BUS_grant_reg;
always @ (posedge clk)
begin
    if (clr)
        begin
            BUS_addr_reg <= 32'b0;
            BUS_RW_reg   <= 0;
            BUS_grant_reg<= 0;
        end
    else    
        begin
            BUS_addr_reg <= BUS_addr;
            BUS_RW_reg   <= BUS_RW;
            BUS_grant_reg<= BUS_grant;
        end
end
//sync index from the BUS or BUS register
wire [INDEX-1:0] index_sync = BUS_addr [INDEX+1 : 2];
wire [INDEX-1:0] index_sync_reg = BUS_addr_reg [INDEX+1 : 2];
//sync tag from the BUS or BUS register
wire [tag_size-1:0] tag_sync = BUS_addr [31:INDEX+2];
wire [tag_size-1:0] tag_sync_reg = BUS_addr_reg[31:INDEX+2];
//----------------------------------------------------------------------------------

//Write enable signal for group A B and C.
wire WE_A, WE_B, WE_C;

//------------------------------------TAGS--------------------------------------
//Memory for TAG A and TAG B. 
//Lines of tags are calculated by: 2<<(index-1) as same as the cache lines in a group.
//Size of tags are calculated by: (32-bit address) - (2-bit word index) - INDEX.
//  Since tags are used to store the part of address that not used in indexing
//  cache lines. This cache has a line size of 4 bytes (2-bit word index) and 
//  two 2 << (INDEX -1) lines set, thus, lower 2+INDEX bits are used for indexing.
reg [tag_size-1 : 0] TAG_A [0 : cache_lines-1];
reg [tag_size-1 : 0] TAG_B [0 : cache_lines-1];

//Out put of TAG_A and TAG_B
reg [tag_size-1 : 0] TAG_A_out, TAG_B_out;

//Out put registers for bus sniffing.
reg [tag_size-1 : 0] TAG_A_sync_out, TAG_B_sync_out;

//Memory for TAG_A.
always @(posedge clk)
begin
    if (WE_A) 
        TAG_A [index_reg] = tag_reg;
    //This is a registered read out. since the index can change according to the
    //state of CPU, use a continuous read (assign statement) could cause a 
    //combinational logic loop from CPU_stall to ready.    
    //if read and write at same time, get the new value.
    TAG_A_out = TAG_A [index];

    //read for cache sync is index by the bus directly
    TAG_A_sync_out = TAG_A [index_sync];
end

//Memory for TAG_B.
always @(posedge clk)
begin
    if (WE_B)
        TAG_B [index_reg] = tag_reg;
    //This is a registered read out. since the index can change according to the
    //state of CPU, use a continuous read (assign statement) could cause a 
    //combinational logic loop from CPU_stall to ready.
    //if read and write at same time, get the new value.
    TAG_B_out = TAG_B [index];

    //read for cache sync is index by the bus directly
    TAG_B_sync_out = TAG_B [index_sync];
end
//----------------------------------------------------------------------------

//-------------------------------VALID REGISTERS------------------------------

//Registers for valid storage. Single bit register can only be defined as scalar.
reg [cache_lines-1:0] VALID_A, VALID_B;

//These two always blocks implement the 2 sets valid bits. Since clear function
//is not supported by altera on board RAM, these two blocks synthesize into 
//registers. 

//as same as TAG & RAM, read address can be directly or from the address
//register based on the state of the CPU (CPU_stall). Since the write request
//always effective at the next clock edge, write address should always be the
//registered value.
//valid bits for group A.
reg VALID_A_out ;
always @(posedge clk)
begin
    if (clr || cache_clr)
        VALID_A = 32'b0;
    else if (WE_A) 
        VALID_A[index_reg] =1;
    else if (VALID_A_clr)
        VALID_A[index_sync_reg] =0;
    //This is a registered read out. since the index can change according to the
    //state of CPU, use a continuous read (assign statement) could cause a 
    //combinational logic loop from CPU_stall to ready.
    //If read and write at same time, get the new value.
    VALID_A_out = VALID_A[index];
end


//valid bits for group B.
reg VALID_B_out;
always @(posedge clk)
begin
    if (clr || cache_clr)
        VALID_B = 32'b0;
    else if (WE_B) 
        VALID_B[index_reg] =1;
    else if (VALID_B_clr)
        VALID_B[index_sync_reg] =0;
    //This is a registered read out. since the index can change according to the
    //state of CPU, use a continuous read (assign statement) could cause a 
    //combinational logic loop from CPU_stall to ready.
    //If read and write at same time, get the new value.
    VALID_B_out = VALID_B[index];
end

//Valid_c is for requests that address is in no cache range.
//valid bit for group C is special. Purpose of group C is to make sure that
//any request on no cache range is cast on the bus. So whenever a new request
//comes to cache (cpu is not stall), this bit is cleared. Also, when a request
//has been answered from the bus, this bit should be set, because when this
//cache is ready, CPU may still in stall, and the clock is still running. If we
//don't registered this bit, ready signal comes from bus may be missed. All 
//three group of valid bits are the key to cache hit signal sended to cpu,
//if cpu is stall by other reason while bus just completed the request, cache
//hit signal is switch to the valid bit from bus ready signal.
reg VALID_C;

always @(posedge clk)
begin
    //clear valid_c for every new request, since every request into no cache zone
    //should be cast to the bus, this provide the necessary cache miss signal.
    if ((~CPU_stall) || clr )
        VALID_C <= 0;
    else if (WE_C) 
        VALID_C <= 1;
    else if (VALID_C_clr)
        VALID_C <= 0;
end
//another name for valid_C.
wire VALID_C_out = VALID_C;
//----------------------------------------------------------------------------

//----------------------------------RAM---------------------------------------

//Cache has 2 sets, each set has 128 (by default) lines
reg [31:0] RAM_A [0 : cache_lines-1];
reg [31:0] RAM_B [0 : cache_lines-1];

wire [31:0] RAM_in;

//as same as TAG & valid bits, read address can be directly or from the address
//register based on the state of the CPU (CPU_stall). Since the write request
//always effective at the next clock edge, write address should always be the
//registered value.
reg [31:0] RAM_A_out;
always @(posedge clk)
begin
    if (WE_A)
        RAM_A[index_reg] = RAM_in;
    //if read and write at same time, get the new value.
    RAM_A_out = RAM_A[index];
end

reg [31:0] RAM_B_out;
always @(posedge clk)
begin
    if (WE_B)
        RAM_B[index_reg] = RAM_in;
    //if read and write at same time, get the new value.
    RAM_B_out = RAM_B[index];
end

//RAM_C is for request in no cache range.
//Although request in this range doesn't need to be cached, value return from
//the bus need to be registered since the cpu may be stalled by other cache,
//when cpu is ready to move on, data on the bus has already gone.
reg [31:0] RAM_C;
wire [31:0] RAM_C_out;

always @(posedge clk)
begin 
    if (WE_C)
        RAM_C <= RAM_in;
end
//ram_c_out is another name of RAM C.
assign RAM_C_out = RAM_C;
//-----------------------------------------------------------------------------

//------------------------------ BUS interface --------------------------------

//If request is granted by bus controller, put addr on the bus, otherwise high z.
assign BUS_addr = BUS_grant ? addr_reg : 32'bz;

//If request is granted, put r/w signal on the bus, otherwise put high z.
assign BUS_RW = BUS_grant ? CPU_RW_reg : 1'bz;

//mask out ready signal from bus if not granted, since the ready is for other device.
wire ready_in = BUS_grant ? BUS_ready : 1'b0;

//BUS_data is bi-direction port. When read, put high z on bus and read from the bus
//when write, put data on bus.
wire [31:0] data_to_bus = CPU_RW_reg ? data_reg : 32'bz;
assign BUS_data = BUS_grant ? data_to_bus : 32'bz;


//This signal is HIGH when there's a request that needs to read or write from/to the
//bus.
//If cache need to access the bus, the BUS_req signal should be set high until ready
//signal from the bus is acknowledged. So if it's a read request, BUS_req is cache
//miss signal, at the next positive edge of clock after ready comes from the bus, 
//cache will be filled and cache hit will be HIGH, thus BUS_req will be LOW.
//If it's a write request, BUS_req is HIGH when it's a new instruction, otherwise
//BUS_req will be determined by the registered ready signal. This implements the
//write through policy.
//BUS_req is masked by CPU_req_reg, use registered value of cpu req can avoid
//false req caused by next_PC.
//BUS request can be canceled if the request hasn't been sent
assign BUS_req = CPU_req_reg &(~cancel | req_sent) & ((~CPU_RW_reg & ~CACHE_HIT_R )
                |(CPU_RW_reg & ~ready_reg));
//-----------------------------------------------------------------------------

//------------------------------ Cache control---------------------------------
//-------------------------------cancel mechanism------------------------------
//The bus controller we used here is a simple controller, it can't handle
//situations like cancelling the sent request. So when cancel signal is high
//we need to make sure that the sent request is still there.
//To achieve this we use a register to indicate whether the request has been 
//sent during this cycle.
reg req_sent;
always @(posedge clk)
begin
    if (clr) 
        req_sent <=0;
    //req_sent resets when every new instruction is pre-fetched
    //req_sent is reset when a new request is coming or the request is done. 
    else if (~CPU_stall|ready_in)
        req_sent <=0;
    //req_sent goes high when the cache request the bus. 
    else if (BUS_grant)
        req_sent <=1;
end

//--------------------------------sync control---------------------------------
//cache_sync signal is HIGH when the sniffed request from the bus is cached. 
wire cache_sync_A, cache_sync_B, cache_sync_C;
//~BUS_grant_reg means that we don't sync the request that issued by itself
//BUS_RW_reg means that we only sync the write request
//(tag_sync_reg == TAG_A_sync_out) means that the sync mechanism is active when
//the sniffed request is cached. 
assign cache_sync_A = ~BUS_grant_reg & BUS_RW_reg & (tag_sync_reg == TAG_A_sync_out);
assign cache_sync_B = ~BUS_grant_reg & BUS_RW_reg & (tag_sync_reg == TAG_B_sync_out);
assign cache_sync_C = ~BUS_grant_reg & BUS_RW_reg & NO_CACHE & HIT_C
                        & (BUS_addr_reg == addr_reg);

//VALID_X_clr is HIGH when we need to clear the valid bit. 
wire VALID_A_clr, VALID_B_clr, VALID_C_clr;

//There are two situations here:
//  1. The monitored request is different from the request to the cache
//          --Clear valid bit directly
//  2. The monitored request is the same as the request to the cache
//          --Clear valid bit only when there's a read hit. 
assign VALID_A_clr = (BUS_addr_reg == addr_reg) ? 
                (cache_sync_A & ~CPU_RW_reg & HIT_A) : cache_sync_A;
assign VALID_B_clr = (BUS_addr_reg == addr_reg) ? 
                (cache_sync_B & ~CPU_RW_reg & HIT_B) : cache_sync_B;

//for valid bit C, if the current request has registered in group C,
//clear the valid bit C and mask out the read hit signal. 
assign VALID_C_clr = cache_sync_C;

wire HIT_mask ;
assign HIT_mask = (BUS_addr_reg == addr_reg)? 
                (VALID_A_clr|VALID_B_clr|VALID_C_clr) : 1'b0;


//------------------------------cache ready signal-----------------------------

//ready signal comes from bus should be registered, otherwise, cpu could miss
//the ready signal when cpu is stalled.
reg ready_reg;
always @(posedge clk)
begin
    if (~CPU_stall)
        ready_reg <= 0;
    else if (CPU_req_reg && ready_in)
        ready_reg <= 1;
end

//cache hit signals.
wire HIT_A = tag_reg == TAG_A_out && VALID_A_out;
wire HIT_B = tag_reg == TAG_B_out && VALID_B_out;
wire HIT_C = VALID_C;

//If request is in no cache range, cache hit signal is from group C. Otherwise,
//announce cache hit if there's a hit at group A or B.
//This signal is used when the request is a read request.
wire CACHE_HIT_R = (NO_CACHE ? HIT_C : (HIT_A|HIT_B)) & ~HIT_mask;

//This signal tells CPU that cache is ready. This is a important signal.
//
always @(*)
begin
    //if there's no request to cache, cache ready is HIGH
    if (~CPU_req_reg)
        ready_o <= 1;
    //if the request has been canceled, cache ready is HIGH
    else if (cancel & ~req_sent)
        ready_o <= 1;
    //If the request is a write request. When and after the bus announced ready
    //The cache is ready. Registered ready signal avoids missing ready signal when
    //CPU is stalled.
    //rw and req signal should be the registered one to avoid logic loop from
    //CPU_stall to ready_o.
    else if (CPU_RW_reg) 
        //use CPU_req_reg as a mask can filter the HIGH Z on bus ready.
        ready_o <= (CPU_req_reg && ready_in) || ready_reg;
    //IF the request is a read request. If there is a cache hit, or cache miss but
    //BUS ready, the cache is ready. When cache isn't hit, cache hit signal will be
    //HIGH at the next positive edge of clock when received ready signal from the bus.
    else 
        ready_o <= (CPU_req_reg && ready_in) || CACHE_HIT_R;
end

//Controlling update of the cache. Need to figure out two questions below:
//      1.when does the cache need to be updated?
//      2.which group of cache needs to be updated?
//Logic here is going to solve these two problems.
//WE_A WE_B and WE_C are the control signal of cache update, logic should
//select the right group at the right time.

//Whenever there's a request on bus, the cache needs to be updated when bus is ready.
//Use BUS_grant to indicate a request on bus can avoid HIGH Z signal from the bus 
//feed into the logic here.(The bus should have a pull down resistor, but I can't
//simulate the resistor, so use a mask to filter the ready signal) 
wire need_update = BUS_grant && ready_in;

//-------------------------------group select mechanism---------------------------

//select proper group to replace. Replace policy is random replace.
//a random number generator, used to decide which group should be replaced.
reg random;
always @(posedge clk)
begin
    random <= random+ 1'b1;
end

//There're two situations: 1. The requested address is in the no cache range
//                         2. other situation.
//1.If the requested address is in the no cache range. Since there's only one
//group for this range (group C), we just replace this group when bus ready.
assign WE_C = NO_CACHE && need_update;

//2.If the requested address is in other range, need to select a group to replace.
//There are three more situations here:
//      1. Replace group with the same tag first. This make sure tag of two group
//          is different.
//      2. when both group are empty or valid, we need to use the counter described 
//          above to randomly choose one group; 
//      3. otherwise, we should replace the empty group;
reg [1:0] group_sel;
always @(*)
begin
    //replace group with the same tag first.
    if (TAG_A_out == tag_reg)
        group_sel <= 2'b01;
    else if (TAG_B_out ==tag_reg)
        group_sel <= 2'b10;
    //if both group is empty or valid, randomly choose one group.
    else if (VALID_A_out == VALID_B_out)
        group_sel <= random ? 2'b01 : 2'b10;
    //if only one group is empty, choose the empty group.
    else
        group_sel <= VALID_A_out ? 2'b10 : 2'b01;
end
//only when requested address is in cache range, WE_A or WE_B can be active.
assign WE_A = (~NO_CACHE) && need_update && group_sel[0];
assign WE_B = (~NO_CACHE) && need_update && group_sel[1];


//------------------------------RAM input select--------------------------------
//If the request is a read request, input of ram should be the data from the bus;
//If the request is a write request, input of ram should be the data from the CPU;
//read/write signal should be the registered one to avoid logic loop.
assign RAM_in = CPU_RW_reg ? data_reg : BUS_data;

//-------------------------------data output to cpu------------------------------
always@(*)
begin
    //If the request is a write request, no need to output data to CPU.
    if (CPU_RW_reg)
        data_o <= 32'b0;
    //If the request is a read request. 
    //when the bus ready, data output to cpu is the data from the bus.
    else if (ready_in)
        data_o <= BUS_data;
    //If cpu is stalled when bus is ready, data from bus has been stored in different
    //part of cache, so data output to cpu should be the output of corresponding group.
    else if (NO_CACHE)
        data_o <= RAM_C_out;
    else if (HIT_A)
        data_o <= RAM_A_out;
    else if (HIT_B)
        data_o <= RAM_B_out;
    else
        data_o <= 32'b0;
end
//-------------------------------------------------------------------------------

endmodule
