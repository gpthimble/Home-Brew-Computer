//FILE:         dummy_master.v
//DESCRIPTION:  This module is a dummy master device used for testing the
//              bus. This module is implemented by a request queue. 
//DATE:         2020-10-16
//AUTHOR:       Thimble Liu


module dummy_master(
    clk, request, ready, grant, address, data, r_w
);
    input clk, ready, grant;
    output request, r_w;
    output [31:0] address;
    inout [31:0] data;

    //dummy requests.
    reg [31:0] req_addr [0:32-1];
    reg [31:0] req_r_w;
    reg [31:0] req;
    wire ready_inner;

    //dummy memory operation.
    reg [31:0] mem      [0:32-1];

    reg [4:0]       req_num  ;
    //initial dummy operations.
    initial
    begin
        //operation 0, write 0xA7 to address 15;
        req_num = 5'b0;

        //single bit register can't be declared as vector
        req     = 32'b00000000000000000000000000010111;
        req_r_w = 32'b00000000000000000000000000000101;

        req_addr[0] = 32'd15;
        mem     [0] = 32'hA7;

        //operation 1, read from address 15;
        req_addr[1] = 32'd15;
        mem     [1] = 32'b0;

        //operation 2, write 0x3322fa43 to address 48;
        req_addr[2] = 32'd48;
        mem     [2] = 32'h3322fa43;

        //operation 3, a nop, do nothing, other device's chance
        //req     [3] = 0;
        //req_r_w [3] = 0;        
        req_addr[3] = 0;
        mem     [3] = 0;

        //operation 4, read from address 48;
        //req     [4] = 1;
        //req_r_w [4] = 0;
        req_addr[4] = 32'd48;
        mem     [4] = 0;

        //only four operations for now.
    end
    //internal state machine.
    reg state;
    always @(posedge clk)
    begin
        case (state)
        1'b0:begin
            if (request) state <= 1;     
            else req_num<=req_num +1;
            end
        1'b1:begin 
            if (ready_inner)
                begin
                    if (~req_r_w [req_num]) 
                        mem[req_num] <= data;
                    state <=0;
                    req_num<=req_num +1;
                end
            end
        endcase
    end

    assign request  = req [req_num];

    //High z when not granted
    assign address = grant ? req_addr[req_num] : 32'bz;
    assign r_w = grant ? req_r_w [req_num] : 1'bz;
    wire [31:0] data_out = req_r_w [req_num] ? mem [req_num] :32'bz;
    assign data = grant ? data_out: 32'bz;

    //mask out ready signal when not granted
    assign ready_inner = grant? ready :1'b0; 

endmodule //dummy_master


module dummy_master_1(
//This module is identical to dummy_master, but with different operations.
    clk, request, ready, grant, address, data, r_w, ready_inner
);
    input clk, ready, grant;
    output request, r_w, ready_inner;
    output [31:0] address;
    inout [31:0] data;

    //dummy requests.
    reg [31:0] req_addr [0:32-1];
    reg [31:0] req_r_w;
    reg [31:0] req;
    wire ready_inner;

    //dummy memory operation.
    reg [31:0] mem      [0:32-1];

    reg [4:0]       req_num  ;
    //initial dummy operations.
    initial
    begin
        //operation 0, write 0xA7 to address 15;
        req_num = 5'b0;
        req     = 32'b00000000000000000000000000001111;
        req_r_w = 32'b00000000000000000000000000001001;
        //req     [0] = 1;
        //req_r_w [0] = 1;
        req_addr[0] = 32'd15;
        mem     [0] = 32'hA8;

        //operation 1, read from address 15;
        //req     [1] = 1;
        //req_r_w [1] = 0;
        req_addr[1] = 32'd15;
        mem     [1] = 32'b0;

        //operation 2, write 0x3322fa43 to address 48;
        //req     [2] = 1;
        //req_r_w [2] = 1;
        req_addr[2] = 32'd48;
        mem     [2] = 0;

        //operation 3, a nop, do nothing, other device's chance
        //req     [3] = 0;
        //req_r_w [3] = 0;        
        //req_addr[3] = 0;
        //mem     [3] = 0;

        //operation 4, read from address 48;
        //req     [4] = 1;
        //req_r_w [4] = 0;
        req_addr[3] = 32'd48;
        mem     [3] = 32'h3322fa44;

        //only four operations for now.
    end
    //internal state machine.
    reg state;
    always @(posedge clk)
    begin
        case (state)
        1'b0:begin
            if (request) state <= 1;     
            else req_num<=req_num +1;
            end
        1'b1:begin 
            if (ready_inner)
                begin
                    if (~req_r_w [req_num]) 
                        mem[req_num] <= data;
                    state <=0;
                    req_num<=req_num +1;
                end
            end
        endcase
    end

    assign request  = req [req_num];

    //High z when not granted
    assign address = grant ? req_addr[req_num] : 32'bz;
    assign r_w = grant ? req_r_w [req_num] : 1'bz;
    wire [31:0] data_out = req_r_w [req_num] ? mem [req_num] :32'bz;
    assign data = grant ? data_out: 32'bz;

    //mask out ready signal when not granted
    assign ready_inner = grant? ready :1'b0; 

endmodule //dummy_master
