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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ring_line_buffer#(
    parameter DEPTH = 128,
    parameter WIDTH = 1920
)(
    input               clk,
    input               rst_n,
    input [7:0]         pixel_in,
    input               pixel_in_en,
    input [15:0]        wr_y,       // From 0 to Depth

    input [15:0]        rd_x,       // Width
    input [15:0]        rd_y,       // Depth
    input               rd_en,
    output              pixel_out_en,
    output [7:0]        pixel_out_11,    
    output [7:0]        pixel_out_12,
    output [7:0]        pixel_out_21,
    output [7:0]        pixel_out_22
    );

    //----------- Reg define --------------------------
    reg [7:0] buffer [DEPTH-1:0] [WIDTH-1:0];
    reg [8:0] wr_ptr;
    reg [8:0] rd_ptr;
    reg [11:0]  data_cnt;

    reg [7:0] pixel_out_11;
    reg [7:0] pixel_out_12;
    reg [7:0] pixel_out_21;
    reg [7:0] pixel_out_22;
    //-------------------------------------------------


    //------------ Init Buffer -----------------------
    generate
        for(genvar i=0; i<DEPTH; i=i+1)begin
            for(genvar j=0; j<WIDTH;j=j+1)begin
                assign buffer[i][j] = 0;
            end
        end
    endgenerate
    //------------------------------------------------

//--------------------- Logic Block ------------------------------
    //--------------------- Write --------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_ptr      <= 9'd0;
        end
        else begin
            wr_ptr      <= wr_y % DEPTH;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_cnt    <= 12'd0;
        end
        else begin
            if(pixel_in_en) begin
                buffer[wr_ptr][data_cnt]    <= pixel_in;
                data_cnt                    <= (data_cnt == WIDTH) ? 12'd0 : (data_cnt + 1'b1);
            end
            else begin
                data_cnt                    <= 12'd0;
            end
        end
    end
    //---------------------------------------------------

    //-------------------- Read -------------------------
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rd_ptr      <= 9'd0;
        end
        else begin
            rd_ptr      <= rd_y % DEPTH;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pixel_out_en                  <= 1'b0;
            pixel_out_11                  <= 8'd0;
            pixel_out_12                  <= 8'd0;
            pixel_out_21                  <= 8'd0;
            pixel_out_22                  <= 8'd0;
        end
        else begin
            if(((wr_ptr - rd_y) >= 2) && rd_en) begin
                pixel_out_11              <= buffer[rd_ptr][rd_x];
                pixel_out_12              <= buffer[rd_ptr][rd_x + 1];
                pixel_out_21              <= buffer[rd_ptr+1][rd_x];
                pixel_out_22              <= buffer[rd_ptr+1][rd_x+1];
                pixel_out_en              <= 1'b1;
            end
            else if((rd_ptr == DEPTH -1) && (wr_ptr >= 1) && rd_en) begin
                pixel_out_11              <= buffer[rd_ptr][rd_x];
                pixel_out_12              <= buffer[rd_ptr][rd_x + 1];
                pixel_out_21              <= buffer[0][rd_x];
                pixel_out_22              <= buffer[0][rd_x+1];
                pixel_out_en              <= 1'b1;
            end
            else begin
                pixel_out_en                  <= 1'b0;
                pixel_out_11                  <= 8'd0;
                pixel_out_12                  <= 8'd0;
                pixel_out_21                  <= 8'd0;
                pixel_out_22                  <= 8'd0;
            end
        end
    end
    //---------------------------------------------------


endmodule
