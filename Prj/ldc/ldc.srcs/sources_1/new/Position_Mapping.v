`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/21 16:58:02
// Design Name: 
// Module Name: Position_Mapping
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "./Parameter.vh"
`define WIDTH 1920
`define HEIGHT 1080

module Position_Mapping(
    input               clk,
    input               rst_n,

    input               map_en,

    output [31:0]       x_out,
    output [31:0]       y_out
    );

    reg [31:0]          position_cnt;
    reg                 map_en_q;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            map_en_q                <= 1'd0;
        end     
        else begin  
            map_en_q                <= map_en;
        end 
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            position_cnt            <= 32'd0;
        end 
        else begin
            if({map_en,map_en_q} == 2'b10) begin
                position_cnt        <= 32'b0;
            end 
            else if(map_en) begin
                position_cnt        <= (position_cnt == (`HEIGHT * ` WIDTH)) ? 'd0 : (position_cnt + 1'b1);
            end
            else begin
                position_cnt        <= 1'd0;
            end
        end
    end
    
endmodule
