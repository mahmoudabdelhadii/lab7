module tristate_buffer(input_x, enable, output_x);
parameter n = 1;
input [n-1:0]input_x;
input enable;
output [n-1:0] output_x;
assign output_x = (enable==0)? input_x:'bz;
endmodule
