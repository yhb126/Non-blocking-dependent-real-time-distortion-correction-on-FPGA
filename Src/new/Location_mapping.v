`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/27 14:51:19
// Design Name: 
// Module Name: Location_mapping
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

// `define LDC_TYPE 0 //0:桶形 1：枕�??(未实�??)
// `define FLOAT_WIDTH 24      // 24位定点数量化下对应矫正参�??
// `define K1 4
// // width*height\k   | k1  |  k2 |
// // 1920*1080        | 4   |  0  |
// // 1080*720


// `define HEIGHT 1080
// `define WIDTH 1920
// `define OFFSET_X 0
// `define OFFSET_Y 0

`include "F:/Final_Design_byYhb/Prj/ldc_2018_3/Prj/ldc/ldc.srcs/sources_1/imports/new/Parameter.vh"

module Location_mapping(
    input                                   clk,
    input                                   rst_n,

    input                                   corrected_en,

    output reg [15:0]                       int_x  ,
    output reg [15:0]                       int_y  ,
    output reg [15:0]                       float_x,
    output reg [15:0]                       float_y,
    output reg                              position_en
    );

    reg [11:0]                              x_position;
    reg [11:0]                              y_position;
    reg [10:0]                              x_cnt;
    reg [10:0]                              y_cnt;

    reg [11:0]                              x_q1;
    reg [11:0]                              y_q1;
    reg [11:0]                              x_q2;
    reg [11:0]                              y_q2;
    reg [47:0]                              r2; // 24int+24float
    reg [`FLOAT_WIDTH:0]                    r2_k; // 24bit int + 48 float
    reg [79:0]                              x_corrected;
    reg [79:0]                              y_corrected;

    reg [15:0]                              int_x_temp  ;
    reg [15:0]                              int_y_temp  ;
    reg [15:0]                              float_x_temp;
    reg [15:0]                              float_y_temp;

    reg                                     corrected_en_q1;
    reg                                     corrected_en_q2;
    reg                                     corrected_en_q3;
    reg                                     corrected_en_q4;
    reg                                     corrected_en_q5;


    wire [23:0]                             x2;
    wire [23:0]                             y2;
    wire [9:0]                              x_center;
    wire [9:0]                              y_center;
    wire                                    line_over;
    wire                                    frame_over;

    assign x_center = (`WIDTH >> 1) + `OFFSET_X;
    assign y_center = (`HEIGHT >> 1) + `OFFSET_Y; 
    assign x2 = x_position*x_position;
    assign y2 = y_position*y_position;
    assign line_over = (x_cnt == (`WIDTH - 1)) ? 1'b1 : 1'b0;
    assign frame_over = (line_over & (y_cnt == (`HEIGHT - 1))) ? 1'b1 : 1'b0;

    parameter FLOAT_WIDTH_DOUBLE = `FLOAT_WIDTH * 2;

    parameter   IDLE = 0,
                AREA1 = 1,
                AREA2 = 2,
                AREA3 = 3,
                AREA4 = 4;

    reg [2:0]                               cur_st;
    reg [2:0]                               nxt_st;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cur_st              <= IDLE;
        end
        else begin
            cur_st              <= nxt_st;
        end
    end

    always @(*) begin
        if(!rst_n) begin
            nxt_st              = IDLE;
        end
        else begin
            case(cur_st)
                IDLE: begin
                    nxt_st      = (corrected_en) ? AREA1 : IDLE;
                end
                AREA1: begin
                    if(x_cnt == x_center - 1) begin
                        nxt_st  = AREA2;
                    end
                    else begin
                        nxt_st  = AREA1;
                    end
                end
                AREA2: begin
                    if(line_over) begin
                        if(y_cnt == y_center - 1) begin
                            nxt_st  = AREA3;
                        end
                        else begin
                            nxt_st  = AREA1;
                        end
                    end
                    else begin
                        nxt_st  = AREA2;
                    end
                end
                AREA3: begin
                    if(x_cnt == x_center - 1) begin
                        nxt_st  = AREA4;
                    end
                    else begin
                        nxt_st  = AREA3;
                    end
                end
                AREA4: begin
                    if(line_over) begin
                        if(frame_over) begin
                            nxt_st  = IDLE;
                        end
                        else begin
                            nxt_st  = AREA3;
                        end
                    end
                    else begin
                        nxt_st  = AREA4;
                    end
                end
                default: nxt_st = IDLE;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_position              <= (`WIDTH >> 1) + `OFFSET_X;
            y_position              <= (`HEIGHT >> 1) + `OFFSET_Y;
        end
        else begin
            case(cur_st) 
            IDLE: begin
                x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                y_position              <= (`HEIGHT >> 1) + `OFFSET_Y;
                if(corrected_en) begin
                    x_position              <= x_position - 1'b1;
                    y_position              <= (`HEIGHT >> 1) + `OFFSET_Y;
                end
            end
            AREA1: begin
                if(corrected_en) begin
                    x_position              <= x_position - 1'b1;
                    y_position              <= y_position;
                end
                else begin
                    x_position              <= x_position;
                    y_position              <= y_position;
                end
            end
            AREA2: begin
                if(line_over) begin
                    x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                    y_position              <= y_position - 1'b1;
                end
                else begin
                    if(corrected_en) begin
                        x_position              <= x_position + 1'b1;
                        y_position              <= y_position;
                    end
                    else begin
                        x_position              <= x_position;
                        y_position              <= y_position;
                    end
                end
            end
            AREA3: begin
                if(line_over) begin
                    x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                    y_position              <= y_position;
                end
                else begin
                    if(corrected_en) begin
                        x_position              <= x_position - 1'b1;
                        y_position              <= y_position;
                    end
                    else begin
                        x_position              <= x_position;
                        y_position              <= y_position;
                    end
                end
            end
            AREA4: begin
                if(line_over) begin
                    if(y_cnt == `HEIGHT - 1) begin
                        x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                        y_position              <= (`HEIGHT >> 1) + `OFFSET_Y;
                    end
                    else begin
                        x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                        y_position              <= y_position + 1'b1;
                    end
                end
                else begin
                    if(corrected_en) begin
                        x_position              <= x_position + 1'b1;
                        y_position              <=  y_position;
                    end
                    else begin
                        x_position              <= x_position;
                        y_position              <= y_position;
                    end
                end
            end
            default: begin
                x_position              <= (`WIDTH >> 1) + `OFFSET_X;
                y_position              <= (`HEIGHT >> 1) + `OFFSET_Y;
            end
            endcase
        end
    end

    //-----------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_q1                         <= 12'd0;
            y_q1                         <= 12'd0;
            x_q2                         <= 12'd0;
            y_q2                         <= 12'd0;
        end 
        else begin
            x_q1                         <= x_position;
            y_q1                         <= y_position;
            x_q2                         <= x_q1;
            y_q2                         <= y_q1;
        end     
    end

    // Stage 1
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r2                          <= 48'd0;
        end 
        else begin
            r2                          <= ((x2 + y2) << `FLOAT_WIDTH);
        end 
    end
    // Stage 2
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r2_k                        <= 'd0;
        end
        else begin
            // r2_k                        <= (`LDC_TYPE) ? (1 << `FLOAT_WIDTH) + ((r2 * `K1) >> `FLOAT_WIDTH): (1 << `FLOAT_WIDTH) - ((r2 * `K1) >> `FLOAT_WIDTH);
            r2_k                        <= (`LDC_TYPE) ? ((1 << FLOAT_WIDTH_DOUBLE) + (r2 * `K1) >> `FLOAT_WIDTH): ((1 << FLOAT_WIDTH_DOUBLE) - (r2 * `K1) >> `FLOAT_WIDTH);
            
        end 
    end
    // Stage 3
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            int_x_temp                  <= 16'd0;
            int_y_temp                  <= 16'd0;
            float_x_temp                <= 16'd0;
            float_y_temp                <= 16'd0;
            x_corrected                 <= 'd0;
            y_corrected                 <= 'd0;
        end
        else begin
            x_corrected                 <= ((x_q2 <<`FLOAT_WIDTH) * r2_k) >> `FLOAT_WIDTH;
            y_corrected                 <= ((y_q2 <<`FLOAT_WIDTH) * r2_k) >> `FLOAT_WIDTH;
            int_x_temp                  <= x_corrected[((`FLOAT_WIDTH))+:16];
            float_x_temp                <= x_corrected[((`FLOAT_WIDTH -1))-:16];
            int_y_temp                  <= y_corrected[((`FLOAT_WIDTH))+:16];
            float_y_temp                <= y_corrected[((`FLOAT_WIDTH -1))-:16];
        end
    end
    //-----------------------------------------------

    //-----------------------------------------------
    reg [2:0]                           image_area_q1;
    reg [2:0]                           image_area_q2;
    reg [2:0]                           image_area_q3;
    reg [2:0]                           image_area_q4;
    reg [2:0]                           image_area_q5;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            image_area_q1               <= 3'd0;
            image_area_q2               <= 3'd0;
            image_area_q3               <= 3'd0;
            image_area_q4               <= 3'd0;
        end
        else begin
            image_area_q1               <= cur_st;
            image_area_q2               <= image_area_q1;
            image_area_q3               <= image_area_q2;
            image_area_q4               <= image_area_q3;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            int_x                       <= 16'd0;
            int_y                       <= 16'd0;
            float_x                     <= 16'd0;
            float_y                     <= 16'd0;
        end
        else begin
            // case(image_area_q4)
            // IDLE: begin
            //     int_x                   <= y_center - int_y_temp;
            //     float_x                 <= (1 << 16) - float_y_temp;
            //     int_y                   <= x_center - int_x_temp;
            //     float_y                 <= (1 << 16) - float_x_temp;
            // end
            // AREA1: begin
            //     int_x                   <= y_center - int_y_temp;
            //     float_x                 <= (1 << 16) - float_y_temp;
            //     int_y                   <= x_center - int_x_temp;
            //     float_y                 <= (1 << 16) - float_x_temp;
            // end
            // AREA2: begin
            //     int_x                   <= y_center - int_y_temp;
            //     float_x                 <= (1 << 16) - float_y_temp;
            //     int_y                   <= x_center + int_x_temp + 1;
            //     float_y                 <= float_x_temp;
            // end
            // AREA3: begin
            //     int_x                   <= y_center + int_y_temp + 1;
            //     float_x                 <= float_y_temp;
            //     int_y                   <= x_center - int_x_temp;
            //     float_y                 <= (1 << 16) - float_x_temp;
            // end
            // AREA4: begin
            //     int_x                   <= y_center + int_y_temp + 1;
            //     float_x                 <= float_y_temp;
            //     int_y                   <= x_center + int_x_temp + 1;
            //     float_y                 <= float_x_temp;
            // end
            // default: begin
            //     int_x                   <= int_x  ;
            //     float_x                 <= float_x;
            //     int_y                   <= int_y  ;
            //     float_y                 <= float_y;
            // end
            // endcase

            case(image_area_q4)
            IDLE: begin
                int_x                   <= x_center - int_x_temp;
                float_x                 <= (1 << 16) - float_x_temp;
                int_y                   <= y_center - int_y_temp;
                float_y                 <= (1 << 16) - float_y_temp;
            end
            AREA1: begin
                int_x                   <= x_center - int_x_temp;
                float_x                 <= (1 << 16) - float_x_temp;
                int_y                   <= y_center - int_y_temp;
                float_y                 <= (1 << 16) - float_y_temp;
            end
            AREA2: begin
                int_x                   <= x_center + int_x_temp + 1;
                float_x                 <= float_x_temp;
                int_y                   <= y_center - int_y_temp;
                float_y                 <= (1 << 16) - float_y_temp;
            end
            AREA3: begin
                int_x                   <= x_center - int_x_temp;
                float_x                 <= (1 << 16) - float_x_temp;
                int_y                   <= y_center + int_y_temp + 1;
                float_y                 <= float_y_temp;
            end
            AREA4: begin
                int_x                   <= x_center + int_x_temp + 1;
                float_x                 <= float_x_temp;
                int_y                   <= y_center + int_y_temp + 1;
                float_y                 <= float_y_temp;
            end
            default: begin
                int_x                   <= int_x  ;
                float_x                 <= float_x;
                int_y                   <= int_y  ;
                float_y                 <= float_y;
            end
            endcase
        end
    end
    //----------------------------------------------
    //-----------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_cnt                   <= 11'd0;
            y_cnt                   <= 11'd0;
        end
        else begin
            if(corrected_en) begin
                x_cnt               <= (line_over) ? 11'd0 : (x_cnt + 1'b1);
                if(line_over) begin
                    y_cnt   <= (frame_over) ? 11'd0 : (y_cnt + 1'b1);
                end
            end
            else begin
                x_cnt               <= (line_over) ? 11'd0 : x_cnt;
                if(line_over) begin
                    y_cnt   <= (frame_over) ? 11'd0 : y_cnt;
                end
            end
        end
    end
    //------------------------------------------------

    //-------- position_en -------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            position_en                       <= 1'b0;
            corrected_en_q1             <= 1'b0;
            corrected_en_q2             <= 1'b0;
            corrected_en_q3             <= 1'b0;
            corrected_en_q4             <= 1'b0;
            corrected_en_q5             <= 1'b0;
        end
        else begin
            corrected_en_q1             <= corrected_en;
            corrected_en_q2             <= corrected_en_q1;
            corrected_en_q3             <= corrected_en_q2;
            corrected_en_q4             <= corrected_en_q3;
            corrected_en_q5             <= corrected_en_q4;
            position_en                       <= corrected_en_q4;
        end
    end
    //--------------------------------------------------

    // reg [11:0]                          line_cnt;
    // reg [11:0]                          row_cnt;

    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         line_cnt                    <= 12'd0;    
    //         row_cnt                     <= 12'd0;
    //     end
    //     else begin
    //         if ((position_en)) begin
    //             line_cnt                <=(line_cnt == 1919) ? ('d0) : line_cnt + 1'b1;
    //             if(line_cnt == 1919) begin
    //                 row_cnt             <= row_cnt + 1'b1;
    //             end 
    //         end
    //     end
    // end

endmodule
