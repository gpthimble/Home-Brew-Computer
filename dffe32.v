//FILE:         dffe32.v
//DESCRIPTION:  Module for a 32-bit register with synchronized clr.
//
//DATE:         2020-10-10
//AUTHOR:       Thimble Liu
//
//INTERFACE:    I/O     NAME          DESCRIPTION
//              input:  data_in       32-bit data input
//                      write_enable  pin control write
//                      clr           synchronized clear
//                      clk           clock input, positive edge trigger
//              output: q_out         32-bit data output


module dffe32(
  data_in,write_enable,clk,clr,q_out
);

    //------------------------- Interface description  -----------------------------
    //32-bit data input
    input   [31:0] data_in;
    //32-bit data output
    output  [31:0] q_out;
    //clk is posedge triggered clock, clr is synchronized clear signal,
    //write is enabled when write_enable is one.
    input   clk,clr,write_enable;
    reg     [31:0] q_out;

    //--------------------------    Module implementation  -------------------------
    //clock is posedge triggered.    
    always @ (posedge clk)
    //synchronized clear signal.
        if (clr==1) begin
          q_out <= 0 ;
        end
        else begin
    //write enable if write_enable is high.
          if (write_enable) q_out <= data_in ;
        end
endmodule // dffe32