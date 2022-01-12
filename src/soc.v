//This is the test bench of the CPU

module soc (
    clk_in,clr_in,    
    int_in, 
    int_ack, 
    int_num,
    TxD,TxD_ready,
    ledo0,ledo1,ledo2,ledo3,ledo4,ledo5,ledo6,ledo7,
    step_mode,step,
    //,timer1,timer2,read,selected

    //,BUS_addr, BUS_data,
    //BUS_req, BUS_ready, BUS_RW,
    //DMA, grant,
    //PC, next_PC,instruction_o,I_cache_ready,
    //ID_PC,BP_miss,CPU_stall,stall_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
    //da,db,imm,
    //E_PC,E_AluOut,
    //M_PC,D_cache_dout_o,D_cache_ready,
    //W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg
);
    input clk_in,clr_in;
    input int_in;
    output int_ack;
    input [19:0] int_num;
    output TxD,TxD_ready;
    output [6:0] ledo0,ledo1,ledo2,ledo3,ledo4,ledo5,ledo6,ledo7;
    input step_mode,step;
    //output [31:0] timer1,timer2,read;
    //output selected;
    reg clr,clk;


    //output [31:0] BUS_addr, BUS_data;
    //output BUS_req, BUS_ready, BUS_RW;
    //output [7:0] DMA, grant;

    //wire [31:0] PC,ID_PC,E_PC,M_PC, next_PC,instruction_o,D_cache_dout_o,W_RegDate_in
    //    ,E_AluOut,da,db,imm;
    //wire I_cache_ready,BP_miss,stall_IF_ID,W_canceled,W_RegWrite,
    //    W_M2Reg,D_cache_ready,CPU_stall,ban_IF,ban_ID,ban_EXE,ban_MEM;
    //wire [4:0] W_TargetReg;

    wire [31:0] BUS_addr, BUS_data;
    wire BUS_req, BUS_ready, BUS_RW;
    wire [7:0] DMA, grant;

    cpu cpu0(BUS_addr,BUS_data,BUS_RW,BUS_ready,DMA[0],DMA[1],grant[0],
                grant[1],int_in, int_ack, int_num, clr, clk,
                //PC, next_PC,instruction_o,I_cache_ready,
                //ID_PC,BP_miss,CPU_stall,stall_IF_ID,ban_IF,ban_ID,ban_EXE,ban_MEM,
                //da,db,imm,
                //E_PC,E_AluOut,
                //M_PC,D_cache_dout_o,D_cache_ready,
                //W_RegDate_in,W_canceled,W_RegWrite,W_M2Reg,W_TargetReg
                );
    bus_control bus_control0(DMA,grant,BUS_req, BUS_ready,clk);
    //dummy_slave ram0 (clk,{2'b00,BUS_addr[31:2]},BUS_data,BUS_req,BUS_ready,BUS_RW);
    //dummy_slave_mid ram0 (clk,{2'b00,BUS_addr[31:2]},BUS_data,BUS_req,BUS_ready,BUS_RW);
    dummy_slave_fast ram0 (clk,{2'b00,BUS_addr[31:2]},BUS_data,BUS_req,BUS_ready,BUS_RW);
    uart_tx tx_0 (clk_in, {2'b00,BUS_addr[31:2]}, BUS_data,BUS_req,BUS_ready,BUS_RW, TxD, TxD_ready, clk);

    //timer timer0 (clk,{2'b00,BUS_addr[31:2]}, BUS_data,BUS_req,BUS_ready,BUS_RW
    //                //,timer1,timer2,read,selected
    //                );

    always@ (posedge clk)
    begin
        clr <= ~clr_in;
    end

    //add step mode

    reg step_mode_reg , step_reg;
    always @(posedge clk_in) begin
        step_mode_reg <= step_mode;
        step_reg  <= step;
    end


    always @(*)
    begin
        if (step_mode_reg)
            clk = clk_in;
        else
            clk = step_reg;
    end
	 
	 wire [6:0] led0,led1,led2,led3,led4,led5,led6,led7;
	 disp disp0(BUS_addr[3:0],led0);
	 disp disp1(BUS_addr[7:4],led1);
	 disp disp2(BUS_addr[11:8],led2);
	 disp disp3(BUS_addr[15:12],led3);
	 disp disp4(BUS_addr[19:16],led4); 
	 disp disp5(BUS_addr[23:20],led5);
	 disp disp6(BUS_addr[27:24],led6);
	 disp disp7(BUS_addr[31:28],led7);
	 
	 
	 reg[6:0] ledo0,ledo1,ledo2,ledo3,ledo4,ledo5,ledo6,ledo7;
	 
	 
    always @(posedge clk) 
    begin
        ledo0 <=~led0;
        ledo1 <=~led1;
        ledo2 <=~led2;
        ledo3 <=~led3;
        ledo4 <=~led4;
        ledo5 <=~led5;
        ledo6 <=~led6;
        ledo7 <=~led7;
        
    end

endmodule

module disp(
    input  [3:0]x,
    output reg [6:0]z
    );
always @*
case (x)
4'b0000 :      	//Hexadecimal 0
z = 7'b0111111;
4'b0001 :    		//Hexadecimal 1
z = 7'b0000110  ;
4'b0010 :  		// Hexadecimal 2
z = 7'b1011011 ;
4'b0011 : 		// Hexadecimal 3
z = 7'b1001111 ;
4'b0100 :		// Hexadecimal 4
z = 7'b1100110 ;
4'b0101 :		// Hexadecimal 5
z = 7'b1101101 ;
4'b0110 :		// Hexadecimal 6
z = 7'b1111101 ;
4'b0111 :		// Hexadecimal 7
z = 7'b0000111;
4'b1000 :     		 //Hexadecimal 8
z = 7'b1111111;
4'b1001 :    		//Hexadecimal 9
z = 7'b1101111 ;
4'b1010 :  		// Hexadecimal A
z = 7'b1110111 ;
4'b1011 : 		// Hexadecimal B
z = 7'b1111100;
4'b1100 :		// Hexadecimal C
z = 7'b0111001 ;
4'b1101 :		// Hexadecimal D
z = 7'b1011110 ;
4'b1110 :		// Hexadecimal E
z = 7'b1111001 ;
4'b1111 :		// Hexadecimal F
z = 7'b1110001 ;
endcase
 
endmodule