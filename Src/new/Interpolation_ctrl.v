`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 17:08:18
// Design Name: 
// Module Name: Interpolation_ctrl
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


module Interpolation_ctrl(
    input                   clk,
    input                   rst_n,

    input [15:0]            float_x,
    input [15:0]            float_y,
    input                   interpola_en,
    input [7:0]             data_11,
    input [7:0]             data_12,
    input [7:0]             data_21,
    input [7:0]             data_22,

    output [7:0]            data_out,
    output                  data_out_en
    );

    Quadratic_Interpolation u1_Quadratic_Interpolation(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .float_x      (float_x      ),
        .float_y      (float_y      ),
        .interpola_en (interpola_en ),
        .data_11      (data_11      ),
        .data_12      (data_12      ),
        .data_21      (data_21      ),
        .data_22      (data_22      ),
        .data_out     (data_out     ),
        .data_out_en  (data_out_en  )
    );
    

endmodule
