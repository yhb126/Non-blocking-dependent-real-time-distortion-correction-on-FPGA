`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xidian University
// Engineer: Hongbo Yu
// 
// Create Date: 2025/02/18 20:08:08
// Design Name: 
// Module Name: Position_Normalization
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

module Position_Normalization #(
    parameter FRAC_BITS = 16        /// 浮点数精度
    )(
        input                              clk,
        input                              rst_n,    

        input [15:0]                       x_raw,
        input [15:0]                       y_raw,
        input [7:0]                        grid_scale, // 缩放尺度，取2时，归一化坐标范围为[-1,1]，可根据要求自适应放大

        output signed [31:0]               x_norm,
        output signed [31:0]               y_norm
    );

    // Center Position
    wire [31:0] center_x ;
    wire [31:0] center_y ;
    assign center_x = ((`WIDTH - 1) >> 1) * (1 << FRAC_BITS);
    assign center_y = ((`HEIGHT - 1) >> 1) * (1 << FRAC_BITS);

    reg [15:0] scale_factor;

    reg signed [31:0] x_offset;
    reg signed [31:0] y_offset;

    reg [31:0] x_norm;
    reg [31:0] y_norm;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            scale_factor                 <= 8'd0;
        end else begin
            scale_factor                 <= (1 << grid_scale);
        end
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_offset                <= 32'd0;
            y_offset                <= 32'd0;
        end else begin
            x_offset                <= ($signed(x_raw) << FRAC_BITS) - center_x;
            y_offset                <= ($signed(y_raw) << FRAC_BITS) - center_y;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_norm                  <= 32'd0;
            y_norm                  <= 32'd0;
        end else begin
            x_norm                  <= (x_offset * scale_factor) / (`WIDTH);
            y_norm                  <= (y_offset * scale_factor) / (`HEIGHT);
        end
    end
endmodule
