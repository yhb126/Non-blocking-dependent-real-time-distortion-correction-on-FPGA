`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 16:15:16
// Design Name: 
// Module Name: buffer_ctrl
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


module buffer_ctrl#(
    parameter DEPTH = 256,
    parameter WIDTH = 1920,
    parameter HEIGHT = 1080,
    parameter SYNC = 580
)(
    input               clk,
    input               rst_n,
    input               h_sync,
    input               v_sync,
    input [7:0]         pixel_in,

    input [15:0]        rd_x,       // Width
    input [15:0]        rd_y,       // Depth
    input               coor_en,
    output              correct_flag,
    output              corrected_req,
    output              pixel_out_en,
    output [7:0]        pixel_out_11,    
    output [7:0]        pixel_out_12,
    output [7:0]        pixel_out_21,
    output [7:0]        pixel_out_22
    );

    //--------------- Wire Define -------------------
    wire                pixel_in_en;
    wire                frame_over;
    wire                line_over;
    wire                frame_start;
    wire                line_start;
    wire                corrected_req_temp;
    wire                correct_flag;
    wire                rst_over;
    wire                o_correct_err;
    //-----------------------------------------------

    
    //-------------- Reg Define ---------------------
    reg [10:0]          wr_y;
    reg                h_sync_q;
    reg                v_sync_q;
    reg                 line_over_q;
    //----------------------------------------------

    //----------------------------------------------
    // assign pixel_in_en = h_sync & v_sync;
    // assign line_start = h_sync & (!h_sync_q);
    // assign line_over = (!h_sync) & h_sync_q;
    // assign frame_over = (!v_sync) & v_sync_q;
    // assign frame_start = v_sync & (!v_sync_q);
    // assign corrected_req = corrected_req_temp | frame_start; //每帧优先读取第一个矫正像素点
    //----------------------------------------------



    //--------------- Logic Block-----------------

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            h_sync_q                <= 1'b0;
        end
        else begin
            h_sync_q                <= h_sync;
        end 
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            v_sync_q                <= 1'b0;
        end
        else begin
            v_sync_q                <= v_sync;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            line_over_q             <= 1'b0;
        end
        else begin
            line_over_q             <= line_over;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_y                <= 11'd0;
        end
        else begin
            if(line_over & v_sync) begin
                wr_y            <= wr_y + 1'b1;
            end
            else if(frame_start) begin
                wr_y            <= 'd0;
            end
            else begin
                wr_y            <= wr_y;
            end
        end
    end

    //--------------------------------------------

    reg [11:0]              pixel_in_cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pixel_in_cnt        <= 'd0;
        end
        else begin
            if(pixel_in_en) begin
                pixel_in_cnt    <= pixel_in_cnt + 1'b1;
            end
            else begin
                pixel_in_cnt    <= 'd0;
            end
        end
    end


    //----------------------------------------------
    assign pixel_in_en = h_sync & v_sync;
    assign line_start = h_sync & (!h_sync_q);
    assign line_over = (!h_sync) & h_sync_q;
    assign frame_over = (!v_sync) & v_sync_q;
    assign frame_start = v_sync & (!v_sync_q);
    assign corrected_req = corrected_req_temp; //每帧优先读取第一个矫正像素点
    //----------------------------------------------


    

    ring_line_buffer #(
        .DEPTH        (DEPTH),
        .WIDTH        (WIDTH),
        .HEIGHT       (HEIGHT),
        .SYNC         (SYNC)
    ) u_ring_line_buffer (
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .pixel_in     (pixel_in     ),
        .pixel_in_en  (pixel_in_en  ),
        .wr_y         (wr_y         ),

        .rd_x         (rd_x         ),
        .rd_y         (rd_y         ),
        .coor_en      (coor_en        ),
        .frame_over   (frame_over   ),
        .o_correct_flag (correct_flag),
        .corrected_req(corrected_req_temp),
        .o_correct_err  (o_correct_err),
        .pixel_out_en (pixel_out_en ),
        .pixel_out_11 (pixel_out_11 ),
        .pixel_out_12 (pixel_out_12 ),
        .pixel_out_21 (pixel_out_21 ),
        .pixel_out_22 (pixel_out_22 )
    );
    

endmodule
