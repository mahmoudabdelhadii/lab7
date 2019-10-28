module datapath (clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,
                  writenum,write,mdata,sximm8,PC,sximm5,status_out,datapath_out); 
	parameter n = 16;
	input loada, loadb, asel, bsel, loadc, loads, clk, write;
	input [n-1:0] mdata, sximm8, sximm5;
	input [2:0] writenum, readnum;
	input [1:0] ALUop, shift;
	input	[3:0] vsel;
	input [7:0] PC;
	output [n-1:0] datapath_out;
	output [2:0] status_out;
	
	wire [n-1:0] data_in, data_out, data_out_A, data_out_B, sout, Ain, Bin, out;
	wire [2:0] status;
	
	//Mux2 #(n) b9wbmux(.a1(sximm8), .a0(datapath_out), .load(vsel[3]), .b(data_in)); // writeback mux
	Mux4 #(n) b9wbmux4in(.a3(mdata), .a2(sximm8), .a1({8'b0, PC}), .a0(datapath_out), .s(vsel), .b(data_in)); //lab6 change for choosing between 4 input signals
	REGFILE  REGFILE(.writenum(writenum), .write(write), .data_in(data_in), .clk(clk), 
	                    .readnum(readnum), .data_out(data_out));                      // register file
	vDFFE #(n) b3vdffeA(.clk(clk), .load(loada), .in(data_out), .out(data_out_A));    // Pipeline Register A
	vDFFE #(n) b4vdffeB(.clk(clk), .load(loadb), .in(data_out), .out(data_out_B));    // Pipeline Register B
	shifter  b8shftU1(.in(data_out_B),.sout(sout),.shift(shift));                     // Shifter Unit
	Mux2 #(n) b6Amux(.a1(16'b0), .a0(data_out_A), .load(asel), .b(Ain));              // Source Operand Mux A
	Mux2 #(n) b7Bmux(.a1(sximm5), .a0(sout), .load(bsel), .b(Bin));                   // Source Operand Mux B
	ALU  b2alu(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .status(status));      // Arithmetic Logic Unit
	vDFFE #(n) b5vdffeC(.clk(clk), .load(loadc), .in(out), .out(datapath_out));       // Pipeline Register C
	vDFFE #(3) b10vdffestat(.clk(clk), .load(loads), .in(status), .out(status_out));  // Status Register 


endmodule

module Muxb4 (a3, a2, a1, a0, sb, b); // not used since vsel is one hot already
	parameter k = 16;
	input [1:0] sb;
	input [k-1:0] a3,a2,a1,a0;
	output[k-1:0] b;
	
	wire [3:0] s;
	
	Dec #(2,4) d(.a(sb),.b(s));
	Mux4 #(k) m(.a3(a3),.a2(a2),.a1(a1),.a0(a0),.s(s),.b(b));
	
endmodule

module Mux4 (a3,a2,a1,a0,s,b);// used to get input signal based on vsel
parameter k = 1;
	input [3:0] s; 
	input [k-1:0] a3,a2,a1,a0;
	output reg [k-1:0] b;
	
	always @(*) begin
		case(s)
			4'b0001: b = a0;
			4'b0010: b = a1;
			4'b0100: b = a2;
			4'b1000: b = a3;
			default: b = {k{1'bx}};
		endcase 
	end
endmodule 


module Muxb8 (a7,a6,a5,a4,a3,a2,a1,a0,sb,b);//used by regfile
	parameter k=16;
   input [2:0] sb; 
	input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
	output [k-1:0] b;
	
	wire [7:0] s;
	
	Dec #(3,8) d(.a(sb),.b(s));
	Mux8 #(k) m(.a7(a7),.a6(a6),.a5(a5),.a4(a4),.a3(a3),.a2(a2),.a1(a1),.a0(a0),.s(s),.b(b));

endmodule
	
module Dec (a,b);
	parameter n = 3, m = 8;
	input [n-1:0] a;
	output [m-1:0] b;

	assign b = 1 << a; //assigns one hot signal ie. 00 -> 0001

endmodule 

module Mux8 (a7,a6,a5,a4,a3,a2,a1,a0,s,b);//used by muxb8
	parameter k = 1;
	input [7:0] s; 
	input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
	output reg [k-1:0] b;
	
	always @(*) begin
		case(s)
			8'b00000001: b = a0;
			8'b00000010: b = a1;
			8'b00000100: b = a2;
			8'b00001000: b = a3;
			8'b00010000: b = a4;
			8'b00100000: b = a5;
			8'b01000000: b = a6;
			8'b10000000: b = a7;
			default: b = {k{1'bx}};
		endcase 
	end
endmodule 




module vDFFE (clk, load, in, out); //to be called for A,B, and C
	parameter n = 1;
	input clk,load;
	input [n-1:0] in; 
	output reg [n-1:0] out;
	wire [n-1:0] next_out;
	
	//Mux2 #(n) abc(.a1(in), .a0(out), .load(load), .b(next_out)); // mux portion
	assign next_out = load ? in : out;

	always @(posedge clk) begin //DFF portion
		out <= next_out; //non blocking good?
	end
endmodule
 
module Mux2 (a1,a0,load,b);//simple mux
	parameter k = 16;
	input [k-1:0] a1, a0;
	input load;
	output [k-1:0] b;

	assign b = load ? a1 : a0 ;
endmodule

module Enc(a,b);//not used
	parameter n = 4, m = 2;
	input [n-1:0] a;
	output [m-1:0] b;

	assign b = {a[3]|a[2], a[3]|a[1]};

endmodule

