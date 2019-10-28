module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
input [3:0] KEY;
input [9:0]
output [9:0] LEDR;
output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

wire [15:0] dout;
cpu U( .clk   (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset (~KEY[1]), 
         .s     (~KEY[2]),//go away
         .load  (~KEY[3]),//go away
         .in    (dout),
         .out   (out),
         .Z     (Z),
         .N     (N),
         .V     (V),
         .w     (LEDR[9]) );
RAM #(16,18) MEM (.clk   (~KEY[0]),
                        )


 assign HEX5[0] = ~Z;
 assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;

endmodule



module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
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
