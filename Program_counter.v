module PC(/*inputs*/clk, reset_pc,load_pc,load_addr,addr_sel,datapath_out,/*outputs*/mem_addr);
input reset_pc, load_pc, load_addr, addr_sel,clk;
input[15:0] datapath_out;

output[8:0] mem_addr; 

wire[8:0] next_pc, p_out, p2_out, data_out;

//Assign p2_out wire to p_out + 1;
assign p2_out = p_out + 9'd1; 

//MUX 1: 
assign next_pc= reset_pc? 9'b0: p2_out; 

//Program Counter Register (P0);
 
vDFFE #(9) ProgramCounter(clk,load_pc, next_pc, p_out);

//Data Address Register (D0);

vDFFE #(9) DataAddress(clk, load_addr, datapath_out[8:0], data_out); 

//MUX #2:
assign mem_addr = addr_sel? p_out: data_out;

endmodule 



