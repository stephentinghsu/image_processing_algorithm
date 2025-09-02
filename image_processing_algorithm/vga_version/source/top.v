`timescale 1ns / 1ps

`include "operate.v"

`define headersize 1078
`define row 100
`define column 100

`define bit_width 8
`define address_width 14

module top(clk, rst, func, red_out, green_out, blue_out, hsync_out, vsync_out);
input clk, rst, func;
output reg [3:0] red_out;
output reg [3:0] green_out;
output reg [3:0] blue_out;
output hsync_out;
output vsync_out;

parameter C_H_SYNC_PULSE  = 112, 
          C_H_BACK_PORCH  = 248,
          C_H_ACTIVE_TIME = 1280,
          C_H_FRONT_PORCH = 48,
          C_H_LINE_PERIOD = 1688;
       
parameter C_V_SYNC_PULSE   = 3, 
          C_V_BACK_PORCH   = 38,
          C_V_ACTIVE_TIME  = 1024,
          C_V_FRONT_PORCH  = 1,
          C_V_FRAME_PERIOD = 1066;

parameter C_IMAGE_WIDTH   = 100,
          C_IMAGE_HEIGHT  = 100,
          C_IMAGE_PIX_NUM = 10000;


// sobel and median operation
wire [bit_width-1:0] result_data;
wire [address_width-1:0] result_address;
operate operate(.clk(clk), .rst(rst), .func(func), .result_address(result_address), .result_data(result_data));

// using true dual bram to write in and read at the same time
wire [bit_width-1:0] blk_out;
wire [bit_width-1:0] bram_data;
reg [address_width-1:0] bram_address;
result_bram result_inout(.clka(clk),.wea(1'h01),.addra(result_address),.dina(result_data),.douta(blk_out),
                         .clkb(clk),.web(1'h00),.addrb(bram_address),.dinb(8'h00),.doutb(bram_data));

// since the vga display can only read 4 bit rather than 8 bit
wire [8:0] rgb_shift;
assign rgb_out = bram_data >> 4;
wire [3:0] rgb_out;
assign rgb_out = rgb_shift[3:0];


// horizontal sync count
reg [11:0] h_cnt;
always @(posedge clk or negedge rst)
begin
    if(!rst)
        h_cnt <= 12'd0;
    else if(h_cnt == C_H_LINE_PERIOD - 1'b1)
        h_cnt <= 12'd0;
    else
        h_cnt <= h_cnt + 1'b1;                
end                

assign hsync_out = (h_cnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1; 


// vertical sync count
reg [11:0] v_cnt;
always @(posedge clk or negedge rst)
begin
    if(!rst)
        v_cnt <=  12'd0   ;
    else if(v_cnt == C_V_FRAME_PERIOD - 1'b1)
        v_cnt <=  12'd0   ;
    else if(h_cnt == C_H_LINE_PERIOD - 1'b1)
        v_cnt <=  v_cnt + 1'b1  ;
    else
        v_cnt <=  v_cnt ;                        
end                

assign vsync_out = (v_cnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1; 


// output to vga
always @(posedge clk or negedge rst)
begin
    if(!rst)begin
        bram_address <= 14'd0;
    end else if(h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH)                   &&
                h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME) &&
                v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH)                   &&
                v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME) )
    begin
            if(h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                        )  &&
               h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_IMAGE_WIDTH  - 1'b1)  &&
               v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                        )  &&
               v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_IMAGE_HEIGHT - 1'b1)  )
            begin
                red_out <= rgb_out;
                green_out <= rgb_out;
                blue_out <= rgb_out;
                if(bram_address == C_IMAGE_PIX_NUM - 1'b1)
                    bram_address <= 14'd0;
                else
                    bram_address <= bram_address + 1'b1;        
                end
            else begin
                 red_out <= 4'd0;
                 green_out <= 4'd0;
                 blue_out <= 4'd0;
                 bram_address <= bram_address;
            end
    end else begin
        red_out <= 4'd0;
        green_out <= 4'd0;
        blue_out <= 4'd0;
        bram_address <= bram_address;
    end          
end


endmodule