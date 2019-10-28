`define add 2'b00
`define sub 2'b01
`define annd 2'b10
`define notB 2'b11

module ALU(Ain,Bin,ALUop,out,status);
	input [15:0] Ain, Bin;
	input [1:0] ALUop;
	output reg [15:0] out;
	output [2:0] status;
	
	wire bsub;

	assign bsub = (Bin[15]^(~ALUop[1]&ALUop[0]));//check for sub to calculate ovf
	assign status[0] = (|out)? 1'b0 : 1'b1;//all zeros Z
	assign status[1] = out[15];//negative N
	assign status[2] = (ALUop !== `notB) ? (~(Ain[15]^bsub)&(Ain[15]^out[15])): 1'b0;//ovf V if aluop is not 11
	
	always @(*) begin
		case(ALUop)
			`add: out <= Ain + Bin;
			`sub: out <= Ain - Bin;
			`annd: out <= Ain & Bin;
			`notB: out <= ~Bin;
			default: out <= {16{1'bx}};
		endcase	
	end
endmodule

