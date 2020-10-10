//FILE:               regfile.v
//DESCRIPTION:        This file implements the register file. There are 32 registers
//                    in the system. Register 0 is always 0. Register file has two
//                    read agents and one write agent. Clear signal should be 
//                    synchronized. Data is always ready in one clock cycle.
//
//DATA:               2020-10-10
//AUTHOR:             Thimble Liu
//
//INTERFACE:          I/O     NAME          DESCRIPTION
//                    input:  r_number_a    5-bit width register address for read 
//                                          agent A
//                            r_number_b    5-bit width register address for read
//                                          agent B
//                            w_number      5-bit width register address for write
//                                          agent
//                            data_in       32-bit data input for write agent
//                            w_en          control for write enable, effective when
//                                          w_en = HIGH
//                            clr           synchronized clear signal, reset when 
//                                          clr = HIGH
//                            clk           clock input
//                    output: data_out_a    32-bit data output for read agent A
//                            data_out_b    32-bit data output for read agent B
//                            
//


module regfile(
  r_number_a,r_number_b,data_out_a,data_out_b,
  w_number,data_in,w_en,clk,clr
);
    //------------------------- Interface description  -----------------------------
    //5-bit register address for read agent A,B and write agent.
    input  [4:0] r_number_a,r_number_b,w_number;

    //32-bit data input for write agent.
    input [31:0] data_in;

    //w_en is control signal for write enable, effective when w_en = HIGH.
    //clk is the clock input.
    //clr is synchronized clear signal, effective when clr = HIGH.
    input        w_en,clk,clr;

    //32-bit data output for read agent A and B.
    output[31:0] data_out_a,data_out_b;

    //--------------------------    Module implementation  -------------------------
    reg   [31:0] register [1:31];

    //Register 0 is always 0. Implemented by compare the address with zero.
    assign data_out_a = (r_number_a==0) ? 0 : register[r_number_a];
    assign data_out_b = (r_number_b==0) ? 0 : register[r_number_b];

    always @(posedge clk)
    begin

    //clear signal is synchronized and effective when HIGH.
      if (clr== 1) begin

        //clear is implemented by for loop.
        integer i;
        for (i = 1; i<32; i=i+1)
          register[i]<=0;
    
    //when w_en is HIGH, write value in the register selected by address of write agent.
      end else if (w_number!=0 && w_en)
        register[w_number] <= data_in;
    end
endmodule // regfile