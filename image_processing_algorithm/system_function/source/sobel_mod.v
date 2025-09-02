`timescale 1ns / 1ps

`include "sobel.v"

module sobel_mod(clk, dosobel, header_done, data_out, sobel_done);

input clk, dosobel, header_done;
output [bit_width-1:0] data_out;
output sobel_done;

// target pixel and the surrounding 8 pixels
wire [bit_width-1:0] sobel_data_p0; wire [bit_width-1:0] sobel_data_p1; wire [bit_width-1:0] sobel_data_p2;
wire [bit_width-1:0] sobel_data_p3; wire [bit_width-1:0] sobel_data_p5;
wire [bit_width-1:0] sobel_data_p6; wire [bit_width-1:0] sobel_data_p7; wire [bit_width-1:0] sobel_data_p8;
wire [bit_width-1:0] sobel_data;

// count the current position
reg [address_width-1:0] sobel_counter;
initial begin sobel_counter <= 14'd0; end

// load the target pixel and the surrounding 8 pixels from bram according to the counter
image_coe load_sobel_p0(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter-100-1),.dina(8'h00),.douta(sobel_data_p0));
image_coe load_sobel_p1(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter-100),.dina(8'h00),.douta(sobel_data_p1));
image_coe load_sobel_p2(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter-100+1),.dina(8'h00),.douta(sobel_data_p2));
image_coe load_sobel_p3(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter-1),.dina(8'h00),.douta(sobel_data_p3));
image_coe load_sobel_p5(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter+1),.dina(8'h00),.douta(sobel_data_p5));
image_coe load_sobel_p6(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter+100-1),.dina(8'h00),.douta(sobel_data_p6));
image_coe load_sobel_p7(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter+100),.dina(8'h00),.douta(sobel_data_p7));
image_coe load_sobel_p8(.clka(clk),.wea(1'h00),.addra(1078+sobel_counter+100+1),.dina(8'h00),.douta(sobel_data_p8));

// do sobel operation
sobel sobel(.p0(sobel_data_p0), .p1(sobel_data_p1), .p2(sobel_data_p2),
            .p3(sobel_data_p3), .p5(sobel_data_p5), 
            .p6(sobel_data_p6), .p7(sobel_data_p7), .p8(sobel_data_p8), 
            .out(sobel_data));

// output the operaton result
reg sobel_done = 0;
reg [bit_width-1:0] sobel_out;
always @(posedge clk)begin
    if(header_done)begin
        if(dosobel)begin
            if((sobel_counter >= 14'd0 && sobel_counter < 14'd100)||(sobel_counter >= 14'd9900 && sobel_counter < 14'd9999))begin 
                sobel_out <= 8'h00;
                sobel_counter <= sobel_counter + 14'd1;
                sobel_done <= 1'b1;
            end else if (sobel_counter == 14'd10000) begin
                sobel_out <= 8'h00;
                sobel_counter <= 14'd10000;
                sobel_done <= 1'b1;
            end else if((sobel_counter % 100 == 14'd0)||(sobel_counter % 100 == 14'd99))begin
                sobel_out <= 8'h00;
                sobel_counter <= sobel_counter + 14'd1;
                sobel_done <= 1'b1;
            end else begin
                sobel_out <= sobel_data;
                sobel_counter <= sobel_counter + 14'd1;
                sobel_done <= 1'b1;
            end
        end else begin
            sobel_out <= 8'h00;
            sobel_counter <= 14'd0;
            sobel_done <= 1'b0;   
        end
    end else begin
        sobel_out <= 8'h00;
        sobel_counter <= 14'd0;
        sobel_done <= 1'b0;
    end
end

wire [bit_width-1:0] data_out;
assign data_out = sobel_out;

endmodule

/*
if (sobel_counter == 14'd0)begin
                sobel_out <= 8'h01;
                sobel_counter <= sobel_counter + 14'd1;
                sobel_done <= 1'b1;
            end else 
*/