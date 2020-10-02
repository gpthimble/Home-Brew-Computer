module pipe_pc(
  next_pc,write_pc,clk,clear,pc_out
);
    input   [31:0] next_pc;
    input          write_pc,clk,clear;
    output  [31:0] pc_out ;
    dffe32 pc0 (next_pc,write_pc,clk,clear,pc_out);
endmodule // pipe_pc