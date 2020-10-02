module clo_clz(
  data,one_or_zero,result
);
    input [31:0] data;
    input one_or_zero;
    output reg [31:0] result;
    reg [5:0] result_temp;
    reg [15:0] data_16;
    reg [7:0]  data_8 ;
    reg [3:0]  data_4 ;
    always @(*)
        begin
          if (data=={32{one_or_zero}}) 
            result_temp=6'b100000;
            else
                begin
                  result_temp[5] = 0;
                  result_temp[4] = (data   [31:16] == {16{one_or_zero}});
                  data_16   = result_temp[4] ? data   [15:0] : data  [31:16];
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
          result={24'b0,result_temp};
        end
endmodule // CLO_CLZ