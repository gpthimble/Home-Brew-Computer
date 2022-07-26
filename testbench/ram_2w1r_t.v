//This file describes the testbench of ram_2w1r.v

`timescale 1ns /10ps

module ram_2w1r_t;

//implement clk
reg clk;
initial 
    clk = 0;
always 
    #10 clk =~ clk;


parameter DEEPTH = 8;
parameter WIDTH = 8;
localparam lines = 2<<(DEEPTH -1);
wire [WIDTH-1:0] read_data;

reg [DEEPTH-1 :0] write_addr_A, write_addr_B, read_addr;
reg [WIDTH-1  :0] write_data_A, write_data_B          ;
reg               write_EN_A,   write_EN_B  , read_EN ;   


ram_2w1r      #(.WIDTH(WIDTH), .DEEPTH(DEEPTH))
              ram (write_addr_A, write_addr_B, read_addr,
              write_data_A, write_data_B, read_data,         
              write_EN_A,   write_EN_B , read_EN, 
             clk                                    );


reg test_result = 0;

task write_A_and_read_1;
begin
//test 1: read from and write to the same location at the
//sametime. 
//Should always return new value. 
//This procedure takes one clock cycle. 
  read_EN =1;
  write_addr_A = $random;
  write_data_A = $random ;
  write_EN_A = 1;
  read_addr = write_addr_A;
  //the value has been read;
  #12 if (read_data == write_data_A) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  #1 write_EN_A = 0;
     read_EN =0;
  #7;
end
endtask

task write_A_and_read_2;
begin
//test 2: read from the same location 1 clock after write
//This test is nessecery because write operation need two clock
//cycle to complete. 
//Should always return new value. 
//This procedure takes two clock cycle. 
  //first cycle. 
  
  write_addr_A = $random;
  write_data_A = $random ;
  write_EN_A = 1;
  
  //finish the write. 
  #12 write_EN_A = 0;
  //second cycle. 
  read_EN =1;
  read_addr = write_addr_A;
  //the value has been read;
  #20 if (read_data == write_data_A) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  //finish the read
  #1 read_EN = 0;
  #7;
end
endtask

task write_A_and_read_3;
begin
//test 3: read from the same location 2 clock after write
//This test is nessecery because write operation need two clock
//cycle to complete. 
//Should always return new value. 
//This procedure takes three clock cycle. 
  //first cycle. 
  
  write_addr_A = $random;
  write_data_A = $random ;
  write_EN_A = 1;
  
  //finish the write. 
  #12 write_EN_A = 0;
  #8;
  //second cycle. 
  #22 read_EN =1;
  read_addr = write_addr_A;
  //the value has been read;
  #10 if (read_data == write_data_A) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  //finish the read
  #1 read_EN = 0;
  #7;
end
endtask

task write_B_and_read_1;
begin
//test 1: read from and write to the same location at the
//sametime. 
//Should always return new value. 
//This procedure takes one clock cycle. 
  read_EN =1;
  write_addr_B = $random;
  write_data_B = $random ;
  write_EN_B = 1;
  read_addr = write_addr_B;
  //the value has been read;
  #12 if (read_data == write_data_B) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  #1 write_EN_B = 0;
     read_EN =0;
  #7;
end
endtask

task write_B_and_read_2;
begin
//test 2: read from the same location 1 clock after write
//This test is nessecery because write operation need two clock
//cycle to complete. 
//Should always return new value. 
//This procedure takes two clock cycle. 
  //first cycle. 
  
  write_addr_B = $random;
  write_data_B = $random ;
  write_EN_B = 1;
  
  //finish the write. 
  #12 write_EN_B = 0;
  //second cycle. 
  read_EN =1;
  read_addr = write_addr_B;
  //the value has been read;
  #20 if (read_data == write_data_B) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  //finish the read
  #1 read_EN = 0;
  #7;
end
endtask

task write_B_and_read_3;
begin
//test 3: read from the same location 2 clock after write
//This test is nessecery because write operation need two clock
//cycle to complete. 
//Should always return new value. 
//This procedure takes three clock cycle. 
  //first cycle. 
  
  write_addr_B = $random;
  write_data_B = $random ;
  write_EN_B = 1;
  
  //finish the write. 
  #12 write_EN_B = 0;
  #8;
  //second cycle. 
  #22 read_EN =1;
  read_addr = write_addr_B;
  //the value has been read;
  #10 if (read_data == write_data_B) $display("Okay!");
  else begin $display("Not okay!"); test_result=1;end
  //finish the read
  #1 read_EN = 0;
  #7;
end
endtask

task multiple_write_test_1;
//test 1: if port A and B write to the same address, ignore B. 
begin
    //first cycle. 
    //port A and B request to the same address with different
    //data. 
    read_EN =1;
    write_addr_A = $random;
    write_data_A = $random ;
    write_EN_A = 1;
    write_addr_B = write_addr_A;
    write_data_B = $random ;
    write_EN_B = 1;
    //first read. 
    read_addr = write_addr_A;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    //finish the write request. 
    #1 write_EN_A = 0;
    write_EN_B = 0;
    read_EN =0;
    #7;
    //second cycle. 
    //second read. 
    read_EN =1;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //third cycle. 
    //third read. 
    read_EN =1;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
end
endtask

task multiple_write_test_2_A;
//port A and B write to different location at the same time. 
//read address A after write. 
begin
    //first cycle. 
    //port A and B request to differnent addresses with different
    //data. 
    read_EN =1;
    write_addr_A = $random;
    write_data_A = $random ;
    write_EN_A = 1;
    write_addr_B = $random;
    write_data_B = $random ;
    write_EN_B = 1;
    //first read of address A.
    read_addr = write_addr_A;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    //finish the write request. 
    #1 write_EN_A = 0;
    write_EN_B = 0;
    read_EN =0;
    #7;
    //second cycle. 
    //second read. 
    read_EN =1;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //third cycle. 
    //third read. 
    read_EN =1;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. 
    //fourth read. read address B. 
    read_EN =1;
    read_addr = write_addr_B;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;    
end 
endtask

task multiple_write_test_2_B;
//port A and B write to different location at the same time. 
//read address B after write. 
begin
    //first cycle. 
    //port A and B request to differnent addresses with different
    //data. 
    read_EN =1;
    write_addr_A = $random;
    write_data_A = $random ;
    write_EN_A = 1;
    write_addr_B = $random;
    write_data_B = $random ;
    write_EN_B = 1;
    //first read of address B.
    read_addr = write_addr_B;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    //finish the write request. 
    #1 write_EN_A = 0;
    write_EN_B = 0;
    read_EN =0;
    #7;
    //second cycle. 
    //second read. 
    read_EN =1;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //third cycle. 
    //third read. 
    read_EN =1;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. 
    //fourth read. read address A. 
    read_EN =1;
    read_addr = write_addr_A;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;    
end 
endtask

task multiple_write_test_3_A;
//test 3: continuous writing to a same location via different port. 
//need this test because there's a data forwarding path for
//this situation. 
begin
    //first cycle. write through port A and read. 
    read_EN =1;
    write_addr_A = $random;
    write_data_A = $random;
    write_EN_A = 1;
    read_addr = write_addr_A;
    write_EN_B = 0;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_A = 0;
    read_EN =0;
    #7;
    //second cycle. write through port B and read at the same
    //location. 
    read_EN =1;
    write_addr_B =write_addr_A;
    write_data_B = $random;
    write_EN_B = 1;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_B = 0;
    read_EN =0;
    #7;
    //third cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    
end
endtask

task multiple_write_test_3_B;
//test 3: continuous writing to a same location via different port. 
//need this test because there's a data forwarding path for
//this situation. 
begin
    //first cycle. write through port B and read. 
    read_EN =1;
    write_addr_B = $random;
    write_data_B = $random;
    write_EN_B = 1;
    read_addr = write_addr_B;
    write_EN_A = 0;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_B = 0;
    read_EN =0;
    #7;
    //second cycle. write through port A and read at the same
    //location. 
    read_EN =1;
    write_addr_A =write_addr_B;
    write_data_A = $random;
    write_EN_A = 1;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_A = 0;
    read_EN =0;
    #7;
    //third cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;  
end
endtask

task multiple_write_test_4_A;
//test 4:continuous writing to a same location with same port
begin
    //first cycle. write through port A and read. 
    read_EN =1;
    write_addr_A = $random;
    write_data_A = $random;
    write_EN_A = 1;
    read_addr = write_addr_A;
    write_EN_B = 0;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_A = 0;
    read_EN =0;
    #7;
    //second cycle. write through port A and read. 
    read_EN =1;
    write_addr_A = write_addr_A;
    write_data_A = $random;
    write_EN_A = 1;
    read_addr = write_addr_A;
    write_EN_B = 0;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_A = 0;
    read_EN =0;
    #7;
    //third cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_A) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7; 
end
endtask

task multiple_write_test_4_B;
//test 4:continuous writing to a same location with same port
begin
    //first cycle. write through port B and read. 
    read_EN =1;
    write_addr_B = $random;
    write_data_B = $random;
    write_EN_B = 1;
    read_addr = write_addr_B;
    write_EN_A = 0;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_B = 0;
    read_EN =0;
    #7;
    //second cycle. write through port A and read. 
    read_EN =1;
    write_addr_B = write_addr_B;
    write_data_B = $random;
    write_EN_B = 1;
    read_addr = write_addr_B;
    write_EN_A = 0;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 write_EN_B = 0;
    read_EN =0;
    #7;
    //third cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7;
    //fourth cycle. check if the write complete. 
    read_EN =1;
    //the value has been read;
    #12 if (read_data == write_data_B) $display("Okay!");
    else begin $display("Not okay!"); test_result=1;end
    #1 read_EN =0;
    #7; 
end
endtask

initial
begin
    //$monitor("time = %d , data = %h , clk = %d, writeEN_A = %d,writeEN_B = %d, write_addr = %h, write_data_A= %h, write_data_B = %h"
    //, $time,read_data,clk, write_EN_A,write_EN_B , write_addr_A,write_data_A,write_data_B);
    $display("Testing sigle write:");
    $display("test 1: read from and write to the same location at the same time. ");
    write_A_and_read_1;
    write_B_and_read_1;
    $display("test 2: read from the same location 1 clock after write ");
    write_A_and_read_2;
    write_B_and_read_2;
    $display("test 3: read from the same location 2 clock after write");
    write_A_and_read_3;
    write_B_and_read_3;
    $display("testing multiple write:");
    $display("test 1: if port A and B write to the same address, ignore B. ");
    multiple_write_test_1;
    $display("test 2: port A and B write to different location at the same time. ");
    multiple_write_test_2_A;
    multiple_write_test_2_B;
    $display("test 3: continuous writing to a same location via different port.");
    multiple_write_test_3_A;
    multiple_write_test_3_B;
    $display("test 4:continuous writing to a same location with same port");
    multiple_write_test_4_A;
    multiple_write_test_4_B;

    if (test_result == 0) begin
        $display("ram_2w1r has passed all the tests!");
    end
    else    $display("FAILED");
    $finish;
end




endmodule

