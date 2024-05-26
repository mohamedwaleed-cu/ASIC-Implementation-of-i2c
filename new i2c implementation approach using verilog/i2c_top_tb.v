module i2c_top_tb;

reg clk,rst;



i2c_top dut ( clk,rst);


initial 
begin
rst <= 1;
clk <= 0;
#3
rst <= 0;
end

initial 
begin
	repeat(70)
	#5 clk <= ~clk;
end







endmodule
