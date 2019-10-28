module REGFILE(data_in,writenum,write,readnum,clk,data_out); 
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output reg[15:0] data_out;

wire[15:0]R0;
wire[15:0]R1; 
wire[15:0]R2; 
wire[15:0]R3; 
wire[15:0]R4; 
wire[15:0]R5; 
wire[15:0]R6; 
wire[15:0]R7;  //These are the enabled d-flip flop of data in(which register is the data @)

wire[7:0]writenum_h,readnum_h;//This is hot coded writenum and readnum 
wire[7:0]write_to_reg; //which reg should it write

Dec #(3,8) dec1(writenum,writenum_h); //one hot coded writenum
Dec #(3,8) dec2(readnum,readnum_h); //one hot coded readnum

assign write_to_reg={
			write&writenum_h[7],  
			write&writenum_h[6],   
			write&writenum_h[5],
			write&writenum_h[4],    //AND OPERATIONS
			write&writenum_h[3],
			write&writenum_h[2],
			write&writenum_h[1],
			write&writenum_h[0]
			};
//REGISTERS
vDFFE #(16) U0(clk,write_to_reg[0],data_in,R0[15:0]); //R0
vDFFE #(16) U1(clk,write_to_reg[1],data_in,R1[15:0]); //R1
vDFFE #(16) U2(clk,write_to_reg[2],data_in,R2[15:0]); //R2
vDFFE #(16) U3(clk,write_to_reg[3],data_in,R3[15:0]); //R3
vDFFE #(16) U4(clk,write_to_reg[4],data_in,R4[15:0]); //R4
vDFFE #(16) U5(clk,write_to_reg[5],data_in,R5[15:0]); //R5
vDFFE #(16) U6(clk,write_to_reg[6],data_in,R6[15:0]); //R6
vDFFE #(16) U7(clk,write_to_reg[7],data_in,R7[15:0]); //R7



always@(*)begin //Multiplexers
case(readnum_h)
8'b0000_0001:data_out=R0[15:0];  
8'b0000_0010:data_out=R1[15:0];
8'b0000_0100:data_out=R2[15:0];
8'b0000_1000:data_out=R3[15:0];
8'b0001_0000:data_out=R4[15:0];
8'b0010_0000:data_out=R5[15:0];
8'b0100_0000:data_out=R6[15:0];
8'b1000_0000:data_out=R7[15:0];
default:data_out=16'bxxxx_xxxx_xxxx_xxxx;
endcase
end
    
endmodule 