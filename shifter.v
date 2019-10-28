module shifter(in,shift,sout); 
input [15:0] in;
input [1:0] shift;
output reg [15:0] sout;
  

always@(*)  begin 
case(shift)  
2'b00:sout=in;  	     //B
2'b01:sout={in[14:0],1'b0};  //B shifted left 1-bit, least significant bit is zero
2'b10:sout={1'b0,in[15:1]};   //B shifted right 1-bit, most significant bit, MSB, is 0
2'b11:sout={in[15],in[15:1]};//B shifted right 1-bit, MSB is copy of B[15]
endcase
 end     
endmodule
