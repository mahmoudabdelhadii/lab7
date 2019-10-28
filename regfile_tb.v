module regfile_tb;  //data_in,writenum,write,readnum,clk,data_out
reg[15:0] data_in;
reg[2:0] writenum,readnum;
reg write,clk,err;
wire[15:0]data_out;


REGFILE DUT(data_in,writenum,write,readnum,clk,data_out);



initial begin 
clk=0; #5;
forever begin   //clk FOREVER LOOP
clk=1; #5;
clk=0; #5;
end
end

initial begin
err=1'b0;writenum=3'b000;readnum=3'b000;data_in=16'b0000_0000_0000_0001;write=1'b0; #10;
$display("Checking while write is 0...");
if(data_out!==data_in) err=1'b0;
else begin err=1'b1; $stop; end

writenum=3'b001; readnum=3'b001; write=1'b1;data_in=16'b0000_1000_0000_0001;#10;
$display("Checking while write is 1 and R1");
if(data_out==data_in) err=1'b0;
else begin err=1'b1; $stop; end

writenum=3'b101; readnum=3'b101; write=1'b1;data_in=16'b0110_0000_0000_0001; #10;
$display("Checking while write is 1 and writing to R5 reading from R5");
if(data_out==data_in) err=1'b0;
else begin err=1'b1; $stop; end

writenum=3'b101; readnum=3'b001; write=1'b1;data_in=16'b0000_1110_0000_0001; #10;
$display("Checking while write is 1 and writing to R5 reading from R1");
if(data_out!==data_in) err=1'b0;
else begin err=1'b1; $stop; end




if(~err) $display("PASSED");
else $display("FAILED");
#500;
$stop;
end
endmodule
