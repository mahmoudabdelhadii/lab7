module Program_counter_tb;
reg reset_pc, load_pc, load_addr, addr_sel, err, clk; 
reg[15:0] datapath_out;

wire[8:0] mem_addr; 

//Module Instantiation 
PC DUT(clk,reset_pc,load_pc,load_addr,addr_sel,datapath_out,mem_addr);


//Setup clock 
initial begin 
clk = 0;
#5;
    forever begin 
    clk = 1; 
    #5;
    clk = 0;
    #5;
    end
end

//Start Testing
initial begin 
err = 1'b0; 

//Test 1 --> reset_pc = 1'b1, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110010;
reset_pc = 1'b1;
load_pc = 1'b1; 
load_addr = 1'b1; 
addr_sel = 1'b0; 
datapath_out = 16'b0001110001110010;
#10; 

$display("mem_addr is %b, and should be: 001110010", mem_addr);
if(mem_addr!==datapath_out[8:0])begin 
err = 1'b1;
$display("Failed Test 1");
end
else
$display("Passed Test 1");

//Test 1 --> reset_pc = 1'b1, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110010;
reset_pc = 1'b1;
load_pc = 1'b1; 
load_addr = 1'b0; 
addr_sel = 1'b0; 
datapath_out = 16'b1101110001110010;
#10; 

$display("mem_addr is %b, and should be: 001110010", mem_addr);
if(mem_addr!==datapath_out[8:0])begin 
err = 1'b1;
$display("Failed Test 2");
end
else
$display("Passed Test 2");


//Testing counter: 
//Test 1 --> reset_pc = 1'b0, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110011;
reset_pc = 1'b0;
load_pc = 1'b1; 
load_addr = 1'b1; 
addr_sel = 1'b1; 
datapath_out = 16'b0001110001110011;
#10; 

$display("mem_addr is %d, and should be: 1", mem_addr);
if(mem_addr!==9'd1)begin 
err = 1'b1;
$display("Failed Test 1");
end
else
$display("Passed Test 1");

//Test 2 --> reset_pc = 1'b0, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110011;
reset_pc = 1'b0;
load_pc = 1'b1; 
load_addr = 1'b1; 
addr_sel = 1'b1; 
datapath_out = 16'b0001110001110011;
#10; 

$display("mem_addr is %d, and should be: 2", mem_addr);
if(mem_addr!==9'd2)begin 
err = 1'b1;
$display("Failed Test 2");
end
else
$display("Passed Test 2");

//Test 3 --> reset_pc = 1'b0, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110011;
reset_pc = 1'b0;
load_pc = 1'b1; 
load_addr = 1'b1; 
addr_sel = 1'b1; 
datapath_out = 16'b0001110001110011;
#10; 

$display("mem_addr is %d, and should be: 3", mem_addr);
if(mem_addr!==9'd3)begin 
err = 1'b1;
$display("Failed Test 3");
end
else
$display("Passed Test 3");

//Test 4 --> reset_pc = 1'b1, load_pc = 1'b1, load_addr = 1'b1, addr_sel = 1'b0, datapath_out = 16'b0001110001110011;
reset_pc = 1'b1;
load_pc = 1'b1; 
load_addr = 1'b1; 
addr_sel = 1'b1; 
datapath_out = 16'b0001110001110011;
#10; 

$display("mem_addr is %d, and should be: 0", mem_addr);
if(mem_addr!==9'd0)begin 
err = 1'b1;
$display("Failed Test 4");
end
else
$display("Passed Test 4");

$stop;
end

endmodule