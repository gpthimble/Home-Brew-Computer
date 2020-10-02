module dffe32(
  data_in,write_enable,clk,clrn,q_out
);
    input   [31:0] data_in;
    output  [31:0] q_out;
    input   clk,clrn,write_enable;
    reg     [31:0] q_out;
    always @ (negedge clrn or posedge clk)
        if (clrn==0) begin
          q_out <= 0 ;
        end
        else begin
          if (write_enable) q_out <= data_in ;
        end
endmodule // dffe32