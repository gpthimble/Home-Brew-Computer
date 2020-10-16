//FILE:             dummy_slave.v
//DESCRIPTION:      This file describes a dummy slave device for testing the bus
//                  and bus controller. This device can be used as a simulated
//                  RAM or ROM to run the CPU.
//DATA:             2020-10-14
//AUTHOR:           Thimble Liu
//
//INTERFACE:        Interface is same with the bus
//                  I/O     NAME          DESCRIPTION   
//                  input:  clk           clock from bus
//                          r_w           write or read from bus.High is for write
//                          request       request from bus.
//                          address       32-bit address from bus.
//                  output: ready         put ready signal onto bus.
//                  inout : data          tristate data bus.
//
//

//module for dummy slave devices.
module dummy_slave( 
    clk,address, data, request, ready_out, r_w
);
    input clk, r_w, request;
    input [31:0] address;
    inout [31:0] data;
    output ready_out;

//--------------------------    Module implementation  -------------------------
    //dummy memory
    reg [31:0] mem [0:32-1];

    //internal state machine
    reg [ 2:0] state;

    //address range
    reg [31:0] entry_start, entry_end;

    //internal registers for bus signal
    reg [31:0] addr_reg,data_reg;
    reg r_w_reg,selected_reg;

    initial 
    begin
        entry_start=32'b0;
        entry_end  =32'b11111;
        state      = 0;
        //ready signal is Z when idle, ready line should have a tri0 
        //pulldown resistance. because there're other devices on the
        //bus.
        ready = 1'b0;
        addr_reg =0;
        data_reg=0;
        r_w_reg=0;
        selected_reg=0;
    end


    //selected if request in address range
    reg selected;
    always @(*)
    begin
        if ((address >= entry_start) &(address <=entry_end) &request )
            selected = 1;
        else    selected =0;

    end 
    //put the ready_out High Z when device is not selected.   
    reg ready;
    assign ready_out = (selected | selected_reg) ? ready : 1'bz;

    //implement inout data port.
    //if device is selected and the request is a read request, this device
    //will put data onto the bus. In any other condition, the output will be
    //high Z.
    assign data = (selected_reg & ~r_w_reg & ready) ? read :32'bz;

    //read is the continuous read data out.
    wire [31:0] read;
    assign read = mem[addr_reg];

    //the state machine implements the dummy wait cycles and ready signal.
    //one dummy operation needs four cycles.
    always @(posedge clk)
    begin
        //If device is in idle state and selected, register address, r_w 
        //and data.
        if ((state == 2'b00)& selected) begin
            state <=  2'b01;

            //pull the ready line low.
            ready <=  0;

            //registered the request
            addr_reg<= address;
            r_w_reg <= r_w;
            selected_reg<=selected;
            if (r_w) begin
                data_reg<= data;
            end
        end
        //dummy write and read.
        else if (state == 2'b01 ) begin
            state <= 2'b10;
            if (r_w_reg) 
                mem[addr_reg] <= data_reg; 
        end       
        //dummy wait. 
        else if (state == 2'b10) begin
            state <= 2'b11;
        end
        //operation ready
        else if (state == 2'b11) begin 
            state <= 3'b100;
            //one cycle ready signal
            ready <= 1;
        end

        //goto idle next cycle, ready for next request
        else if (state ==3'b100) begin
            state <= 00;
            ready <= 1'b0;
            selected_reg<= 0;
            r_w_reg <=0;
            data_reg <=0;
            addr_reg<=0;
        end
        else begin 
            //if device is idle, and there's no request on this device
            //clear all internal registers.
            state <= 00;
            ready <= 1'b0;
            selected_reg<= 0;
            r_w_reg <=0;
            data_reg <=0;
            addr_reg<=0;
        end
    end
endmodule //dummy_slave


module dummy_slave_1
//This module is identical to dummy_slave, but with different entry point.                   
                    ( 
    clk,address, data, request, ready_out, r_w
);
    input clk, r_w, request;
    input [31:0] address;
    inout [31:0] data;
    output ready_out;

//--------------------------    Module implementation  -------------------------
    //dummy memory
    reg [31:0] mem [0:32-1];

    //internal state machine
    reg [ 2:0] state;

    //address range
    reg [31:0] entry_start, entry_end;

    //internal registers for bus signal
    reg [31:0] addr_reg,data_reg;
    reg r_w_reg,selected_reg;

    initial 
    begin
        entry_start=32'b100000;
        entry_end  =32'b111111;
        state      = 0;
        //ready signal is Z when idle, ready line should have a tri0 
        //pulldown resistance. because there're other devices on the
        //bus.
        ready = 1'b0;
        addr_reg =0;
        data_reg=0;
        r_w_reg=0;
        selected_reg=0;
    end


    reg ready;
    //selected if request in address range
    reg selected;
    assign ready_out = (selected | selected_reg) ? ready : 1'bz;
    always @(*)
    begin
        if ((address >= entry_start) &(address <=entry_end) &request )
            selected = 1;
        else    selected =0;

    end 
       
    //implement inout data port.
    //if device is selected and the request is a read request, this device
    //will put data onto the bus. In any other condition, the output will be
    //high Z.
    assign data = (selected_reg & ~r_w_reg & ready) ? read :32'bz;

    //read is the continuous read data out.
    wire [31:0] read;
    assign read = mem[addr_reg];

    //the state machine implements the dummy wait cycles and ready signal.
    //one dummy operation needs four cycles.
    always @(posedge clk)
    begin
        //If device is in idle state and selected, register address, r_w 
        //and data.
        if ((state == 2'b00)& selected) begin
            state <=  2'b01;

            //pull the ready line low.
            ready <=  0;

            //registered the request
            addr_reg<= address;
            r_w_reg <= r_w;
            selected_reg<=selected;
            if (r_w) begin
                data_reg<= data;
            end
        end
        //dummy write and read.
        else if (state == 2'b01 ) begin
            state <= 2'b10;
            if (r_w_reg) 
                mem[addr_reg] <= data_reg; 
        end       
        //dummy wait. 
        else if (state == 2'b10) begin
            state <= 2'b11;
        end
        //operation ready
        else if (state == 2'b11) begin 
            state <= 3'b100;
            //one cycle ready signal
            ready <= 1;
        end

        //goto idle next cycle, ready for next request
        else if (state ==3'b100) begin
            state <= 00;
            ready <= 1'b0;
            selected_reg<= 0;
            r_w_reg <=0;
            data_reg <=0;
            addr_reg<=0;
        end
        else begin 
            //if device is idle, and there's no request on this device
            //clear all internal registers.
            state <= 00;
            ready <= 1'b0;
            selected_reg<= 0;
            r_w_reg <=0;
            data_reg <=0;
            addr_reg<=0;
        end
    end
endmodule //dummy_slave