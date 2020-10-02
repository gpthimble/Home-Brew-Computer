module pipe_ir(
  pc4,instruct_in,write_ir,clk,clrn,d_pc4,instruct_out
);
    input   [31:0] pc4,instruct_in;
    input          write_ir,clk,clrn;
    output  [31:0] d_pc4,instruct_out;
    dffe32 pc_plus4 (pc4,write_ir,clk,clrn,d_pc4);
    dffe32 instruction (instruct_in,write_ir,clk,clrn,instruct_out);
endmodule // pipe_ir