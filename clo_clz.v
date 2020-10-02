//FILE:         clo_clz.v
//DESCRIPTION:  Module for CLO (Count Leading Ones) and COZ (Count Leading Zeros).
//              This module is total combinational logic.
//              Examples: input   data: 1111 0001 0000 0000 0000 0000 0000 0000 
//                                one_or_zero: 1 (CLO Count Leading Ones)
//                        output   4 in decimal for there're 4 ones leading. 
//DATA:         2020-10-02
//AUTHOR:       Thimble Liu
//
//INTERFACE:    I/O     NAME        DESCRIPTION
//              input : data        (32-bit)
//                      one_or_zero (high for CLO, low for CLZ)
//              output: result      (32-bit)


module clo_clz(
  data,one_or_zero,result
);
    //------------------------- Interface description   -----------------------------
    //This is the 32-bit data input.
    input [31:0] data;
    //This pin control CLO or CLZ.
    input one_or_zero;
    //This is the 32-bit result output. Defined as reg for "=" operator.
    output reg [31:0] result;

    //--------------------------    Module implementation   -------------------------
    //Input is 32-bit long, so the maximum of result is 32 in decimal, 6'b100000.
    reg [5:0] result_temp;

    reg [15:0] data_16;
    reg [7:0]  data_8 ;
    reg [3:0]  data_4 ;
    //The implementation here use a simple idea, from right to left fill the bit of 
    //  result[5:0].
    always @(*)
        begin

          // If all bits of data is one or zero, then the highest bit of result should
          // be high, the result is 32 in decimal (maximum).
          if (data=={32{one_or_zero}}) 
            result_temp=6'b100000;
            else
                begin

                //If previous condition is not met, result[5] should be zero, and
                //  then setting result[4] accordingly. 
                  result_temp[5] = 0;
                
                //If result is from 16 to 31, result[4] should be one. It is obvious
                //  that in this case, data [31:16] should be all ones or zeros, and
                //  the difference between previous case is at the lower 16-bit of 
                //  data.
                  result_temp[4] = (data   [31:16] == {16{one_or_zero}});

                //If result[4] == 1, then the lower 16-bit of data should be checked
                //  to determine lower bit of result.
                //Otherwise, result can be obtain from upper 16-bit of data, and lower
                //  16-bit of data is just abandoned.
                  data_16   = result_temp[4] ? data   [15:0] : data  [31:16];
                
                //The procedure described above keep going, till reach the last bit of
                //  result.
                  result_temp[3] = (data_16[15:8]  == {8 {one_or_zero}});
                  data_8    = result_temp[3] ? data_16[7:0] : data_16[15:8];
                  result_temp[2] = (data_8 [7:4]   == {4 {one_or_zero}});
                  data_4    = result_temp[2] ? data_8 [3:0] : data_8 [7:4];
                  result_temp[1] = (data_4[3:2]    == {2 {one_or_zero}});
                  if (one_or_zero)                 
                    result_temp[0] = result_temp[1] ? data_4[1] : data_4[3];
                    else
                    result_temp[0] = result_temp[1] ?~data_4[1] :~data_4[3];

                end
          //Expand result to 32-bit to fit output of ALU.
          result={24'b0,result_temp};
        end
endmodule // CLO_CLZ