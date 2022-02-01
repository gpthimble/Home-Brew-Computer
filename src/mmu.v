//FILE:         mmu.v
//DESCRIPTION   This is the memory control unit



module mmu (
    //control signal from CU
    mmu_en, mmu_update,
    //32-bit virtual address input
    vaddr_in,
    //virtual page number input
    vpage_in,
    //physical page number input
    ppage_in,

    //mmu error signal output
    mmu_error_o,
    //32-bit physical address output
    paddr_o,

    //clock input
    clk,

    //clear signal
    clr,
    
    //stall signal
    stall,
);

//This parameter determined the size of the page
//default setting is 20, which means the page size is 4KB
parameter PAGE_NUM_WIDTH = 20;

//mmu_en is HIGH, if the processor is in User mode.
//mmu_en is LOW, if the processor is in the kernel mode.
//mmu_update is HIGH, if there's a valid eret instruction.
input mmu_en, mmu_update;

//Virtual page number and physical page number input, these numbers
//are updated when the mmu_update is HIGH.
input [PAGE_NUM_WIDTH - 1 : 0] vpage_in, ppage_in;

//32-bit Virtual addresses input 
input [31:0] vaddr_in;
//32-bit physical address output
output [31:0] paddr_o;

//If the page number in the virtual address not equal to the virtual
//page number mmu_error is HIGH
output mmu_error_o;

//clock input
input clk;

input clr;

input stall;

//register virtual page number, physical page number and if the mmu is on
reg [PAGE_NUM_WIDTH-1 :0] vpage_reg, ppage_reg;
reg mmu_en_reg;
initial begin
    vpage_reg <= 0;
    ppage_reg <= 0;
    mmu_en_reg <= 0;
end

always @(posedge clk) begin
    if (mmu_update & ~stall) begin
        vpage_reg <= vpage_in;
        ppage_reg <= ppage_in;
        mmu_en_reg <= mmu_en;
    end
end

//generate the internel control signal
//if there is a mmu_update signal, use the new values as control
wire en = mmu_update ? mmu_en : mmu_en_reg;
wire [PAGE_NUM_WIDTH-1 : 0] vpage = mmu_update ? vpage_in : vpage_reg;
wire [PAGE_NUM_WIDTH-1 : 0] ppage = mmu_update ? ppage_in : ppage_reg; 

//generate the mmu error signal
assign mmu_error_o =(en & ~(vaddr_in [31: 32-PAGE_NUM_WIDTH] == vpage ))? 1:0;

//do the address translation
assign paddr_o = en ? {ppage,vaddr_in[31-PAGE_NUM_WIDTH : 0]} : vaddr_in;


endmodule