//FILE:         bus_control.v
//DESCRIPTION   This module is responsible for DMA devices queue. 
//              From DMA0 to DMA7, priority is decreasing.
//DATE:         2020-10-15
//author:       Thimble Liu
//
//INTERFACE:    I/O     NAME          DESCRIPTION
//              input:  dma           DMA devices should connect
//                                    this pin to access the bus.
//                      ready         Slave use this pin to signal
//                                    data ready.
//                      clk           Clock input.
//              output: req           Signal the other devices req.
//                      grant         This pin signal masters which
//                                    request has been granted.
//


module bus_control(
    dma,grant,req,ready,clk
);
    input   [7:0] dma;
    input   ready, clk;
    output  [7:0] grant;
    output  req;

//--------------------------    Module implementation  -------------------------

    //registered grant value.
    reg [7:0] grant_reg;

    //internal state machine
    reg state;
    always @(posedge clk)
    begin
        case (state)

        //Idle state, in this state, if has a req, jump to state busy
        //and register the grant value, this device is chosen, and 
        //other devices' request can't change the output.
            0: begin
                if (req & ready) 
                    state <= 0;
                else if (req) 
                    state <= 1;
                    
                grant_reg <= grant_inner;
                    
            end
        //Busy state, in this state, if has a ready, jump to state idle
            1: begin
                //ready signal should be masked by req to avoid High
                //Z on ready.
                if (req&ready)
                    state <= 0;
            end
        endcase
    end

    //dma request queue.
    reg [7:0] grant_inner;
    always @(*)
    begin
        casez (dma)
            8'bzzzzzzz1 :  grant_inner = 8'b00000001;
            8'bzzzzzz10 :  grant_inner = 8'b00000010;
            8'bzzzzz100 :  grant_inner = 8'b00000100;
            8'bzzzz1000 :  grant_inner = 8'b00001000;
            8'bzzz10000 :  grant_inner = 8'b00010000;
            8'bzz100000 :  grant_inner = 8'b00100000;
            8'bz1000000 :  grant_inner = 8'b01000000;
            8'b10000000 :  grant_inner = 8'b10000000;
            default     :  grant_inner = 8'b00000000; 
        endcase
    end

    //When state == 0 (idle), grant is the instant output of code above
    //When state == 1 (busy), grant is the registered value.
    //This lets the grant output stable when one device has already been
    //chosen.
    assign  grant = state ? grant_reg : grant_inner;

    //The req signal will remain untill ready signal is received.
    assign   req = (|grant) ? 1 : 0;

endmodule //bus_control
