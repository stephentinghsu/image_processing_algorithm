`timescale 1ns / 1ps

`include "sobel.v"
`include "median.v"

module operate(clk, rst, func, result_address, result_data);

input clk;
input rst;
input func;
output [address_width-1:0] result_address;
output [bit_width-1:0] result_data;

// target pixel and the surrounding 8 pixels
wire [bit_width-1:0] p0; wire [bit_width-1:0] p1; wire [bit_width-1:0] p2;
wire [bit_width-1:0] p3; wire [bit_width-1:0] p4; wire [bit_width-1:0] p5;
wire [bit_width-1:0] p6; wire [bit_width-1:0] p7; wire [bit_width-1:0] p8;
wire [bit_width-1:0] sobel_result;
wire [bit_width-1:0] median_result;

reg [address_width-1:0] counter;
initial begin counter <= 14'd0; end

// load the target pixel and the surrounding 8 pixels from bram according to the counter
image_coe load_p0(.clka(clk), .wea(1'h00), .addra(1078+counter-100-1), .dina(8'h00),.douta(p0));
image_coe load_p1(.clka(clk), .wea(1'h00), .addra(1078+counter-100),   .dina(8'h00),.douta(p1));
image_coe load_p2(.clka(clk), .wea(1'h00), .addra(1078+counter-100+1), .dina(8'h00),.douta(p2));
image_coe load_p3(.clka(clk), .wea(1'h00), .addra(1078+counter-1),     .dina(8'h00),.douta(p3));
image_coe load_p4(.clka(clk), .wea(1'h00), .addra(1078+counter),       .dina(8'h00),.douta(p4));
image_coe load_p5(.clka(clk), .wea(1'h00), .addra(1078+counter+1),     .dina(8'h00),.douta(p5));
image_coe load_p6(.clka(clk), .wea(1'h00), .addra(1078+counter+100-1), .dina(8'h00),.douta(p6));
image_coe load_p7(.clka(clk), .wea(1'h00), .addra(1078+counter+100),   .dina(8'h00),.douta(p7));
image_coe load_p8(.clka(clk), .wea(1'h00), .addra(1078+counter+100+1), .dina(8'h00),.douta(p8));

// do sobel operation
sobel sobel(.p0(p0), .p1(p1), .p2(p2),
            .p3(p3), .p5(p5), 
            .p6(p6), .p7(p7), .p8(p8), 
            .out(sobel_result));

// do median operation
median median(.p0(p0), .p1(p1), .p2(p2),
              .p3(p3), .p4(p4), .p5(p5),
              .p6(p6), .p7(p7), .p8(p8),
              .out(median_result));

// output the operaton result depending on func
reg [bit_width-1:0] result_data;
always @(posedge clk)begin
    if(!rst)begin 
        counter <= 14'd0;
    end else begin
        if((counter >= 14'd0 && counter < 14'd100)||(counter >= 14'd9900 && counter < 14'd9999))begin 
            result_data <= 8'h00;
            counter <= counter + 14'd1;
        end else if(counter == 14'd10000)begin
            result_data <= 8'h00;
            counter <= 14'd10000;
        end else if((counter % 100 == 14'd0)||(counter % 100 == 14'd99))begin
            result_data <= 8'h00;
            counter <= counter + 14'd1;
        end else begin
            counter <= counter + 14'd1;
            if(func) result_data <= sobel_result;
            else result_data <= median_result;
        end
    end
end

// delay the address for 1
reg [address_width-1:0] result_address;
always @(counter)begin
    if(counter == 14'd0)
        result_address <= counter;
    else
        result_address <= counter - 14'd1;
end



endmodule
