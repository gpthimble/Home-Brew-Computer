module shifter(
  data,sa,right,arith,result
);
    input [31:0]data;
    input [31: 0]sa;
    input right,arith;
    output reg [31:0] result;
    always @(*)
        begin
          if (!right) begin
            if (!arith) result = data << sa[4:0];
            else result = data <<16;
          end 
          else begin
            if (arith)  result = $signed(data) >>> sa[4:0];
            else        result = data >> sa[4:0];
          end
        end
endmodule // shifter