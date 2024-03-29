module cpu_tb;

reg [15:0] read_data;
reg clk, reset;
wire [15:0] write_data;
wire[8:0] mem_addr;
wire [1:0]mem_cmd;
wire N, V, Z;

reg err;
/*

cpu(clk,read_data,mem_cmd,mem_addr,write_data,reset,N,V,Z); //controls all of RISC machine with 16 bits instruction input and reset, s, clk, and load signals
	input clk, reset;
	output reg [1:0] mem_cmd;
	output [15:0] write_data;
	output N, V, Z;
	input [15:0] read_data;
	output[8:0] mem_addr;

*/
cpu DUT(.mem_cmd(mem_cmd),.mem_addr(mem_addr),.clk(clk),.reset(reset),.read_data(read_data),.write_data(write_data),.N(N),.V(V),.Z(Z));



  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

  initial begin



  	//Test 1 : DIFFERENT NUMBERS 
	 //MOV R3, #4 this means, take the absolute number 4 and store it in R3
	
	
   $display("TEST 1");
    err = 0;
    reset = 1; read_data = 16'b0;
    #10;
    reset = 0; 
    #10;

    read_data = 16'b1101001100000100;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing MOV R3 #4");
    $display(" The register R3 contains this: %b", cpu_tb.DUT.DP.REGFILE.R3);

    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'h4) begin
      err = 1;
      $display("FAILED: MOV R3, #4");
    end
    

// MOV R4, #7 this means, take the absolute number 7 and store it in R4

    read_data = 16'b1101010000000111;
     
    #10;
    
    
   
   
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing MOV R4 #7");
     $display(" The register R4 contains this: %b", cpu_tb.DUT.DP.REGFILE.R4);
    if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R4, #7");
      
    end
     
// ADD R5, R3, R4 LSL#1 this means R5 = R3 + (R4 shifted left by 1) = 4+14 = 18



    read_data = 16'b1010001110101100;
   #10
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing ADD R5, R3 R4 LSL#1");
     $display("Actual: out = %b, Z = %1b, N = %1b, V = %1b", write_data, Z, N, V);
     $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b0000000000010010, 1'b0 ,1'b0, 1'b0 );
     if ((write_data == 16'b0000000000010010) & (Z == 1'b0) & (N == 1'b0) & (V == 1'b0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: ADD R5, R3, R4, LSL#1"); 
    end
  


	// CMP R3, R4 LSL#1 this means status = R3 - (R4 Sshifted left by 1) = 4 - 14 = -10


    #10;
 	  read_data = 16'b1010101100001100 ;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing  CMP R3, R4 LSL#1");
    $display("Actual: Z = %b, N = %b, V = %b", Z, N, V);
    $display("Expected:  Z = %b, N = %b, V = %b", 1'b0 ,1'b1, 1'b0 );

  if ((Z == 0) & (N == 1) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: CMP R3, R4, LSL#1");
      
    end


	// AND R7, R3, R4 this means R7 = R3 & R4 LSL = 0000000000000100 & 0000000000001110 = 000000000000100

  #10;
	read_data = 16'b1011001111101100;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
 $display("Testing  AND R7, R3, R4 LSL#1");
  $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b000000000000100, 1'b0 ,1'b0, 1'b0 );
  
  if ((write_data == 16'b000000000000100) & (Z == 0) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: AND R7, R3, R4 LSL#1 ");
      
    end
  


	// MVN R6, R4 , this means ~R4 = 1111111111111000

#10;
read_data = 16'b1011100011000100;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing  MVN R6, R4 ");
     $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b1111111111111000, 1'b0,1'b1, 1'b0 );
  
  if ((write_data == 16'b1111111111111000) & (Z == 0) & (N == 1) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: MVN R6, R4");

    end
    



// TEST 2 : EQUAL NUMBERS

// MOV R3 #3
$display("TEST 2");

read_data = 16'b1101001100000011;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing  MOV R3, #3 ");
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'h3) begin
      err = 1;

      $display("FAILED: MOV R3, #3");
    end
    $display(" The register R3 contains this: %b", cpu_tb.DUT.DP.REGFILE.R3);

//MOV R4 #3

    read_data = 16'b1101010000000011;
    #10;
    @(posedge clk); // wait for w to go high again
   
    #10;
     $display("Testing  MOV R4, #3 ");
     $display(" The register R4 contains this: %b", cpu_tb.DUT.DP.REGFILE.R4);
    if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'h3) begin
      err = 1;
      $display("FAILED: MOV R4, #3");
    
    end
    
     
//ADD R5, R3, R4


    read_data = 16'b1010001110100100;
    #10;
    @(posedge clk); // wait for w to go high again
   
    #10;
     $display("Testing  ADD R5, R3, R4 ");
    $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'h6, 1'b0 ,1'b0, 1'b0 );
    if ((write_data == 16'h6) & (Z == 0) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: ADD R5, R3, R4");
      
    end
  

  


// CMP R3, R4


read_data = 16'b1010101100000100;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing  CMP R3, R4 ");
    $display("Actual:  Z = %b, N = %b, V = %b", Z, N, V);
  $display("Expected:   Z = %b, N = %b, V = %b", 1'b1 ,1'b0, 1'b0 );
if ((Z == 1) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: CMP R3, R4");
      
    end
    

  



// AND R0, R3, R4 


read_data = 16'b1011001100000100;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing  AND R0, R3, R4 ");
     $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'h3, 1'b0 ,1'b0, 1'b0 );
if ((write_data == 16'h3) & (Z == 0) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: AND R0, R3, R4");
      
    end

  

// MVN R1, R3



read_data = 16'b1011100000100011;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing  MVN R1, R3 ");
      $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b1111111111111100, 1'b0 ,1'b1, 1'b0 );
if ((write_data == 16'b1111111111111100) & (Z == 0) & (N == 1) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: MVN R1, R3");   
    end


 



// TEST 3 : ALL 1s

// MOV R1 #170
$display("TEST 3");

read_data = 16'b1101000111111111;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing  MOV R1, #170 ");
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b1111111111111111) begin
      err = 1;

      $display("FAILED: MOV R1, #170");
    end
    $display(" The register R3 contains this: %b", cpu_tb.DUT.DP.REGFILE.R1);

//MOV R2, R1 LSL#1

    read_data = 16'b1100000001000001;
    #10;
    @(posedge clk); // wait for w to go high again
   
    #10;
     $display("Testing  MOV R2, R1  ");
     $display(" The register R4 contains this: %b", cpu_tb.DUT.DP.REGFILE.R2);
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b1111111111111111) begin
      err = 1;
      $display("FAILED: MOV R2, R1 ");
    
    end
    
     
//ADD R3, R2, R1


    read_data = 16'b1010000101100010;
    #10;
    @(posedge clk); // wait for w to go high again
   
    #10;
     $display("Testing  ADD R3, R2, R1 ");
    $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b1111111111111110, 1'b0 ,1'b1, 1'b0 );
    if ((write_data == 16'b1111111111111110) & (Z == 0) & (N == 1) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: ADD R3, R2, R1");
      
    end
  

  


// CMP R1, R2


read_data = 16'b1010100100000010;
   #10;
    @(posedge clk); // wait for w to go high again
    #10;
    $display("Testing  CMP R1, R2 ");
    $display("Actual:  Z = %b, N = %b, V = %b", Z, N, V);
  $display("Expected:   Z = %b, N = %b, V = %b", 1'b1 ,1'b0, 1'b0 );
if ((Z == 1) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: CMP R1, R2");
      
    end
    

  



// AND R4, R1, R2 


read_data = 16'b1011000110000010;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing  AND R4, R1, R2 ");
     $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b1111111111111111, 1'b0 ,1'b1, 1'b0 );
if ((write_data == 16'b1111111111111111) & (Z == 0) & (N == 1) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: AND R4, R1, R2");
      
    end

  

// MVN R5, R1



read_data = 16'b1011100010100001;
    #10;
    @(posedge clk); // wait for w to go high again
    #10;
     $display("Testing  MVN R1, R3 ");
      $display("Actual: out = %b, Z = %b, N = %b, V = %b", write_data, Z, N, V);
  $display("Expected:  out = %b, Z = %b, N = %b, V = %b", 16'b0, 1'b1 ,1'b0, 1'b0 );
if ((write_data == 16'b0) & (Z == 1) & (N == 0) & (V ==0)) begin
    $display("The output is correct");
    end else begin
      err = 1;
      $display("FAILED: MVN R5, R1");   
    end


if(err!==1) 
$display("All tests are correct");
if(err == 1)
$display("ERROR: some tests are incorrect");


$stop;


  end


  endmodule


 	









