module regfile(
  r_number_a,r_number_b,data_out_a,data_out_b,
  w_number,data_in,w_en,clk,clrn
);
    input  [4:0] r_number_a,r_number_b,w_number;
    input [31:0] data_in;
    input        w_en,clk,clrn;
    output[31:0] data_out_a,data_out_b;
    reg   [31:0] register [1:31];
    assign data_out_a = (r_number_a==0) ? 0 : register[r_number_a];
    assign data_out_b = (r_number_b==0) ? 0 : register[r_number_b];

    always @(posedge clk or negedge clrn)
    begin
      if (clrn==0) begin
        integer i;
        for (i = 1; i<32; i=i+1)
          register[i]<=0;
      end else if (w_number!=0 && w_en)
        register[w_number] <= data_in;
    end
endmodule // regfile