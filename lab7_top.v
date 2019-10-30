`define MNONE 2'b00 //do not read or write
`define MWRITE 2'b01 // write to memory(can change)
`define MREAD  2'b11 // read from memory(can change)


module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

wire [15:0] dout;


wire N,V,Z;

//WIRES FOR CIRCUITS
wire addr, cmd, in_out; 
wire addr2, cmd2, out_out;
wire[8:0] h140 = 0'h140;
wire[8:0] h100 = 0'h00; 
wire[7:0] h00 = 0'h00;
	
//MEM and RAM module**

wire[15:0] write_data;
wire[15:0] read_data;
wire [1:0] mem_cmd;
wire [8:0] mem_addr;

wire [15:0] tribufferin;

wire msel;
wire[15:0] mwriteeq,mreadeq;
wire writeout,readout;
assign msel = (mem_addr[8:8] == 1'b0)? 1'b1: 1'b0;
RAM #(16,8) MEM(.clk(~KEY[0]),.read_address(mem_addr[7:0]),.write_address(mem_addr[7:0]),.write(writeout),.din(write_data),.dout(tribufferin));


assign mwriteeq = (mem_cmd == `MWRITE)? 1'b1: 1'b0;
assign mreadeq  = (mem_cmd == `MREAD)? 1'b1: 1'b0;

assign writeout = mwriteeq & msel;
assign readout = mreadeq &msel;

tristate_buffer#(16) tribuf(tribufferin, readout, read_data);

//instantiate:

cpu CPU(.clk(~KEY[0]),.read_data(read_data),.mem_cmd(mem_cmd),.mem_addr(mem_addr),.write_data(write_data),.reset(~KEY[1]),.N(N),.V(V),.Z(Z));


//Circuit 1:
assign addr = (mem_addr==h140)? 1:0;
assign cmd = (mem_cmd == `MREAD)?1:0;
assign in_out =(addr&cmd)?1:0;

//Tristate buffer:

tristate_buffer #(8) Circ1(.input_x(h00), .enable(in_out),.output_x(read_data[15:8]));
tristate_buffer #(8) Circ12(.input_x(SW[7:0]),.enable(in_out),.output_x(read_data[7:0]));

//Circuit 2:

assign addr2= (mem_addr==h100)? 1:0;
assign cmd2 = (mem_cmd==`MWRITE)? 1:0;
assign out_out =(addr2&cmd2)? 1:0;

//VDFFE:

vDFFE #(8) Circ2(.clk(~KEY[0]),.load(out_out),.in(write_data[7:0]),.out(LEDR[7:0]));



 assign HEX5[0] = ~Z;
 assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(write_data[3:0],   HEX0);
  sseg H1(write_data[7:4],   HEX1);
  sseg H2(write_data[11:8],  HEX2);
  sseg H3(write_data[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;

endmodule



module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  

   always@(*)begin  //remember 0 means open
case(in)
	   //6543_210
4'b0000:segs=7'b1000_000;		//0
4'b0001:segs=7'b1111_001;		//1
4'b0010:segs=7'b0100_100;		//2
4'b0011:segs=7'b0110_000;		//3
4'b0100:segs=7'b0011_001;		//4
	   //6543_210
4'b0101:segs=7'b0010_010;		//5
4'b0110:segs=7'b0000_010;		//6
4'b0111:segs=7'b1111_000;		//7
4'b1000:segs=7'b0000_000;		//8
	   //6543_210
4'b1001:segs=7'b0010_000;		//9
4'b1010:segs=7'b0001_000;		//10=A
4'b1011:segs=7'b0000_011;		//11=b
	   //6543_210
4'b1100:segs=7'b1000_110;		//12=C
4'b1101:segs=7'b0100_001;		//13=d
4'b1110:segs=7'b0000_110;		//14=E
4'b1111:segs=7'b0001_110;		//15F
default:segs=7'bxxxx_xxx;
endcase
end

endmodule
