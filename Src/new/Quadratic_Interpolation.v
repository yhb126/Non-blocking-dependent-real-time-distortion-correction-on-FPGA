`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 15:06:21
// Design Name: 
// Module Name: Quadratic_Interpolation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 2 Cycles
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Quadratic_Interpolation(
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
    output reg                  data_out_en
    );

    //------- reg define ----------------
    reg [39:0]              x_top;
    reg [39:0]              x_bottom;
    reg [23:0]              x_top_q;
    reg [23:0]              x_bottom_q;
    reg [15:0]              float_x_q;
    reg [15:0]              float_y_q;
    reg [15:0]              float_x_2q;
    reg [15:0]              float_y_2q;
    reg [15:0]              float_x_rev;
    reg [15:0]              float_y_rev;
    reg                     interpola_en_q;
    reg                     interpola_en_2q;
    reg                     interpola_en_3q;
    reg                     interpola_en_4q;

    reg [48:0]               data_out_temp;

    reg [7:0]               data_11_q;
    reg [7:0]               data_12_q;
    reg [7:0]               data_21_q;
    reg [7:0]               data_22_q;       
    reg [7:0]               data_11_2q;
    reg [7:0]               data_12_2q;
    reg [7:0]               data_21_2q;
    reg [7:0]               data_22_2q; 
    
    //-----------------------------------


    assign data_out = (data_out_temp[31]) ? data_out_temp[32+:8] + 1'b1:data_out_temp[32+:8];

//----------- Logic Block------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_top_q         <= 'd0;
            x_bottom_q      <= 'd0;
            interpola_en_q  <= 1'd0;
            interpola_en_2q <= 1'd0;
            float_x_q       <= 16'd0;
            float_y_q       <= 16'd0;
            float_x_2q      <= 16'd0;
            float_y_2q      <= 16'd0;
            float_x_rev     <= 16'd0;
            float_y_rev     <= 16'd0;
        end
        else begin
            x_top_q         <= x_top >> 16;
            x_bottom_q      <= x_bottom >> 16;
            float_x_q       <= float_x;
            float_y_q       <= float_y;
            float_x_2q      <= float_x_q;
            float_y_2q      <= float_y_q;
            float_x_rev     <= 65535 - float_x;
            float_y_rev     <= 65535 - float_y_q;
            {interpola_en_3q,interpola_en_2q,interpola_en_q} <= {interpola_en_2q,interpola_en_q,interpola_en};
            interpola_en_4q <= interpola_en_3q;
        end 
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_11_q           <= 'd0;
            data_12_q           <= 'd0;
            data_21_q           <= 'd0;
            data_22_q           <= 'd0;
            data_11_2q          <= 'd0;
            data_12_2q          <= 'd0;
            data_21_2q          <= 'd0;
            data_22_2q          <= 'd0;
        end
        else begin
            data_11_q           <= data_11;
            data_12_q           <= data_12;
            data_21_q           <= data_21;
            data_22_q           <= data_22;
            data_11_2q          <= data_11_q;
            data_12_2q          <= data_12_q;
            data_21_2q          <= data_21_q;
            data_22_2q          <= data_22_q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_bottom        <= 'd0;
            x_top           <= 'd0;
        end
        else begin
            if(interpola_en_q) begin
                x_top       <= (data_11_2q << 16) * (float_x_rev) + (data_12_2q << 16)*float_x_q;
                x_bottom    <= (data_21_2q << 16) * (float_x_rev) + (data_22_2q << 16)*float_x_q;
            end
            else begin
                x_top       <= x_top;
                x_bottom    <= x_bottom;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out_temp        <= 'd0;
        end
        else begin
            data_out_temp        <= (((x_top >> 16)*(float_y_rev) + (x_bottom >> 16)*float_y_2q));
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out_en            <= 'd0;
        end
        else begin
            data_out_en            <= interpola_en_3q;
        end
    end

endmodule
 