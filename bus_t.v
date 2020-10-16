
//FILE:             bus_t.v
//DESCRIPTION:      This file describes a module used for testing the bus.
//                  Two DMA devices and two slave (memory) devices are connected
//                  to the bus, use the bus output to analysis the operation of
//                  the bus.
//DATA:             2020-10-14
//AUTHOR:           Thimble Liu
//
//INTERFACE:        Interface is same with the bus
//                  I/O     NAME          DESCRIPTION   
//                  input:  clk           clock from bus
//                  output: address_o     32-bit address bus
//                          data_o        32-bit data bus
//                          request_o     request line 
//                          ready_o       ready line
//                          rw_o          read or write line
//                          DMA_o         8-bit DMA request
//                          grant_o       8-bit DMA request granted line
//                  output: 
//                  inout : 
//
//
//This module is the test bench for bus
module bus_t(
    clk,address_o,data_o,request_o,ready_o,rw_o,DMA_o,grant_o ,ready_inner
);
    output [31:0] address_o, data_o;
    output request_o, ready_o,rw_o,ready_inner;
    output [7:0] DMA_o, grant_o;

    input clk;

    //These wires are internal bus signal
    wire [31:0] address,data;
    wire request, ready, r_w;
    wire [7:0] DMA, grant;

   //these ports are used by the simulator output
    assign address_o =address;
    assign data_o = data;
    assign request_o = request;
    assign ready_o = ready;
    assign rw_o = r_w;
    assign DMA_o = DMA;
    assign grant_o = grant;

    //instances of bus component
    bus_control bus_control_0 (DMA,grant, request,ready,clk);
    dummy_slave dummy_slave_a (clk,address,data,request,ready,r_w);
    dummy_slave_1 dummy_slave_b (clk,address,data,request,ready,r_w);
    dummy_master dummy_master_a (clk,DMA[0],ready, grant[0],address,data,r_w);
    dummy_master_1 dummy_master_b (clk,DMA[1],ready, grant[1],address,data,r_w,ready_inner);    
endmodule