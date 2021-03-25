//timer is a slave device which is connected to the bus
module timer(
    clk,address,data,request,ready_out,r_w
    //,timer1, timer2,read,selected
);
    input clk, r_w, request;
    input [31:0] address;
    inout [31:0] data;
    output ready_out;
    //output [31:0] timer1, timer2, read;
    //output selected;

    //address range
    reg [31:0] entry_start, entry_end;
    initial 
    begin
		//This port has two registers
        entry_start=32'h3fffffc;
        entry_end  =32'h3fffffd;
	end

    //selected if request in address range
 reg selected;
    always @(*)
    begin
        if (($unsigned(address) >= $unsigned(entry_start)) &($unsigned(address) <=$unsigned(entry_end)) &request )
            selected = 1;
        else    selected =0;
    end
    //the timer
    //The timer is configured as read only, and the unit is millisecond. 
    reg [31:0] timer1, timer2,tick;

    initial begin
        timer1 = 32'b0;
        timer2 = 32'b0;
        tick   = 32'b0;
    end
    
    always @(posedge clk)
    begin
        if (tick >= 50000)
        begin
            tick <= 0;
            timer1 <= timer1 +1;
        end
        else 
        begin
            tick <= tick +1;
        end
        timer2 <= timer2 +1;
    end

    //bus interface
	//registers in this port always ready in one clock cycle
    wire [31:0] read;
	assign ready_out = selected ? 1'b1 :1'bz;

    assign data = selected ? 35 :32'bz;
    assign read = address[0] ? timer2 : timer1;

endmodule