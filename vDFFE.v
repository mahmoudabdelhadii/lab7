module vDFFE(clk,load,in,out);  //from the slidesets
parameter n=1;
input clk,load;              //this is d flip flop with enable.
input[n-1:0] in;
output [n-1:0] out;
reg[n-1:0]out;
wire[n-1:0]next_out;
assign next_out=load?in:out;

always@(posedge clk)
out=next_out;
endmodule 