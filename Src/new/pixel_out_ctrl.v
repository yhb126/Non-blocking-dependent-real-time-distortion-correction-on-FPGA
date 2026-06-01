`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 15:21:05
// Design Name: 
// Module Name: pixel_out_ctrl
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


module pixel_out_ctrl(
    input       clk,
    input       rst_n,

    input       correct_flag,
    input       pixel_in_en,
    input [7:0] pixel_in,

    output      o_v_sync,
    output      o_h_sync,
    output[7:0] o_pixel
    );
    assign o_h_sync = pixel_in_en;
    assign o_v_sync = correct_flag;
    assign o_pixel = pixel_in;

endmodule
