`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 15:50:40
// Design Name: 
// Module Name: ldc_top
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
`include "F:/Final_Design_byYhb/Prj/ldc_2018_3/Prj/ldc/ldc.srcs/sources_1/imports/new/Parameter.vh"

module ldc_top(
    input               clk,
    input               rst_n,

    input               i_v_sync,
    input               i_h_sync,
    input [7:0]         i_pixel,

    output              o_v_sync,
    output              o_h_sync,
    output [7:0]        o_pixel
    );

    wire [15:0]                         int_x       ;
    wire [15:0]                         int_y       ;
    wire [15:0]                         i_float_x     ;
    wire [15:0]                         i_float_y     ;
    wire [15:0]                         o_float_x     ;
    wire [15:0]                         o_float_y     ;
    wire [15:0]                         o_int_x        ;
    wire [15:0]                         o_int_y        ;


    wire                                coor_en     ;
    wire                                corrected_en;
    wire                                corrected_req;
    wire                                correct_flag;
    wire                                position_en       ;
    wire                                pixel_out_en;
    wire [7:0]                          pixel_out_11;
    wire [7:0]                          pixel_out_12;
    wire [7:0]                          pixel_out_21;
    wire [7:0]                          pixel_out_22;
    wire                                data_out_en;
    wire [7:0]                          data_out;



    Location_mapping u1_Location_mapping(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .corrected_en (corrected_en ),
        .int_x        (int_x        ),
        .int_y        (int_y        ),
        .float_x      (o_float_x      ),
        .float_y      (o_float_y      ),
        .position_en  (position_en        )
    );
    

    buffer_ctrl#(
        .DEPTH        (`DEPTH),
        .WIDTH        (`WIDTH),
        .HEIGHT       (`HEIGHT),
        .SYNC         (`SYNC)
    )
     u2_buffer_ctrl(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .h_sync       (i_h_sync     ),
        .v_sync       (i_v_sync     ),
        .pixel_in     (i_pixel      ),
        .rd_x         (o_int_x      ),
        .rd_y         (o_int_y      ),
        .coor_en      (coor_en      ),
        .correct_flag (correct_flag),
        .corrected_req(corrected_req ),
        .pixel_out_en (pixel_out_en ),
        .pixel_out_11 (pixel_out_11 ),
        .pixel_out_12 (pixel_out_12 ),
        .pixel_out_21 (pixel_out_21 ),
        .pixel_out_22 (pixel_out_22 )
    );


    Interpolation_ctrl u3_Interpolation_ctrl(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .float_x      (i_float_x      ),
        .float_y      (i_float_y      ),
        .interpola_en (pixel_out_en ),
        .data_11      (pixel_out_11 ),
        .data_12      (pixel_out_12 ),
        .data_21      (pixel_out_21 ),
        .data_22      (pixel_out_22 ),
        .data_out     (data_out     ),
        .data_out_en  (data_out_en  )
    );
    
    fifo_ctrl u4_fifo_ctrl(
        .clk           (clk           ),
        .rst_n         (rst_n         ),
        .i_int_x       (int_x       ),
        .i_int_y       (int_y       ),
        .i_float_x     (o_float_x     ),
        .i_float_y     (o_float_y     ),
        .position_en   (position_en   ),
        .corrected_req (corrected_req ),
        .pixel_out_en  (pixel_out_en  ),
        .o_int_x       (o_int_x       ),
        .o_int_y       (o_int_y       ),
        .o_float_x     (i_float_x     ),
        .o_float_y     (i_float_y     ),
        .coor_en       (coor_en       ),
        .corrected_en  (corrected_en  )
    );

    pixel_out_ctrl u5_pixel_out_ctrl(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .correct_flag (correct_flag ),
        .pixel_in_en  (data_out_en  ),
        .pixel_in     (data_out     ),
        .o_v_sync     (o_v_sync     ),
        .o_h_sync     (o_h_sync     ),
        .o_pixel      (o_pixel      )
    );
    




endmodule
