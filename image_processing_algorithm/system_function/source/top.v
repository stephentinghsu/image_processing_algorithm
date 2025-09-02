`timescale 1ns / 1ps

`include "sobel_mod.v"
`include "median_mod.v"

`define headersize 1078
`define row 100
`define column 100

`define bit_width 8
`define address_width 14

module top(clk, start, dosobel, domedian, sobel_success, median_success);

input clk, start, dosobel, domedian;
output wire sobel_success, median_success;

//create a clock half clock delay
wire delay_clk;
assign delay_clk = clk^1'b1;

// create file
integer create_sobel;
integer create_median;
initial begin
    create_sobel = $fopen("C:/Users/downloads/image_processing_fwrite/lenna_sobel.bmp","wb");
    create_median = $fopen("C:/Users/downloads/image_processing_fwrite/lenna_median.bmp","wb");
end

// header ///////////////////////////////////////////////////////////////////////////////////
// a clock where header can start to write in
wire header_can_in;
assign header_can_in = start & delay_clk;

// load header data
wire [bit_width-1:0] header_data;
reg [address_width-1:0] header_write_counter = 14'd0;
image_coe load_header (.clka(clk), .wea(1'h00), .addra(header_write_counter), .dina(8'h00),.douta(header_data));

// counte header number
always @(posedge header_can_in)begin
    if(start)begin
        if(header_write_counter < 14'd11077)begin
            header_write_counter <= header_write_counter + 14'd1;
        end else begin
            header_write_counter <= header_write_counter;
        end
    end else begin
        header_write_counter <= 14'd0;
    end
end

// write header into file
reg header_done = 0;
always @(posedge header_can_in)begin
    if(header_write_counter < 14'd1078)begin
        $fwrite(create_sobel, "%c", header_data);
        $fwrite(create_median, "%c", header_data);
    end else begin
        header_done <= 1'b1;
    end
end


// sobel ////////////////////////////////////////////////////////////////////////////////////
// sobel operation result
wire [bit_width-1:0] sobel_data_out;
wire sobel_done;
sobel_mod sobeling(.clk(clk), .dosobel(dosobel), .header_done(header_done), .data_out(sobel_data_out), .sobel_done(sobel_done));

// a clock where sobel result can start to write in
wire sobel_can_in;
assign sobel_can_in = sobel_done & delay_clk;

// counte sobel number
reg [address_width-1:0] sobel_write_counter;
initial begin sobel_write_counter = 14'd0;end
always @(negedge sobel_can_in)begin
    if(sobel_done == 1'b1)begin
        if(sobel_write_counter < 14'd10000)begin
            sobel_write_counter <= sobel_write_counter + 14'd1;
        end else begin
            sobel_write_counter <= sobel_write_counter;
        end
    end else begin
        sobel_write_counter <= 14'd0;
    end
end

// close file when sobel finish
reg sobel_finish = 0;
always @(posedge sobel_can_in)begin
    if(sobel_write_counter < 14'd10000)begin
        $fwrite(create_sobel, "%c", sobel_data_out);
    end else begin
        $fwrite(create_sobel, "%c", sobel_data_out);
        $fclose(create_sobel);
        sobel_finish <= 1'b1;
    end
end

assign sobel_success = sobel_finish;


// median ///////////////////////////////////////////////////////////////////////////////////
// median operation result
wire [bit_width-1:0] median_data_out;
wire median_done;
median_mod medianing(.clk(clk), .domedian(domedian), .header_done(header_done), .data_out(median_data_out), .median_done(median_done));

// a clock where median result can start to write in
wire median_can_in;
assign median_can_in = median_done & delay_clk;

// counte median number
reg [address_width-1:0] median_write_counter = 0;
initial begin median_write_counter = 14'd0;end
always @(negedge median_can_in)begin
    if(median_done == 1'b1)begin
        if(median_write_counter < 14'd10000)begin
            median_write_counter <= median_write_counter + 14'd1;
        end else begin
            median_write_counter <= median_write_counter;
        end
    end else begin
        median_write_counter <= 14'd0;
    end
end

// close file when median finish
reg median_finish = 0;
always @(posedge median_can_in)begin
    if(median_write_counter < 14'd10000)begin
        $fwrite(create_median, "%c", median_data_out);
    end else begin
        $fwrite(create_median, "%c", median_data_out);
        $fclose(create_median);
        median_finish <= 1'b1;
    end
end

assign median_success = median_finish;


endmodule