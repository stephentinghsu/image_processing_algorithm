`timescale 1ns / 1ps

module testbench();

reg clk;
initial clk = 0;
always #5 clk = ~clk;


reg start, dosobel, domedian;
initial begin
start = 0;
dosobel = 0;
domedian = 0;
#10
start = 1;
dosobel = 1;
domedian =1;
end

top top(clk, start, dosobel, domedian, sobel_success, median_success);


endmodule
