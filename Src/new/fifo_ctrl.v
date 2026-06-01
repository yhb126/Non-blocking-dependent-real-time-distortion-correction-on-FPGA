`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/17 16:17:23
// Design Name: 
// Module Name: fifo_ctrl
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


module fifo_ctrl(
    input               clk,
    input               rst_n,

    input [15:0]        i_int_x,
    input [15:0]        i_int_y,
    input [15:0]        i_float_x,
    input [15:0]        i_float_y,

    input               position_en,
    input               corrected_req,
    input               pixel_out_en,

    output reg [15:0]       o_int_x,
    output reg [15:0]       o_int_y,
    output [15:0]       o_float_x,
    output [15:0]       o_float_y,

    output              coor_en,
    output              corrected_en
    );

    wire [31:0]                         din1;
    wire                                wr_en1;
    wire                                rd_en1;
    wire [31:0]                         dout1;
    wire                                full1;
    wire                                almost_full1;
    wire                                empty1;
    wire                                almost_empty;
    wire [31:0]                         din2;
    wire                                wr_en2;
    wire                                rd_en2;
    wire [31:0]                         dout2;
    wire                                full2;
    wire                                almost_full2;
    wire                                empty2;
    wire                                almost_empty2;
    reg                                 rd_en_q;
    reg                                 rd_en_2q;

    wire [15:0]                          int_x;
    wire [15:0]                          int_y;
    reg [15:0]                          o_int_y_mod;


    reg [3:0]           fifo_data_cnt;

    reg                 advanced_read;
    wire                advanced_read_flag;
    assign              advanced_read_flag = advanced_read & !empty1;

    assign coor_en = rd_en_2q;
    assign corrected_en = (fifo_data_cnt[3]) & rst_n ? 1'b0 : 1'b1;

    assign din1 = {i_int_x,i_int_y};
    assign wr_en1 = position_en & !almost_full1;
    assign rd_en1 = (corrected_req & !empty1) | advanced_read_flag;
    assign {int_x,int_y} = dout1;

    assign din2 = {i_float_x,i_float_y};
    assign wr_en2 = wr_en1;
    assign rd_en2 = pixel_out_en;
    assign {o_float_x,o_float_y} = dout2;
    

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rd_en_q                         <= 'd0;
            rd_en_2q                        <= 'd0;
        end
        else begin
            rd_en_q                         <= rd_en1;
            rd_en_2q                        <= rd_en_q;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            o_int_x                         <= 'd0;
            o_int_y                         <= 'd0;
            o_int_y_mod                     <= 'd0;
        end
        else begin
            o_int_x                         <= int_x;
            o_int_y                         <= int_y;
        end
    end

    //---------- fifo_depth = 16 -----------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_data_cnt                   <= 'd0;
        end
        else begin
            if(rd_en1 && wr_en1) begin
                fifo_data_cnt               <= fifo_data_cnt;
            end
            else if(rd_en1) begin
                fifo_data_cnt               <= fifo_data_cnt - 1'b1;
            end
            else if(wr_en1) begin
                fifo_data_cnt               <= fifo_data_cnt + 1'b1;
            end
        end
    end


    //--------------------------------------------
    // After the reset, a coordinate is read for the correction start judgment, 
    // and the part is only performed once after the reset
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            advanced_read       <= 1'b1;
        end
        else begin
            if(advanced_read & !empty1) begin
                advanced_read   <= 1'b0;
            end
        end
    end



    position_fifo position_fifo_int (
        .clk(clk),      // input wire clk
        .srst(!rst_n),    // input wire srst
        .din(din1),      // input wire [31 : 0] din
        .wr_en(wr_en1),  // input wire wr_en
        .rd_en(rd_en1),  // input wire rd_en
        .dout(dout1),    // output wire [31 : 0] dout
        .full(full1),    // output wire full
        .almost_full(almost_full1), 
        .empty(empty1) , // output wire empty
        .almost_empty(almost_empty1) 
    );

    position_fifo position_fifo_float (
        .clk(clk),      // input wire clk
        .srst(!rst_n),    // input wire srst
        .din(din2),      // input wire [31 : 0] din
        .wr_en(wr_en2),  // input wire wr_en
        .rd_en(rd_en2),  // input wire rd_en
        .dout(dout2),    // output wire [31 : 0] dout
        .full(full2),    // output wire full
        .almost_full(almost_full2), 
        .empty(empty2) , // output wire empty
        .almost_empty(almost_empty2) 
    );


endmodule
