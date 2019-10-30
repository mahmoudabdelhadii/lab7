module datapath_tb;


	
reg [15:0] in;
reg clk, reset, s, load;
wire [15:0] out;
wire N, V, Z;

reg err;


//Using our CPU to test datapath

cpu DUT(.clk(clk),.reset(reset),.s(s),.load(load),.in(in),.out(out),.N(N),.V(V),.Z(Z),.w(w));

initial begin 
	clk = 1; #5;
	forever begin
		clk = 0; #5;
		clk = 1; #5;
	end
	end 


	initial begin

	err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;

    in = 16'b1101001100000100;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;


in = 16'b1101010000000111;
    load = 1;
     
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;

in = 16'b1010001110101100;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
//Doing an ADD operation to check both the mux, and the status register


$display("Testing the mux4 after we did an ADD operation with 4 + 7 shiffted to the left");
$display("The mux should have as inputs mdata, sximm8 (in this case the immediate 8 bit input that is sign extended), pc and C (18 =(14+4)). 
Vsel should be one-hot 0 and the output 18.");
 $display("%b", datapath_tb.DUT.DP.b9wbmux4in.b );

if(datapath_tb.DUT.DP.b9wbmux4in.b  == 18) begin
	$display("Correct output");
end else begin
	err = 1;
end



$display("Testing the mux 2");
$display("The mux2 should take as input B with the optional shift, in this case 14 (7 shifted to the left) and sximm5. The select is 0");
$display("%b", datapath_tb.DUT.DP.b7Bmux.a0);

if(datapath_tb.DUT.DP.b7Bmux.a0 == 14) begin
$display("Correct output");
end else begin
	err = 1;
end

$display("Testing the the status register");
$display("It should output 3 bit 0");
$display("%b", datapath_tb.DUT.DP.b10vdffestat.out);

if(datapath_tb.DUT.DP.b10vdffestat.out == 3'b0) begin
	$display("Correct output");
end else begin
	err = 1;
end


#10;
 	  in = 16'b1010101100001100 ;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;

$display("Testing the the status register in a CMP operation");
$display("It should output 010");
$display("%b", datapath_tb.DUT.DP.b10vdffestat.out);
if(datapath_tb.DUT.DP.b10vdffestat.out == 3'b010) begin
	$display("Correct output");
end else begin
	err = 1;
end



in = 16'b1101010000000011;
    load = 1;
     
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
   
    #10;



in = 16'b1010001110100100;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
   
    #10;

// Checking for another ADD

$display("Testing the mux 2 for another ADD ");
$display("The mux2 should take as input B with the optional shift, in this case 3 and sximm5. The select is 0");
$display("%b", datapath_tb.DUT.DP.b7Bmux.a0);

if(datapath_tb.DUT.DP.b7Bmux.a0 == 3) begin
$display("Correct output");
end else begin
	err = 1;
end

$display("Testing the the status register for another ADD");
$display("It should output 3 bit 0");
$display("%b", datapath_tb.DUT.DP.b10vdffestat.out);

if(datapath_tb.DUT.DP.b10vdffestat.out == 3'b000) begin
	$display("Correct output");
end else begin
	err = 1;
end



if(err == 1) 
$display ("ERROR: Some tests are wrong");
if(err == 0)
$display("The tests are corretct");


$stop;
end

endmodule 