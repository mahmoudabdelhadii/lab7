`define reset 3'b000
`define Decode 3'b001
`define WriteImm 3'b010
`define GetA 3'b011
`define GetB 3'b100
`define alushiftloadcs 3'b101
`define WriteReg 3'b110
`define extraClk 3'b111

`define MOVopc 3'b110

`define wrImmop 2'b10
`define wrShft 2'b00

`define ALUopc 3'b101

`define ALUadd 2'b00
`define ALUsub 2'b01
`define ALUannd 2'b11
`define ALUnotB 2'b01

`define Rd 3'b001
`define Rm 3'b010
`define Rn 3'b100

`define Vsximm8 4'b0100
`define Vdataout 4'b0001


module cpu(clk,mdata,dout,reset,s,load,out,N,V,Z,w); //controls all of RISC machine with 16 bits instruction input and reset, s, clk, and load signals
	input clk, reset, s, load;
	
	output [15:0] out;
	output N, V, Z;
	output w;
	input [15:0] mdata,dout;
	
	reg loada, loadb, loadc, loads, write, asel, bsel;
	wire [1:0] op;
	wire [1:0] ALUop, shift;
	wire [2:0] state, readwrite;
	reg [2:0] n_state, nsel;
	reg [3:0] vsel;
	wire [2:0] opcode;
	wire [15:0] inreg, sximm8, sximm5;
	wire [7:0] PC = 8'b0;
	
	vDFFE #(16) cpuDFF(.clk(clk), .load(load), .in(in), .out(inreg));//passes new instructions when load is high
	instrucDec fig8(.inreg(inreg), .nsel(nsel), .opcode(opcode), .op(op), .ALUop(ALUop),
							.shift(shift), .sximm8(sximm8), .sximm5(sximm5), .readwrite(readwrite));//decodes instructions for use in FSM
							
	datapath #(16) DP(.clk(clk), .readnum(readwrite), .vsel(vsel), .loada(loada),
										.loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel),
										.ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(readwrite),
										.write(write), .mdata(mdata), .sximm8(sximm8), .PC(PC),
										.sximm5(sximm5), .status_out({V,N,Z}), .datapath_out(out)); // assigns inputs to run datapath based on cpu FSM and instruction decoding
									
	
	assign w = ((~|(state)) & ~s) ? 1'b1: 1'b0;
	assign state = n_state;

	always @(posedge clk) begin //goes over states of various opcode/op instructions, assigns relevant datapath inputs, else staying in the same state and assigning all zeros for the default line
		casex({reset, s, opcode, op, state})
			{2'b00, 3'bxxx, 2'bxx, `reset}: n_state <= `reset; //s is zero and reset state
			{2'b01, `MOVopc, `wrImmop, `reset}: n_state <= `WriteImm;
			{2'b01, `MOVopc, `wrShft, `reset}: n_state <= `GetA; //s goes to 1
			{2'b01, `ALUopc, 2'bxx, `reset}: n_state <= `GetA; 
			
			{2'b1x, 3'bxxx, 2'bxx, 3'bxxx}: n_state <= `reset; //reset state

			{2'b0x, 3'bxxx, 2'bxx, `WriteImm}: {n_state, nsel, vsel, write} <= {`extraClk, `Rn, `Vsximm8, 1'b1}; //state to write number from vsel mux to register Rn
			
			{2'b0x, 3'bxxx, 2'bxx, `GetA}: {n_state, nsel, loada} <= {`GetB, `Rn, 1'b1}; // state to get first source operand
			
			{2'b0x, 3'bxxx, 2'bxx, `GetB}: {n_state, nsel, loadb, loada} <= {`alushiftloadcs, `Rm, 1'b1, 1'b0}; // state to get second source operand
			
			{2'b0x, `ALUopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`WriteReg, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};//state which performs calculations on numbers
			{2'b0x, `MOVopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`WriteReg, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0};												
			
			{2'b0x, 3'bxxx, 2'bxx, `WriteReg}: {n_state, nsel, vsel, write, loadc, loads} <= {`extraClk, `Rd, `Vdataout, 1'b1, 1'b0, 1'b0};// state to write numbers to Rd
			
			{2'b0x, 3'bxxx, 2'bxx, `extraClk}: {n_state, write} <= {`reset, 1'b0};//extra state to allow program to correctly execute before error signal is checked
			
			default: {n_state, nsel, loada, loadb, loadc, loads, vsel, write, asel, bsel} <= {n_state, 3'b000, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0, 1'b0, 1'b0, 1'b0};//maintain state if issue to indicate issue, all signals 0 to have nothing doing anything
		endcase
	end

endmodule 

module instrucDec(inreg, nsel, opcode, op, ALUop, shift, sximm8, sximm5, readwrite); // decodes 16 bit input signal
	input [15:0] inreg;
	input [2:0] nsel;
	output [2:0] opcode ;
	output [1:0] ALUop, shift ;
	output [1:0] op;
	output [15:0] sximm8;
	output [15:0] sximm5;
	output [2:0] readwrite;
	
	wire [2:0] Rn = inreg[10:8], Rd = inreg[7:5], Rm = inreg[2:0]; // coding for the first, destination, and second source operand registers
	
	assign op = inreg[12:11]; // secondary signal to choose method to execute
	assign opcode = inreg[15:13];//primary signal to choose method class to execute 
	assign sximm8 = {{8{inreg[7]}}, inreg[7:0]};//8 bit sign extended input signal to datapath
	assign sximm5 = {{11{inreg[4]}}, inreg[4:0]};//5 bit sign extended signal to input in ALU if asel MUX is high
	assign ALUop = inreg[12:11];//signal to choose operation for ALU unit
	assign shift = inreg[4:3];//signal to choose operation for shift unit
	
	Mux3 #(3) regchooser(.a2(Rn), .a1(Rm), .a0(Rd), .s(nsel), .b(readwrite));//mux to choose which register to write/read to
	
endmodule 

module Mux3 (a2,a1,a0,s,b);//mux to choose which register to read/write to
	parameter k = 1;
	input [2:0] s; 
	input [k-1:0] a2,a1,a0;
	output reg [k-1:0] b;
	
	always @(*) begin//to choose the input based on s 
		case(s)
			3'b001: b = a0;
			3'b010: b = a1;
			3'b100: b = a2;
			default: b = {k{1'bx}};
		endcase 
	end
endmodule 