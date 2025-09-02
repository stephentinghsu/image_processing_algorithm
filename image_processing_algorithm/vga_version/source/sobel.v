`timescale 1ns / 1ps

module sobel( p0, p1, p2, p3, p5, p6, p7, p8, out);

input  [bit_width-1:0] p0,p1,p2,p3,p5,p6,p7,p8;
output [bit_width-1:0] out;

wire signed [10:0] gx,gy;
				 
wire signed [10:0] abs_gx,abs_gy;
wire [10:0] sum;

assign gx=((p2-p0)+((p5-p3)<<1)+(p8-p6));
assign gy=((p0-p6)+((p1-p7)<<1)+(p2-p8));

assign abs_gx = (gx[10]? ~gx+1 : gx);
assign abs_gy = (gy[10]? ~gy+1 : gy);

assign sum = (abs_gx+abs_gy);
assign out = (|sum[10:8])?8'hff : sum[7:0];

endmodule
