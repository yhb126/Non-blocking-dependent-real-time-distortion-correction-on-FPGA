`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xidian University
// Engineer: LDC
// 
// Create Date: 2025/02/20 10:55:03
// Design Name: Hongbo Yu
// Module Name: Polynomial_Correction_Unit
// Project Name: 
// Target Devices: 
// Tool Versions: 2018.3
// Description: 
//  多项式粗矫正处理全局畸变；Cycle = 2
//  可优化流水线级数，减少DSP数量 在不满足DSP条件下可以从此入手
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "./Parameter.vh"

module Polynomial_Correction_Unit(
    input                   clk,
    input                   rst_n,

    input [31:0]            x_in,
    input [31:0]            y_in,
    input [31:0]            coeffs[3:0], //[p2,p1,k2,k1]
    
    output [31:0]           x_out,
    output [31:0]           y_out
    );

    //-------------- wire define ----------------------------
    wire [63:0]             r_sq;
    wire [63:0]             factor;

    assign r_sq = (x_in*x_in) + (y_in*y_in);    // r^2
    assign factor = 1 + coeffs[0]*r_sq + coeffs[1]*r_sq*r_sq; // 1 + k1*r^2 + k2*r^4


    //-------------- reg define -----------------------------------
    reg [63:0]              x_corr;
    reg [63:0]              y_corr;
    reg [63:0]              x_corr_q;
    reg [63:0]              y_corr_q;
    reg [31:0]              x_in_q;
    reg [31:0]              y_in_q;
    reg [63:0]              x_final;
    reg [63:0]              y_final;

    //--------------- function block -----------------------

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_corr_q        <= 64'd0;
            y_corr_q        <= 64'd0;
            x_in_q          <= 32'd0;
            y_in_q          <= 32'd0;
        end else begin
            x_corr_q        <= x_corr;
            y_corr_q        <= y_corr;
            x_in_q          <= x_in;
            y_in_q          <= y_in;
        end
    end

    // Cycle = 1 -> 计算径向畸变  需考虑时序是否收敛
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_corr          <= 64'd0;
            y_corr          <= 64'd0;
        end else begin
            x_corr          <= x_in*factor;
            y_corr          <= y_in*factor;
        end
    end


    // Cycle = 2 -> 计算切向畸变
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_final         <= 64'd0;
            y_final         <= 64'd0;
        end else begin
            x_final         <= ((coeffs[2]*x_in_q*y_in_q) << 1) + (coeffs[3]* (3*x_in_q*x_in_q + y_in_q*y_in_q));
            y_final         <= ((coeffs[3]*x_in_q*y_in_q) << 1) + (coeffs[2]* (3*y_in_q*y_in_q + x_in_q*x_in_q));
        end
    end

    assign x_out = x_final[63:32];
    assign y_out = y_final[63:32];

endmodule
