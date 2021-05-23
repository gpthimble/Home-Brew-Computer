//need to be modified when addding interrupt support.
module pipe_if(
  pc_source,pc,condit_bran_pc,j_reg_pc,j_pc,next_pc,pc4
);

    input   [1:0]  pc_source;
    input   [31:0] pc,condit_bran_pc,j_reg_pc,j_pc;
    output  [31:0] next_pc,pc4;
    reg     [31:0] next_pc,pc4;
    //  pc_source       next_pc
    //  00              pc+4(pc4)
    //  01              condit_bran_pc     conditional branch pc
    //  10              j_reg_pc           jump to  register address
    //  11              j_pc               jump to  immediate address 
    always @(*) begin
        pc4=pc+'d4;
      case (pc_source)
        2'b00: next_pc=pc4;
        2'b01: next_pc=condit_bran_pc;
        2'b10: next_pc=j_reg_pc;
        2'b11: next_pc=j_pc; 
        default: $display("Invalid pc_source!");
      endcase
    end

endmodule // pipe_if