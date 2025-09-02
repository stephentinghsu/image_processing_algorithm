`timescale 1ns / 1ps

module testbench();

reg clk;
initial clk = 0;
always #5 clk = ~clk;


reg rst, func;
initial begin
rst = 0;
func = 0;
#10000
rst = 1;
func = 1;
#2500000
rst = 0;
func = 0;
#10000
rst = 1;
func = 0;
end


wire [3:0] red_out;
wire [3:0] green_out;
wire [3:0] blue_out;
wire hsync_out;
wire vsync_out;
top top(clk, rst, func, red_out, green_out, blue_out, hsync_out, vsync_out);


endmodule
