module shifter_tb; //in,shift,sout
reg err;
reg[15:0]in;
reg[1:0]shift;
wire[15:0]sout;

shifter DUT(in,shift,sout);

initial begin  //example from lab handout
err=1'b0;  in=16'b1111000011001111;  shift=2'b00; //at first op code
#5;
$display("EXPECTED OUT=1111000011001111 , TESTBENCH OUT=%b",sout);
if(sout!==16'b1111000011001111)begin err =1'b1; $display("FAILED"); $stop; end     //00  out=1111000011001111
else err=1'b0;

  in=16'b1111000011001111;  shift=2'b01; //at first op code
#5;
$display("EXPECTED OUT=1110000110011110 , TESTBENCH OUT=%b",sout);
if(sout!==16'b1110000110011110)begin err =1'b1; $display("FAILED"); $stop; end	//01   out=1110000110011110
else err=1'b0;  

  in=16'b1111000011001111;  shift=2'b10; //at first op code
#5;
$display("EXPECTED OUT=0111100001100111 , TESTBENCH OUT=%b",sout);
if(sout!==16'b0111100001100111)begin err =1'b1; $display("FAILED"); $stop; end	//10   out=0111100001100111
else err=1'b0;
  in=16'b1111000011001111;  shift=2'b11; //at first op code
#5;
$display("EXPECTED OUT=1111100001100111 , TESTBENCH OUT=%b",sout);
if(sout!==16'b1111100001100111)begin err =1'b1; $display("FAILED"); $stop; end	//11    out=1111100001100111

if(~err) $display("PASSED");
else $display("FAILED");
#500;
$stop;
end


endmodule 
