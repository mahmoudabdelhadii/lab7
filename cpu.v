`define MNONE 2'b00 //do not read or write
`define MWRITE 2'b01 // write to memory(can change)
`define MREAD  2'b11 // read from memory(can change)

`define reset 4'b0000
`define IF1   4'b0001
`define IF2	  4'b0010
`define updatePC 4'b0011
`define HALT 4'b0100
`define GetMem 4'b0101
`define LDRReadMem 4'b0110
`define LDRSTG3 4'b0111
`define WriteMem 4'b1000
`define STRSTG2 4'b1001
`define WriteImm 4'b1010
`define GetA  4'b1011
`define GetB 4'b1100
`define alushiftloadcs 4'b1101
`define WriteReg 4'b1110
`define extraClk 4'b1111

`define MOVopc 3'b110

`define LDRopc 3'b011
`define STRopc 3'b100
`define HALTopc 3'b111

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

`define mdata 4'b1000
`define Vsximm8 4'b0100
`define Vdataout 4'b0001


module cpu(clk,read_data,mem_cmd,mem_addr,write_data,reset,N,V,Z); //controls all of RISC machine with 16 bits instruction input and reset, s, clk, and load signals
	input clk, reset;
	output reg [1:0] mem_cmd;
	output [15:0] write_data;
	output N, V, Z;
	input [15:0] read_data;
	output[8:0] mem_addr;
	
	reg loada, loadb, loadc, loads, write, asel, bsel;
	wire [1:0] op;
	wire [1:0] ALUop, shift;
	wire [2:0] readwrite;
	reg [2:0]  nsel;
	wire [3:0] state;
	reg[3:0] n_state;
	reg [3:0] vsel;
	wire [2:0] opcode;
	wire [15:0] inreg, sximm8, sximm5;
	reg load_pc,reset_pc, addr_sel, loadaddr,load_ir;
	wire [7:0]PC;
	wire [15:0] mdata;
	
	
	vDFFE #(16) cpuvDFFE(.clk(clk), .load(load_ir), .in(read_data), .out(inreg));//passes new instructions when load is high
	instrucDec fig8(.inreg(inreg), .nsel(nsel), .opcode(opcode), .op(op), .ALUop(ALUop),
							.shift(shift), .sximm8(sximm8), .sximm5(sximm5), .readwrite(readwrite));//decodes instructions for use in FSM
							
	datapath #(16) DP(.clk(clk), .readnum(readwrite), .vsel(vsel), .loada(loada),
										.loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel),
										.ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(readwrite),
										.write(write), .mdata(read_data), .sximm8(sximm8), .PC(PC),
										.sximm5(sximm5), .status_out({V,N,Z}), .datapath_out(write_data)); // assigns inputs to run datapath based on cpu FSM and instruction decoding
									
	PC U2(/*inputs*/.clk(clk), /*FSM*/.reset_pc(reset_pc),/*FSM*/.load_pc(load_pc),/*FSM*/.load_addr(load_addr),/*FSM*/.addr_sel(addr_sel),.datapath_out(write_data),/*outputs*/.mem_addr(mem_addr));
	//assign w = ((~|(state)) & ~s) ? 1'b1: 1'b0;
	assign state = n_state;

	always @(posedge clk) begin //goes over states of various opcode/op instructions, assigns relevant datapath inputs, else staying in the same state and assigning all zeros for the default line
		casex({reset, opcode, op, state})
			
			//RESET
			{1'b1, 3'bxxx, 2'bxx, 4'bxxxx}: n_state <= `reset; //reset state
			
			//RESET TO IF1
			{1'b0, 3'bxxx, 2'bxx, `reset}: {n_state,reset_pc,load_pc,mem_cmd,addr_sel,load_ir} <= {`IF1,1'b1,1'b1,`MNONE,1'b0,1'b0}; //s is zero and reset state
			
			//IF1 to IF2
			{1'b0, 3'bxxx, 2'bxx, `IF1} :  {n_state,addr_sel,mem_cmd,reset_pc,load_pc,addr_sel} <= {`IF2,1'b1,`MREAD,1'b0,1'b0,1'b1}; //s is zero and reset state
			
			//IF2 TO UPDATEPC
			{1'b0, 3'bxxx, 2'bxx, `IF2} : {n_state,addr_sel,mem_cmd,load_ir}  <= {`updatePC,1'b1,`MREAD,1'b1};
			
			//UPDATEPC TO WRITEIMM, GETA(movopc), GETA(aluopc)
			{1'b0, `MOVopc, `wrImmop, `updatePC}: {n_state, load_pc} <= {`WriteImm,1'b1};
			{1'b0, `MOVopc, `wrShft, `updatePC}:{n_state, load_pc} <= {`GetA,1'b1}; 
			{1'b0, `ALUopc, 2'bxx, `updatePC}: {n_state, load_pc} <= {`GetA,1'b1};
			
			//UPDATE PC to HALT, GETA(ldropc), GETA(stropc)
			{1'b0, `HALTopc,2'b00, `updatePC}: {n_state, load_pc,addr_sel,mem_cmd,load_ir} <= {`HALT,1'b1,1'b0,`MNONE,1'b0};
			{1'b0, `LDRopc,2'b00, `updatePC}: {n_state, load_pc,addr_sel,mem_cmd,load_ir} <= {`GetA,1'b1,1'b0,`MNONE,1'b0};
			{1'b0, `STRopc,2'b00, `updatePC}: {n_state, load_pc,addr_sel,mem_cmd,load_ir} <= {`GetA,1'b1,1'b0,`MNONE,1'b0};
			
			//GET A to WRITEIMM(ldropc), WRITEIMM(stropc)
			{1'b0, `LDRopc, 2'bxx, `GetA}: {n_state, nsel, loada} <= {`WriteImm, `Rn, 1'b1};
			{1'b0, `STRopc, 2'bxx, `GetA}: {n_state, nsel, loada} <= {`WriteImm, `Rn, 1'b1};

			//HALT TO EXTRACLK AND EXTRACLK TO HALT
			{1'b0, `HALTopc, 2'bxx, `HALT}: n_state <= `extraClk;
			{1'b0, `HALTopc, 2'bxx, `extraClk}: {n_state, write} <= `HALT;

			//WRITEIMM to alushift(ldr), alushift(str)
			{1'b0, `LDRopc, 2'bxx, `WriteImm}:{n_state, nsel, vsel, write} <= {`alushiftloadcs, `Rn, `mdata, 1'b1};
			{1'b0, `STRopc, 2'bxx, `WriteImm}: {n_state, nsel, vsel, write} <= {`alushiftloadcs, `Rn, `mdata, 1'b1};

			//alushift to GETMEM(ldr), GETMEM(str)
			{1'b0, `LDRopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`GetMem, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};//state which performs calculations on numbers
			{1'b0, `STRopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`GetMem, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};//state which performs calculations on numbers

			//GETMEM to LDRREADMEM, GETB
			{1'b0, `LDRopc, 2'bxx, `GetMem}: {n_state,addr_sel,load_pc,mem_cmd} <= {`LDRReadMem};
			{1'b0, `STRopc, 2'bxx, `GetMem}: n_state <= `GetB;

			//LDRREADMEM TO WRITEREG, GETB TO alushift
			{1'b0, `LDRopc, 2'bxx, `LDRReadMem}: n_state <= `WriteReg;
			{1'b0, `STRopc, 2'bxx, `GetB}: {n_state, nsel, loadb, loada} <= {`alushiftloadcs, `Rm, 1'b1, 1'b0};

			//alushift to WRITEMEM
			{1'b0, `STRopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`WriteMem, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};

			//
			{1'b0, `LDRopc, 2'bxx, `WriteReg}: {n_state, nsel, vsel, write, loadc, loads} <= {`extraClk, `Rd, `Vdataout, 1'b1, 1'b0, 1'b0};
			{1'b0, `STRopc, 2'bxx, `WriteMem}: n_state <= `extraClk;


			{1'b0, `MOVopc, `wrImmop, `WriteImm}: {n_state, nsel, vsel, write} <= {`extraClk, `Rn, `Vsximm8, 1'b1}; //state to write number from vsel mux to register Rn
			//{1'b0, 3'bxxx, 2'bxx, `WriteImm}: {n_state}<={`extraClk};

			{1'b0, `MOVopc, `wrShft, `GetA}: {n_state, nsel, loada} <= {`GetB, `Rn, 1'b1}; // state to get first source operand
			{1'b0, `ALUopc, 2'bxx, `GetA}: {n_state, nsel, loada} <= {`GetB, `Rn, 1'b1};
			
			{1'b0, `MOVopc, `wrShft, `GetB}: {n_state, nsel, loadb, loada} <= {`alushiftloadcs, `Rm, 1'b1, 1'b0}; // state to get second source operand
			{1'b0, `ALUopc, 2'bxx, `GetB}: {n_state, nsel, loadb, loada} <= {`alushiftloadcs, `Rm, 1'b1, 1'b0}; // state to get second source operand
			
			{1'b0, `ALUopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`WriteReg, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0};//state which performs calculations on numbers
			{1'b0, `MOVopc, 2'bxx, `alushiftloadcs}: {n_state, asel, bsel, loadc, loads, loadb} <= {`WriteReg, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0};												
			
			{1'b0, 3'bxxx, 2'bxx, `WriteReg}: {n_state, nsel, vsel, write, loadc, loads} <= {`extraClk, `Rd, `Vdataout, 1'b1, 1'b0, 1'b0};// state to write numbers to Rd
			{1'b0, 3'bxxx, 2'bxx, `WriteReg}: {n_state, nsel, vsel, write, loadc, loads} <= {`extraClk, `Rd, `Vdataout, 1'b1, 1'b0, 1'b0};// state to write numbers to Rd

			{1'b0, 3'bxxx, 2'bxx, `extraClk}: {n_state, write} <= {`IF1, 1'b0};//extra state to allow program to correctly execute before error signal is checked
			
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