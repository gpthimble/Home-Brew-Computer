//FILE:         shifter.v
//DESCRIPTION:  Module for shift operation, this module is total combinational logic.
//                This module also implements the LUI instruction.
//DATA:         2020-10-02
//AUTHOR:       Thimble Liu
//
//INTERFACE:    I/O     NAME        DESCRIPTION
//              input : data        32-bit data input.
//                      sa          5-bit value input for shift amount, expand to 32-bit;
//                      right       direction of shift operation, high for right shift
//                      arith       high for arithmetic shift. 
//                                  Right LOW and arith HIGH is for LUI instruction, just
//                                  left shift 16 bits.
//              output: result      32-bit result output.


module shifter(
  data,sa,right,arith,result
);
    //------------------------- Interface description   -----------------------------
    //32-bit data input.
    input [31:0]data;
    //32-bit input, only lower 5 bits are effective for shift amount.
    input [31: 0]sa;
    //Control signal of this module. Right LOW and arith HIGH is for LUI instruction.
    input right,arith;
    //32-bit result output.
    output reg [31:0] result;

    //--------------------------    Module implementation   -------------------------
    always @(*)
        begin        
          if (!right) begin
          //For left shift.
            //Logical left shift.
            if (!arith) result = data << sa[4:0];
            //shift left 16 bits for LUI instruction.
            else result = data <<16;
          end 
          else begin
          //For right shift.  
            if (arith)  result = $signed(data) >>> sa[4:0];
            else        result = data >> sa[4:0];
          end
        end
endmodule // shifter