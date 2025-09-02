`timescale 1ns / 1ps

module median( p0, p1, p2, p3, p4, p5, p6, p7, p8, out);

input  [bit_width-1:0] p0,p1,p2,p3,p4,p5,p6,p7,p8;
output [bit_width-1:0] out;

//
wire [bit_width-1:0] p012_min, p012_med, p012_max;
wire [bit_width-1:0] p345_min, p345_med, p345_max;
wire [bit_width-1:0] p678_min, p678_med, p678_max;

assign p012_min = (p0 <= p1) ? ((p0 <= p2) ? p0 : p2) : ((p1 <= p2) ? p1 : p2);
assign p012_med = (p0 <= p1) ? ((p0 <= p2) ? ((p1 <= p2) ? p1 : p2) : p0) : ((p1 <= p2) ? ((p0 <= p2) ? p0 : p2) : p1);
assign p012_max = (p0 >= p1) ? ((p0 >= p2) ? p0 : p2) : ((p1 >= p2) ? p1 : p2);

assign p345_min = (p3 <= p4) ? ((p3 <= p5) ? p3 : p5) : ((p4 <= p5) ? p4 : p5);
assign p345_med = (p3 <= p4) ? ((p3 <= p5) ? ((p4 <= p5) ? p4 : p5) : p3) : ((p4 <= p5) ? ((p3 <= p5) ? p3 : p5) : p4);
assign p345_max = (p3 >= p4) ? ((p3 >= p5) ? p3 : p5) : ((p4 >= p5) ? p4 : p5);

assign p678_min = (p6 <= p7) ? ((p6 <= p8) ? p6 : p8) : ((p7 <= p8) ? p7 : p8);
assign p678_med = (p6 <= p7) ? ((p6 <= p8) ? ((p7 <= p8) ? p7 : p8) : p6) : ((p7 <= p8) ? ((p6 <= p8) ? p6 : p8) : p7);
assign p678_max = (p6 >= p7) ? ((p6 >= p8) ? p6 : p8) : ((p7 >= p8) ? p7 : p8);

// the maximum from the three minimum, the minimum from the three maximum 
wire [bit_width-1:0] p_3min_max, p_3max_min; 

assign p_3max_min = (p012_max <= p345_max) ? ((p012_max <= p678_max) ? p012_max : p678_max)
                                           : ((p345_max <= p678_max) ? p345_max : p678_max);
assign p_3min_max = (p012_min >= p345_min) ? ((p012_min >= p678_min) ? p012_min : p678_min
                                           : ((p345_min >= p678_min) ? p345_min : p678_min);

// exclude the two maximum from the five median, and the third maximum is the median
reg [bit_width-1:0] p_4med_0, p_4med_1, p_4med_2, p_4med_3; 
reg [bit_width-1:0] p_3med_0, p_3med_1, p_3med_2;

always @(*)begin
    if((p012_med >= p345_med)&&(p012_med >= p678_med)&&(p012_med >= p_3max_min)&&(p012_med >= p_3min_max))begin
        p_4med_0 = p345_med; p_4med_1 = p678_med; p_4med_2 = p_3max_min; p_4med_3 = p_3min_max;
    end else if((p345_med >= p012_med)&&(p345_med >= p678_med)&&(p345_med >= p_3max_min)&&(p345_med >= p_3min_max))begin
        p_4med_0 = p012_med; p_4med_1 = p678_med; p_4med_2 = p_3max_min; p_4med_3 = p_3min_max;
    end else if((p678_med >= p012_med)&&(p678_med >= p345_med)&&(p678_med >= p_3max_min)&&(p678_med >= p_3min_max))begin
        p_4med_0 = p012_med; p_4med_1 = p345_med; p_4med_2 = p_3max_min; p_4med_3 = p_3min_max;
    end else if((p_3max_min >= p012_med)&&(p_3max_min >= p345_med)&&(p_3max_min >= p678_med)&&(p_3max_min >= p_3min_max))begin
        p_4med_0 = p012_med; p_4med_1 = p345_med; p_4med_2 = p678_med; p_4med_3 = p_3min_max;
    end else if((p_3min_max >= p012_med)&&(p_3min_max >= p345_med)&&(p_3min_max >= p678_med)&&(p_3min_max >= p_3max_min))begin
        p_4med_0 = p012_med; p_4med_1 = p345_med; p_4med_2 = p678_med; p_4med_3 = p_3max_min;
    end else begin
        p_4med_0 = p012_med; p_4med_1 = p345_med; p_4med_2 = p678_med; p_4med_3 = 8'd0;
    end
end

always @(*)begin
    if((p_4med_0 >= p_4med_1)&&(p_4med_0 >= p_4med_2)&&(p_4med_0 >= p_4med_3))begin
    p_3med_0 = p_4med_1; p_3med_1 = p_4med_2; p_3med_2 = p_4med_3;
    end else((p_4med_1 >= p_4med_0)&&(p_4med_1 >= p_4med_2)&&(p_4med_1 >= p_4med_3))begin
    p_3med_0 = p_4med_0; p_3med_1 = p_4med_2; p_3med_2 = p_4med_3;
    end else((p_4med_2 >= p_4med_0)&&(p_4med_2 >= p_4med_1)&&(p_4med_2 >= p_4med_3))begin
    p_3med_0 = p_4med_0; p_3med_1 = p_4med_1; p_3med_2 = p_4med_3;
    end else((p_4med_3 >= p_4med_0)&&(p_4med_3 >= p_4med_1)&&(p_4med_3 >= p_4med_2))begin
    p_3med_0 = p_4med_0; p_3med_1 = p_4med_1; p_3med_2 = p_4med_2;
    end else begin
    p_3med_0 = p_4med_0; p_3med_1 = p_4med_1; p_3med_2 = p_4med_2;
    end
end

assign out = (p_3med_0 >= p_3med_1) ? ((p_3med_0 >= p_3med_2) ? p_3med_0 : p_3med_2) : ((p_3med_1 >= p_3med_2) ? p_3med_1 : p_3med_2);
                                              
// wire [10:0] sum;
// assign sum = p0+p1+p2+p3+p5+p6+p7+p8;
// assign out = sum/8'h08;

// assign med = (a <= b) ? ((a <= c) ? ((b <= c) ? b : c) : a) : ((b <= c) ? ((a <= c) ? a : c) : b);
// assign min = (a <= b) ? ((a <= c) ? a : c) : ((b <= c) ? b : c);
// assign max = (a >= b) ? ((a >= c) ? a : c) : ((b >= c) ? b : c);

endmodule
