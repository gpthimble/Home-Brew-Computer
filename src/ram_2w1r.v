//2w1r implements a memory with 2 write prots and 1 read port.
//It is used for the valid bit in caches, and it will be inferred
//as block-ram in FPGA instead of registers.
//This module is an implementation of the paper "Multi-Ported memories
// for FPGAs via XOR", use the propertis of XOR to implemet the true
//dual port memory with sigle port block rams in FPGAS.
//I hope this tech will decrea the resources ocuppied and improve
//the overall performance of the cache.

module ram_2w1r (
    W_addr_A, W_addr_B, R_addr_A,
    W_data_A, W_data_B, R_data_A,
    W_en_A,   W_en_B,   R_en_A,
    clk
  );
  //Data width in memory bits
  parameter WIDTH = 1;
  //address width; how many words stored in this memroy
  parameter DEEPTH = 12;

  input [WIDTH-1 : 0] W_data_A, W_data_B;
  output [WIDTH-1 : 0] R_data_A;
  input [DEEPTH-1 : 0] W_addr_A, W_addr_B, R_addr_A;
  input W_en_A, W_en_B, R_en_A;
  input clk;

  //To implemnet a two write ports and one read port ram using XOR,
  //we need four identical memories work in the following pattern:
  /*
          mA1             mA2
   
          mB1             mB2
  */
  //If there's a write operation which store value X into address A, through port 1
  //it will read address A from mB1 first to get value of "old X",
  //then the value of X XOR "old X" will be stored at the address A of
  //mA1 and mA2.
  //If there's a write operation which sotre value Y into address B, trough port 2
  //it will read address B from mA1 first to get value of "old Y",
  //then the value of Y XOR "old Y" will be stored at the address B of
  //mB1 and mB2.
  //If there's a read operation at address C ,the output value is the xor of the
  //read out of mA2 and mB2.
  //Block rams for mXXs are all with one read port and one write port.
  localparam cache_lines  = 2<< (DEEPTH -1);
  reg [WIDTH-1 :0] mA1 [0: cache_lines -1];
  reg [WIDTH-1 :0] mA2 [0: cache_lines -1];
  reg [WIDTH-1 :0] mB1 [0: cache_lines -1];
  reg [WIDTH-1 :0] mB2 [0: cache_lines -1];

  //since every write operation need reading as well, we need to registed
  //the write request, data and address and add some forwarding circuitry,
  //ensure that from the view out of this module the write complete in one
  //clock cycle.
  reg [WIDTH-1 : 0] W_data_A_R, W_data_B_R, R_data_A_R;
  reg [DEEPTH-1 :0] W_addr_A_R, W_addr_B_R, R_addr_A_R;
  reg W_en_A_R, W_en_B_R, R_en_A_R;

  //these registers are for read after write forwarding
  reg [WIDTH-1 : 0] W_data_A_R2,W_data_B_R2;
  reg [DEEPTH-1 :0] W_addr_A_R2,W_addr_B_R2;
  reg W_en_B_R2,W_en_A_R2;
  //If two write ports write to the same address, request on port B will be
  //ignored.
  wire ignored_W_B = W_addr_A == W_addr_B & W_en_B;

  //update these registers when each port is enabled.
  always @(posedge clk)
  begin
    if (W_en_A)
    begin
      W_data_A_R <= W_data_A;
      W_addr_A_R <= W_addr_A;
      W_en_A_R   <= 1;
    end
    else
      W_en_A_R   <= 0;

    if (W_en_B & ~ignored_W_B)
    begin
      W_data_B_R <= W_data_B;
      W_addr_B_R <= W_addr_B;
      W_en_B_R   <= 1;
    end
    else
      W_en_B_R   <= 0;
    if (R_en_A)
    begin
      R_data_A_R <= R_data_A;
      R_addr_A_R <= R_addr_A;
      R_en_A_R   <= 1;
    end
    else
      R_en_A_R   <= 0;

    //second stage of registers used for read after write forwarding
    W_data_A_R2 <= W_data_A_R;
    W_addr_A_R2 <= W_addr_A_R;
    W_en_A_R2   <= W_en_A_R;

    W_data_B_R2 <= W_data_B_R;
    W_addr_B_R2 <= W_addr_B_R;
    W_en_B_R2   <= W_en_B_R;
  end

  //These registers store the data read from block rams.
  reg [WIDTH-1:0] R_data_reg_A1, R_data_reg_A2,
      R_data_reg_B1, R_data_reg_B2;

  //data forwarding for write logic
  wire  [WIDTH-1:0] old_A, old_B, new_A, new_B;
  //If there are 2 continuous write request through different
  //port at the same address, the old value should be forwarded
  //since this value has not been written into the memory.
  assign old_A = (W_en_A & W_addr_A == W_addr_B_R & W_en_B_R)?
         W_data_B_R : R_data_reg_B1;
  assign old_B = (W_en_B & W_addr_B == W_addr_A_R & W_en_A_R)?
         W_data_A_R : R_data_reg_A1;
  assign new_A = old_A ^ W_data_A_R;
  assign new_B = old_B ^ W_data_B_R;

  //since the write request needs two cycle to complete, we need to
  //save the value of the requst for data forwarding (see bellow 
  //situation 2)
  reg [WIDTH -1:0] new_A_R, new_B_R;
  always @(posedge clk) begin
    new_A_R <= new_A;
    new_B_R <= new_B;
  end


  //data forwarding for read logic
  reg [WIDTH-1:0] read_A, read_B;

  //data forwarding for read logic has two situations:
  //1. read request and write request happen at the same time
  // and both request to the same address. This is because our
  // cache neet to get the new value when read and write happen
  // at the same time. 
  //2. read request happens after the write request to the same
  //address.  this is because the write request needs 2 cycles to
  //complete. 
  //We also need to consider the priority of this two situations
  //because we always want to get the new value when read and write
  //at the sametime, situation one has higher priority, since the 
  //value is newer.  
  always @(*) begin
    //situation 1 for mA2
    if (R_addr_A_R == W_addr_A_R & W_en_A_R) begin
      //get the value which will be stored at the next clock posedge
      read_A = new_A;
    end
    //situation 2 for mA2
    else if (R_addr_A_R == W_addr_A_R2 & W_en_A_R2) begin
      read_A = new_A_R;
    end
    //nomal situation for mA2
    else
      //get the value from mA2
      read_A = R_data_reg_A2;
  end

  always @(*) begin
    //situation 1 for mB2
    if (R_addr_A_R == W_addr_B_R & W_en_B_R) begin
      //get the value which will be stored at the next clock posedge
      read_B = new_B;
    end
    //situation 2 for mB2
    else if (R_addr_A_R == W_addr_B_R2 & W_en_B_R2) begin
      read_B = new_B_R;
    end
    //nomal situation for mA2
    else
      //get the value from mA2
      read_B = R_data_reg_B2;
  end

  //assign read_A = (R_addr_A_R == W_addr_A_R & W_en_A_R)?
  //       new_A : R_data_reg_A2;
  //assign read_B = (R_addr_A_R == W_addr_B_R & W_en_B_R)?
  //       new_B : R_data_reg_B2;

  //output read data.
  assign R_data_A = read_A ^ read_B;


  always @(posedge clk)
  begin

    //for write requests
    //If there's a write request on write port A
    //need to read from mB1 first
    if (W_en_A)
      R_data_reg_B1 <= mB1 [W_addr_A];

    //If there's a write request on write port B
    //need to read from mA1 first
    if (W_en_B)
      R_data_reg_A1 <= mA1 [W_addr_B];

    //If there's a registed write request on write portA
    //the old value of requested address has been already
    //read from mB1 into R_data_reg_B1.
    //Finish the write request at this posedge of clk
    //mA1 and mA2 need to be update both.
    if (W_en_A_R)
    begin
      mA1 [W_addr_A_R] <= new_A;
      mA2 [W_addr_A_R] <= new_A;
    end

    //If there's a registed write request on write portB
    //the old value of requested address has been already
    //read from mA1 into R_data_reg_A1.
    //Finish the write request at this posedge of clk
    //mB1 and mB2 need to be update both.
    if (W_en_B_R)
    begin
      mB1 [W_addr_B_R] <= new_B;
      mB2 [W_addr_B_R] <= new_B;
    end

    //for read requests
    if (R_en_A)
    begin
      R_data_reg_A2 <= mA2[R_addr_A];
      R_data_reg_B2 <= mB2[R_addr_A];
    end
  end

endmodule

