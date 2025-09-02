`timescale 1ns / 1ps

`include "median.v"

module median_mod(clk, domedian, header_done, data_out, median_done);

input clk, domedian, header_done;
output [bit_width-1:0] data_out;
output median_done;

// target pixel and the surrounding 8 pixels
wire [bit_width-1:0] median_data_p0; wire [bit_width-1:0] median_data_p1; wire [bit_width-1:0] median_data_p2;
wire [bit_width-1:0] median_data_p3; wire [bit_width-1:0] median_data_p4; wire [bit_width-1:0] median_data_p5;
wire [bit_width-1:0] median_data_p6; wire [bit_width-1:0] median_data_p7; wire [bit_width-1:0] median_data_p8;
wire [bit_width-1:0] median_data;

reg [address_width-1:0] median_counter;
initial begin median_counter <= 14'd0; end

// load the target pixel and the surrounding 8 pixels from bram according to the counter
image_coe load_median_p0(.clka(clk),.wea(1'h00),.addra(1078+median_counter-100-1),.dina(8'h00),.douta(median_data_p0));
image_coe load_median_p1(.clka(clk),.wea(1'h00),.addra(1078+median_counter-100),.dina(8'h00),.douta(median_data_p1));
image_coe load_median_p2(.clka(clk),.wea(1'h00),.addra(1078+median_counter-100+1),.dina(8'h00),.douta(median_data_p2));
image_coe load_median_p3(.clka(clk),.wea(1'h00),.addra(1078+median_counter-1),.dina(8'h00),.douta(median_data_p3));
image_coe load_median_p3(.clka(clk),.wea(1'h00),.addra(1078+median_counter),.dina(8'h00),.douta(median_data_p4));
image_coe load_median_p5(.clka(clk),.wea(1'h00),.addra(1078+median_counter+1),.dina(8'h00),.douta(median_data_p5));
image_coe load_median_p6(.clka(clk),.wea(1'h00),.addra(1078+median_counter+100-1),.dina(8'h00),.douta(median_data_p6));
image_coe load_median_p7(.clka(clk),.wea(1'h00),.addra(1078+median_counter+100),.dina(8'h00),.douta(median_data_p7));
image_coe load_median_p8(.clka(clk),.wea(1'h00),.addra(1078+median_counter+100+1),.dina(8'h00),.douta(median_data_p8));

// do median operation
median median(.p0(median_data_p0), .p1(median_data_p1), .p2(median_data_p2),
              .p3(median_data_p3), .p4(median_data_p4), .p5(median_data_p5),
              .p6(median_data_p6), .p7(median_data_p7), .p8(median_data_p8),
              .out(median_data));

// output the operaton result
reg median_done = 0;   
reg [bit_width-1:0] median_out;
always @(posedge clk)begin
    if(header_done)begin
        if(domedian)begin
            if((median_counter >= 14'd0 && median_counter < 14'd100)||(median_counter >= 14'd9900 && median_counter < 14'd9999))begin 
                median_out <= 8'h00;
                median_counter <= median_counter + 14'd1;
                median_done <= 1'b1;
            end else if (median_counter == 14'd10000) begin
                median_out <= 8'h00;
                median_counter <= 14'd10000;
                median_done <= 1'b1;
            end else if((median_counter % 100 == 14'd0)||(median_counter % 100 == 14'd99))begin
                median_out <= 8'h00;
                median_counter <= median_counter + 14'd1;
                median_done <= 1'b1;
            end else begin
                median_out <= median_data;
                median_counter <= median_counter + 14'd1;
                median_done <= 1'b1;
            end
        end else begin
            median_out <= 8'h00;
            median_counter <= 14'd0;
            median_done <= 1'b0;      
        end
    end else begin
        median_out <= 8'h00;
        median_counter <= 14'd0;
        median_done <= 1'b0;
    end
end

wire [bit_width-1:0] data_out;
assign data_out = median_out;

endmodule
