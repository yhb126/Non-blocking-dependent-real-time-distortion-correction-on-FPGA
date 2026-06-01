`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 10:53:29
// Design Name: 
// Module Name: ring_ram_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 该模块负责环形行缓存功能实现，可自定义行缓存位宽和深度，当待处理坐标为浮点数时，输入坐标�?向上取整。输入坐�?(i,j),输出的点值为 D(i,j)，D(i+1,j),D(i,j+1),D(i+1,j+1)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "F:/Final_Design_byYhb/Prj/ldc_2018_3/Prj/ldc/ldc.srcs/sources_1/imports/new/Parameter.vh"


module ring_line_buffer_new #(
    parameter DEPTH = 256,
    parameter WIDTH = 1920,
    parameter HEIGHT = 1080,
    parameter SYNC = 580
)(
    input               clk,
    input               rst_n,
    input [7:0]         pixel_in,
    input               pixel_in_en,
    input [10:0]        wr_y,       

    input [15:0]        rd_x,       // Width
    input [15:0]        rd_y,       // Depth
    input               coor_en,

    input               frame_over,

    output                  o_correct_flag,
    output                  o_correct_err,
    output reg              corrected_req,
    output reg              pixel_out_en,
    output reg [7:0]        pixel_out_11,    
    output reg [7:0]        pixel_out_12,
    output reg [7:0]        pixel_out_21,
    output reg [7:0]        pixel_out_22
    );

    localparam WIDTH_DIV = WIDTH/2;


    //----------- Reg define --------------------------
    reg [7:0]                           pixel_in_q;
    wire [8:0]                          wr_ptr;
    wire [8:0]                          rd_ptr;
    reg [11:0]                          row_cnt;
    reg                                 corrected_flag;
    reg [11:0]                          col_cnt;

    reg [7:0]                           line_num;
    reg [15:0]                          x_temp;
    reg [15:0]                          y_temp;
    reg [15:0]                          x_temp_q;
    reg [15:0]                          y_temp_q;
    reg [15:0]                          x_temp_2q;
    reg [15:0]                          y_temp_2q;
    reg [15:0]                          x_temp_3q;
    reg [15:0]                          y_temp_3q;

    reg [11:0]                          out_pixel_cnt;
    reg                                 out_pixel_hsync;

    reg                                 out_pixel_hsync_q;
    reg                                 out_pixel_hsync_2q;
    reg                                 out_pixel_hsync_3q;
    reg                                 out_pixel_hsync_4q;
    reg                                 out_pixel_hsync_5q;

    // reg [8:0]                           o_line_num;
    //-------------------------------------------------


    //---------- ram singal define -------------------
    reg                                 ena1;
    reg                                 wea1;
    reg [`ADDR_DEPTH-1:0]               addra1;
    reg [7:0]                           dina1;
    reg                                 enb1;
    reg [`ADDR_DEPTH-1:0]               addrb1;
    wire [7:0]                          doutb1;                    

    reg                                 ena2;
    reg                                 wea2;
    reg [`ADDR_DEPTH-1:0]               addra2;
    reg [7:0]                           dina2;
    reg                                 enb2;
    reg [`ADDR_DEPTH-1:0]               addrb2;
    wire [7:0]                          doutb2;    

    reg                                 ena3;
    reg                                 wea3;
    reg [`ADDR_DEPTH-1:0]               addra3;
    reg [7:0]                           dina3;
    reg                                 enb3;
    reg [`ADDR_DEPTH-1:0]               addrb3;
    wire [7:0]                          doutb3;    

    reg                                 ena4;
    reg                                 wea4;
    reg [`ADDR_DEPTH-1:0]               addra4;
    reg [7:0]                           dina4;
    reg                                 enb4;
    reg [`ADDR_DEPTH-1:0]               addrb4;
    wire [7:0]                          doutb4;   

    wire [`ADDR_DEPTH-1:0]              frame_start_addr;
    wire                                corrected_finish;
    wire [7:0]                          correct_buffer_min_line;

    wire [`ADDR_DEPTH-1:0]              addrb_temp;
    //------------------------------------------------


    // assign wr_ptr = (wr_y + o_line_num) % DEPTH;
    // assign rd_ptr = (y_temp + line_num) % DEPTH;
    assign wr_ptr = wr_y % DEPTH;
    assign rd_ptr = y_temp;
    assign o_correct_flag = corrected_flag;
    assign corrected_finish = (!corrected_flag) & corrected_flag_q;
    assign o_correct_err = corrected_finish & pixel_in_en;
    assign correct_buffer_min_line = (`OFFSET_X < 0) ? (2 - (`OFFSET_X >> 1)) : 2;

    assign addrb_temp = rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] - WIDTH_DIV;

//=========================================================
//                      Logic Block 
//=========================================================


    //----------corrected_en singal-------------------
    reg                         corrected_flag_q;
    wire                        corrected_over;
    assign  corrected_over = (!corrected_flag) & corrected_flag_q;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            corrected_flag <= 1'd0;
        end
        else begin
            if(wr_y - rd_y == correct_buffer_min_line) begin
                corrected_flag <= 1'b1;
            end
            // else if(rd_ptr == wr_ptr) begin
            //     corrected_flag = 1'b0;
            // end
            else if((col_cnt == HEIGHT -1) && (row_cnt == WIDTH -1)) begin
                corrected_flag <= 1'b0;
            end
            else begin
                corrected_flag <= corrected_flag;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            corrected_flag_q    <= 1'd0;
        end
        else begin
            corrected_flag_q    <= corrected_flag;
        end
    end

    //------------ pixel_in_q-----------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pixel_in_q                  <= 8'd0;
        end
        else begin
            pixel_in_q                  <= pixel_in;
        end 
    end

    //------------output row/col cnt--------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            row_cnt                     <= 12'd0;
            col_cnt                     <= 12'd0;
        end
        else begin
            if(pixel_out_en) begin
                row_cnt                 <= (row_cnt == WIDTH-1) ? 'd0 : (row_cnt + 1'b1);
                if(row_cnt == WIDTH-1) begin
                    col_cnt             <= (col_cnt == HEIGHT-1) ? 'd0 : (col_cnt + 1'b1);
                end
            end
        end     
    end
    //--------------------------------------------------


    //--------------------------------------------------
    // (x_c,y_c)缓存，用于矫正开始判�?
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_temp                      <= 16'd0;
            y_temp                      <= 16'd0;
        end
        else begin
            if(coor_en) begin
                x_temp                      <= rd_x;
                y_temp                      <= rd_y % DEPTH;
            end
            else begin
                x_temp                      <= x_temp;
                y_temp                      <= y_temp;
            end 
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_temp_q                    <= 'd0;
            y_temp_q                    <= 'd0;
            x_temp_2q                    <= 'd0;
            y_temp_2q                    <= 'd0;
            x_temp_3q                    <= 'd0;
            y_temp_3q                    <= 'd0;
        end
        else begin
            x_temp_q                    <= x_temp;
            y_temp_q                    <= y_temp;
            x_temp_2q                   <= x_temp_q;
            y_temp_2q                   <= y_temp_q;
            x_temp_3q                   <= x_temp_2q;
            y_temp_3q                   <= y_temp_2q;
        end
    end
    //------------------------------------------------


    //---------------------------------------------------
    //Remember Frame over Line
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         line_num                    <= 8'd0;
    //     end
    //     else begin
    //         line_num                    <= (corrected_over) ? o_line_num : line_num;
    //     end
    // end
    //--------------------------------------------------

    //----- Line num------------------------------
    // 每帧结束后需要记录此时的缓存位置
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         o_line_num                  <= 'd0;
    //     end
    //     else begin
    //         o_line_num                  <= (frame_over) ? wr_ptr + 1 : o_line_num;
    //     end
    // end

//=========================================================
//                    RAM CTRL
//=========================================================

//------------------------------------------------------
    // ----------- ram_write -------------------
    reg                                 ram_row_sel; // 行�?�择
    reg                                 ram_col_sel;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ram_row_sel                 <= 1'b0;
            ram_col_sel                 <= 1'b0;
        end
        else begin
            ram_row_sel                 <= wr_y[0];
            if(pixel_in_en) begin
                ram_col_sel             <= ram_col_sel + 1'b1;
            end
        end 
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ena1                        <= 1'd0;
            wea1                        <= 1'd0;
            addra1                      <= 'd0;
            dina1                       <= 8'd0;
            ena2                        <= 1'd0;
            wea2                        <= 1'd0;
            addra2                      <= 'd0;
            dina2                       <= 8'd0;
            ena3                        <= 1'd0;
            wea3                        <= 1'd0;
            addra3                      <= 'd0;
            dina3                       <= 8'd0;
            ena4                        <= 1'd0;
            wea4                        <= 1'd0;
            addra4                      <= 'd0;
            dina4                       <= 8'd0;
        end
        else begin
            if(corrected_finish) begin // 帧间复位
                // a_en singal
                ena1                    <= 1'b0;
                ena2                    <= 1'b0;
                ena3                    <= 1'b0;
                ena4                    <= 1'b0;
                // a_we singal
                wea1                    <= 1'b0;
                wea2                    <= 1'b0;
                wea3                    <= 1'b0;
                wea4                    <= 1'b0;
                // a_addra singal
                addra1                  <= 'd0;
                addra2                  <= 'd0;
                addra3                  <= 'd0;
                addra4                  <= 'd0;
                // a_din singal
                dina1                   <= 'd0;
                dina2                   <= 'd0;
                dina3                   <= 'd0;
                dina4                   <= 'd0;
            end
            else
                case({ram_row_sel,ram_col_sel})
                2'b00 : begin
                    // a_en singal
                    ena1                    <= pixel_in_en;
                    ena2                    <= 1'b0;
                    ena3                    <= 1'b0;
                    ena4                    <= 1'b0;
                    // a_we singal
                    wea1                    <= pixel_in_en;
                    wea2                    <= 1'b0;
                    wea3                    <= 1'b0;
                    wea4                    <= 1'b0;
                    // a_addra singal
                    addra1                  <= (pixel_in_en) ? ((addra1 == ((WIDTH * DEPTH) >> 2)) ? 'd1 : (addra1 + 1'b1)) : addra1;
                    addra2                  <= addra2;
                    addra3                  <= addra3;
                    addra4                  <= addra4;
                    // a_din singal
                    dina1                   <= pixel_in;
                    dina2                   <= 'd0;
                    dina3                   <= 'd0;
                    dina4                   <= 'd0;
                end
                2'b01 : begin
                    // a_en singal
                    ena1                    <= 1'b0;
                    ena2                    <= pixel_in_en;
                    ena3                    <= 1'b0;
                    ena4                    <= 1'b0;
                    // a_we singal
                    wea1                    <= 1'b0;
                    wea2                    <= pixel_in_en;
                    wea3                    <= 1'b0;
                    wea4                    <= 1'b0;
                    // a_addra singal
                    addra1                  <= addra1;
                    addra2                  <= (pixel_in_en) ? ((addra2 == ((WIDTH * DEPTH) >> 2)) ? 'd1 : (addra2 + 1'b1)) : addra2;
                    addra3                  <= addra3;
                    addra4                  <= addra4;
                    // a_din singal
                    dina1                   <= 'd0;
                    dina2                   <= pixel_in;
                    dina3                   <= 'd0;
                    dina4                   <= 'd0;
                end
                2'b10 : begin
                    // a_en singal
                    ena1                    <= 1'b0;
                    ena2                    <= 1'b0;
                    ena3                    <= pixel_in_en;
                    ena4                    <= 1'b0;
                    // a_we singal
                    wea1                    <= 1'b0;
                    wea2                    <= 1'b0;
                    wea3                    <= pixel_in_en;
                    wea4                    <= 1'b0;
                    // a_addra singal
                    addra1                  <= addra1;
                    addra2                  <= addra2;
                    addra3                  <= (pixel_in_en) ? ((addra3 == ((WIDTH * DEPTH) >> 2)) ? 'd1 : (addra3 + 1'b1)) : addra3;
                    addra4                  <= addra4;
                    // a_din singal
                    dina1                   <= 'd0;
                    dina2                   <= 'd0;
                    dina3                   <= pixel_in;
                    dina4                   <= 'd0;
                end
                2'b11 : begin
                    // a_en singal
                    ena1                    <= 1'b0;
                    ena2                    <= 1'b0;
                    ena3                    <= 1'b0;
                    ena4                    <= pixel_in_en;
                    // a_we singal
                    wea1                    <= 1'b0;
                    wea2                    <= 1'b0;
                    wea3                    <= 1'b0;
                    wea4                    <= pixel_in_en;
                    // a_addra singal
                    addra1                  <= addra1;
                    addra2                  <= addra2;
                    addra3                  <= addra3;
                    addra4                  <= (pixel_in_en) ? ((addra4 == ((WIDTH * DEPTH) >> 2)) ? 'd1 : (addra4 + 1'b1)) : addra4;
                    // a_din singal
                    dina1                   <= 'd0;
                    dina2                   <= 'd0;
                    dina3                   <= 'd0;
                    dina4                   <= pixel_in;
                end
                default : begin
                    // a_en singal
                    ena1                    <= 1'b0;
                    ena2                    <= 1'b0;
                    ena3                    <= 1'b0;
                    ena4                    <= 1'b0;
                    // a_we singal
                    wea1                    <= 1'b0;
                    wea2                    <= 1'b0;
                    wea3                    <= 1'b0;
                    wea4                    <= 1'b0;
                    // a_addra singal
                    addra1                  <= 'd0;
                    addra2                  <= 'd0;
                    addra3                  <= 'd0;
                    addra4                  <= 'd0;
                    // a_din singal
                    dina1                   <= 'd0;
                    dina2                   <= 'd0;
                    dina3                   <= 'd0;
                    dina4                   <= 'd0;
                end
                endcase
        end
    end
    //----------------------------------------------

    //--------- ram_read -------------------------
    //-------- Optimization  critical warning -----------------
    // reg [`ADDR_DEPTH-1 : 0]                     addrb_temp;
    // reg [8:0]                                   rd_ptr_q;
    // reg                                         coor_en_q;
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         addrb_temp                      <= 'd0;
    //         rd_ptr_q                        <= 'd0;
    //         coor_en_q                       <= 'd0;
    //     end
    //     else begin
    //         rd_ptr_q                        <= rd_ptr;
    //         coor_en_q                       <= coor_en;
    //         addrb_temp                      <= rd_ptr[8:1]*WIDTH_DIV;
    //     end
    // end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            enb1                        <= 1'b0;
            enb2                        <= 1'b0;
            enb3                        <= 1'b0;
            enb4                        <= 1'b0;
            addrb1                      <= 'd0;
            addrb2                      <= 'd0;
            addrb3                      <= 'd0;
            addrb4                      <= 'd0;
        end
        else begin
            if(corrected_flag & coor_en) begin
                if(x_temp != WIDTH)
                    case({y_temp[0],x_temp[0]})
                        2'b11:begin
                            enb1                        <= 1'b1;
                            enb2                        <= 1'b1;
                            enb3                        <= 1'b1;
                            enb4                        <= 1'b1;
                            addrb1                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb2                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb3                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb4                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        end
                        2'b10:begin
                            enb1                        <= 1'b1;
                            enb2                        <= 1'b1;
                            enb3                        <= 1'b1;
                            enb4                        <= 1'b1;
                            addrb1                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb2                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                            addrb3                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb4                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                        end
                        2'b01:begin
                            enb1                        <= 1'b1;
                            enb2                        <= 1'b1;
                            enb3                        <= 1'b1;
                            enb4                        <= 1'b1;
                            addrb1                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1] + 1) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb2                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1] + 1) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            // addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1] + 1;
                            // addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : addrb_temp + 1;
                            addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : addrb_temp + 1;
                        end
                        2'b00:begin
                            enb1                        <= 1'b1;
                            enb2                        <= 1'b1;
                            enb3                        <= 1'b1;
                            enb4                        <= 1'b1;
                            addrb1                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1] + 1) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                            addrb2                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1]) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                            // addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] +1: (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1] +1;
                            // addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1]  : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1];
                            addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] +1: addrb_temp +1;
                            addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1]  : addrb_temp;
                        end
                        default :begin
                            enb1                        <= 1'b0;
                            enb2                        <= 1'b0;
                            enb3                        <= 1'b0;
                            enb4                        <= 1'b0;
                            addrb1                      <= 'd0;
                            addrb2                      <= 'd0;
                            addrb3                      <= 'd0;
                            addrb4                      <= 'd0;
                        end 
                    endcase
                else 
                    case({y_temp[0],x_temp[0]})
                    2'b11:begin
                        enb1                        <= 1'b1;
                        enb2                        <= 1'b1;
                        enb3                        <= 1'b1;
                        enb4                        <= 1'b1;
                        addrb1                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        addrb2                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        addrb3                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        addrb4                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                    end
                    2'b10:begin
                        enb1                        <= 1'b1;
                        enb2                        <= 1'b1;
                        enb3                        <= 1'b1;
                        enb4                        <= 1'b1;
                        addrb1                      <= rd_ptr[8:1]*WIDTH_DIV + (x_temp[15:1]-1) + 1;
                        addrb2                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                        addrb3                      <= rd_ptr[8:1]*WIDTH_DIV + (x_temp[15:1]-1) + 1;
                        addrb4                      <= rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                    end
                    2'b01:begin
                        enb1                        <= 1'b1;
                        enb2                        <= 1'b1;
                        enb3                        <= 1'b1;
                        enb4                        <= 1'b1;
                        addrb1                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1] + 1) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        addrb2                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1] + 1) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1] + 1;
                        // addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1] + 1;
                        // addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1] + 1;
                        addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : addrb_temp + 1;
                        addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : addrb_temp + 1;
                    end
                    2'b00:begin
                        enb1                        <= 1'b1;
                        enb2                        <= 1'b1;
                        enb3                        <= 1'b1;
                        enb4                        <= 1'b1;
                        addrb1                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + x_temp[15:1]) :rd_ptr[8:1]*WIDTH_DIV + x_temp[15:1];
                        addrb2                      <= (y_temp == HEIGHT) ? ((rd_ptr[8:1] -1)*WIDTH_DIV + (x_temp[15:1]-1) + 1) :rd_ptr[8:1]*WIDTH_DIV + (x_temp[15:1]-1) + 1;
                        // addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1];
                        // addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : (rd_ptr[8:1] - 1)*WIDTH_DIV + x_temp[15:1];
                        addrb3                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] : addrb_temp;
                        addrb4                      <= (rd_ptr == 0) ? (DEPTH/2 -1)*WIDTH_DIV + x_temp[15:1] + 1 : addrb_temp;
                    end
                    default :begin
                        enb1                        <= 1'b0;
                        enb2                        <= 1'b0;
                        enb3                        <= 1'b0;
                        enb4                        <= 1'b0;
                        addrb1                      <= 'd0;
                        addrb2                      <= 'd0;
                        addrb3                      <= 'd0;
                        addrb4                      <= 'd0;
                    end 
                endcase
            end
            else begin
                enb1                        <= 1'b0;
                enb2                        <= 1'b0;
                enb3                        <= 1'b0;
                enb4                        <= 1'b0;
                addrb1                      <= addrb1;
                addrb2                      <= addrb2;
                addrb3                      <= addrb3;
                addrb4                      <= addrb4;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pixel_out_11                <= 8'd0;
            pixel_out_12                <= 8'd0;
            pixel_out_21                <= 8'd0;
            pixel_out_22                <= 8'd0;
        end
        else begin
            case({y_temp_2q[0],x_temp_2q[0]})
                2'b11:begin
                    pixel_out_11                <= doutb1;
                    pixel_out_12                <= doutb2;
                    pixel_out_21                <= doutb3;
                    pixel_out_22                <= doutb4;
                end
                2'b10:begin
                    pixel_out_11                <= doutb2;
                    pixel_out_12                <= doutb1;
                    pixel_out_21                <= doutb4;
                    pixel_out_22                <= doutb3;
                end
                2'b01:begin
                    pixel_out_11                <= doutb3;
                    pixel_out_12                <= doutb4;
                    pixel_out_21                <= doutb1;
                    pixel_out_22                <= doutb2;
                end
                2'b00:begin
                    pixel_out_11                <= doutb4;
                    pixel_out_12                <= doutb3;
                    pixel_out_21                <= doutb2;
                    pixel_out_22                <= doutb1;
                end
                default :begin
                    pixel_out_11                <= doutb1;
                    pixel_out_12                <= doutb2;
                    pixel_out_21                <= doutb3;
                    pixel_out_22                <= doutb4;
                end 
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pixel_out_en                        <= 1'b0;
        end
        else begin
            pixel_out_en                        <= out_pixel_hsync_5q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            corrected_req                       <= 1'd0;
        end
        else begin
            corrected_req                       <= corrected_flag & out_pixel_hsync; 
        end
    end


    //---------- Output singal ------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_pixel_cnt                       <= 12'd0;
        end
        else begin
            if(corrected_flag) begin
                if(out_pixel_cnt == SYNC + WIDTH - 1) begin
                    out_pixel_cnt               <= 'd0;
                end
                else begin
                    out_pixel_cnt               <= out_pixel_cnt + 1'b1;
                end
            end
            else begin
                out_pixel_cnt                   <= 'd0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_pixel_hsync                     <= 'd0;
        end
        else begin
            if(corrected_flag) begin
                if(out_pixel_cnt < SYNC) begin
                    out_pixel_hsync             <= 'd0;
                end
                else begin
                    out_pixel_hsync             <= 1'b1;
                end
            end
        end
    end
    //--------------------------------------------------------

    //--------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_pixel_hsync_q                   <= 1'b0;    
            out_pixel_hsync_2q                  <= 1'b0;
            out_pixel_hsync_3q                  <= 1'b0;
            out_pixel_hsync_4q                  <= 1'b0;
            out_pixel_hsync_5q                  <= 1'b0;
        end
        else begin
            out_pixel_hsync_q                   <= out_pixel_hsync ;
            out_pixel_hsync_2q                  <= out_pixel_hsync_q;
            out_pixel_hsync_3q                  <= out_pixel_hsync_2q;
            out_pixel_hsync_4q                  <= out_pixel_hsync_3q;
            out_pixel_hsync_5q                  <= out_pixel_hsync_4q;
        end
    end


    //--------------------------------------------
    // wire [16:0] temp1;
    // wire [16:0] temp2;
    // wire [16:0] temp3;
    // wire [16:0] temp4;
    // assign temp1 = rd_ptr[8:1]*WIDTH/2 + x_temp[15:1] + 1;
    // assign temp2 = rd_ptr[8:1]*WIDTH/2 + (x_temp[15:1]-1) + 1;
    // assign temp3 = (rd_ptr[8:1] - 1)*WIDTH/2 + x_temp[15:1] + 1;
    // assign temp4 = (rd_ptr[8:1] - 1)*WIDTH/2 + (x_temp[15:1]-1) + 1;

    



    // blk_mem_gen_0 data_buffer_1 (
    //     .clka(clk),    // input wire clka
    //     .ena(ena1),      // input wire ena
    //     .wea(wea1),      // input wire [0 : 0] wea
    //     .addra(addra1),  // input wire [16 : 0] addra
    //     .dina(dina1),    // input wire [7 : 0] dina
    //     .clkb(clk),    // input wire clkb
    //     .enb(enb1),      // input wire enb
    //     .addrb(addrb1),  // input wire [16 : 0] addrb
    //     .doutb(doutb1)  // output wire [7 : 0] doutb
    // );
    // blk_mem_gen_0 data_buffer_2 (
    //     .clka(clk),    // input wire clka
    //     .ena(ena2),      // input wire ena
    //     .wea(wea2),      // input wire [0 : 0] wea
    //     .addra(addra2),  // input wire [16 : 0] addra
    //     .dina(dina2),    // input wire [7 : 0] dina
    //     .clkb(clk),    // input wire clkb
    //     .enb(enb2),      // input wire enb
    //     .addrb(addrb2),  // input wire [16 : 0] addrb
    //     .doutb(doutb2)  // output wire [7 : 0] doutb
    // );
    // blk_mem_gen_0 data_buffer_3 (
    //   .clka(clk),    // input wire clka
    //   .ena(ena3),      // input wire ena
    //   .wea(wea3),      // input wire [0 : 0] wea
    //   .addra(addra3),  // input wire [16 : 0] addra
    //   .dina(dina3),    // input wire [7 : 0] dina
    //   .clkb(clk),    // input wire clkb
    //   .enb(enb3),      // input wire enb
    //   .addrb(addrb3),  // input wire [16 : 0] addrb
    //   .doutb(doutb3)  // output wire [7 : 0] doutb
    // );
    // blk_mem_gen_0 data_buffer_4 (
    //   .clka(clk),    // input wire clka
    //   .ena(ena4),      // input wire ena
    //   .wea(wea4),      // input wire [0 : 0] wea
    //   .addra(addra4),  // input wire [16 : 0] addra
    //   .dina(dina4),    // input wire [7 : 0] dina
    //   .clkb(clk),    // input wire clkb
    //   .enb(enb4),      // input wire enb
    //   .addrb(addrb4),  // input wire [16 : 0] addrb
    //   .doutb(doutb4)  // output wire [7 : 0] doutb
    // );

    // xdil_dpram #(
    //     .NumWords       (`DEPTH*`WIDTH >> 2),
    //     .AddrBits       (`ADDR_DEPTH),
    //     .NumBits        (`NumberBits)
    // )u1_xdil_dpram(
    //     .wrclk (clk      ),
    //     .waddr (addra1   ),
    //     .we    (wea1     ),
    //     .wd    (dina1    ),
    //     .rdclk (clk      ),
    //     .raddr (addrb1   ),
    //     .rd    (doutb1    )
    // );

    // xdil_dpram #(
    //     .NumWords       (`DEPTH*`WIDTH >> 2),
    //     .AddrBits       (`ADDR_DEPTH),
    //     .NumBits        (`NumberBits)
    // )u2_xdil_dpram(
    //     .wrclk (clk      ),
    //     .waddr (addra2   ),
    //     .we    (wea2     ),
    //     .wd    (dina2    ),
    //     .rdclk (clk      ),
    //     .raddr (addrb2   ),
    //     .rd    (doutb2    )
    // );

    // xdil_dpram #(
    //     .NumWords       (`DEPTH*`WIDTH >> 2),
    //     .AddrBits       (`ADDR_DEPTH),
    //     .NumBits        (`NumberBits)
    // )u3_xdil_dpram(
    //     .wrclk (clk      ),
    //     .waddr (addra3   ),
    //     .we    (wea3     ),
    //     .wd    (dina3    ),
    //     .rdclk (clk      ),
    //     .raddr (addrb3   ),
    //     .rd    (doutb3    )
    // );

    // xdil_dpram #(
    //     .NumWords       (`DEPTH*`WIDTH >> 2),
    //     .AddrBits       (`ADDR_DEPTH),
    //     .NumBits        (`NumberBits)
    // )u4_xdil_dpram(
    //     .wrclk (clk      ),
    //     .waddr (addra4   ),
    //     .we    (wea4     ),
    //     .wd    (dina4    ),
    //     .rdclk (clk      ),
    //     .raddr (addrb4   ),
    //     .rd    (doutb4    )
    // );
    

endmodule
