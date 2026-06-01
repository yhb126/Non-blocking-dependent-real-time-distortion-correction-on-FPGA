`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/05 16:36:40
// Design Name: 
// Module Name: tb_buffer
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
`define HEIGHT 1080
`define WIDTH 1920


module tb_buffer();
    reg                 clk     ;
    reg                 rst_n   ;
    reg                 h_sync = 0   ;
    reg                 v_sync = 0   ;
    reg [7:0]           pixel_in = 0;
    reg [15:0]          wr_x    ;
    reg [15:0]          wr_y    ;
    reg                 coor_en   ;

    reg            wr_en;
    reg            rd_en;
    wire            fifo_rd_en;
    wire [31:0]     din;
    wire [31:0]     dout;
    wire [15:0]     rd_x    ;
    wire [15:0]     rd_y    ;
    wire            full;
    wire            empty;
    wire            almost_full;
    wire            almost_empty;

    reg [1:0] pixel;
    reg [11:0] row_cnt = 0;
    reg [11:0] col_cnt = 0;
    reg [23:0] cor_pixel_cnt = 0;
    reg corrected_flag;

    wire                pixel_out_en;
    wire                corrected_en;
    wire [7:0]          pixel_out_11;
    wire [7:0]          pixel_out_12;
    wire [7:0]          pixel_out_21;
    wire [7:0]          pixel_out_22;

    wire hsync;
    wire [31:0] dout_temp;
    assign hsync = h_sync & v_sync;
    assign din = {wr_x,wr_y};
    assign dout_temp = (rd_en) ? dout : 'd0;
    assign rd_x = dout_temp[31:16];
    assign rd_y = dout_temp[15:0];


    parameter PERIOD = 20;
   always #(PERIOD/2) clk = ~clk;
    initial begin
        rst_n           <= 1'b0;
        clk             <= 1'b0;
        coor_en           <= 'd0;
        wr_x            <= 'd1;
        wr_y            <= 'd1;
        #100
        rst_n           <= 1'b1;

        repeat(100) @(posedge clk);#1
        row_cnt         <= 'b0;
        col_cnt         <= 'b0;
        cor_pixel_cnt   <= 'd0;
        corrected_flag  <= 1'b1;
        #1
        ram_r_w_test;
        repeat(10000) @(posedge clk); #1
        row_cnt         <= 'b0;
        col_cnt         <= 'b0;
        cor_pixel_cnt   <= 'd0;
        corrected_flag  <= 1'b1;
        #1
        ram_r_w_test;
        repeat(10000) @(posedge clk); #1
        row_cnt         <= 'b0;
        col_cnt         <= 'b0;
        cor_pixel_cnt   <= 'd0;
        corrected_flag  <= 1'b1;
        #1
        ram_r_w_test;
        $finish;
    end 


    // task ram_write_test;
    // begin: loop1
    //     reg[11:0] i;
    //     reg[11:0] j;
    //     v_sync = 1;
    //     for(i=0 ; i<`HEIGHT; i=i+1) begin
    //         repeat(580) @(posedge clk); 
    //         #1 h_sync = 1;
    //         for(j=0;j<`WIDTH;j=j+1) begin
    //             @(posedge clk);
    //             case({i[0],j[0]})
    //             2'b00: pixel_in = 0;
    //             2'b01: pixel_in = 1;
    //             2'b10: pixel_in = 2;
    //             2'b11: pixel_in = 3;
    //             endcase
    //         end
    //         h_sync  = 0;
    //     end
    //     v_sync = 0;
    // end
    // endtask    

    task ram_r_w_test;
    begin: loop2
        while(corrected_flag) begin
            @(posedge clk);
            row_cnt     <= (row_cnt == (`WIDTH + 580 )) ? 'd0 : row_cnt + 1'b1;
            if(row_cnt == (`WIDTH + 580 )) begin
                col_cnt <= (col_cnt == `HEIGHT) ? col_cnt : col_cnt + 1'b1;
            end
            else begin
                col_cnt <= col_cnt;
            end

            if(col_cnt < `HEIGHT) begin
                v_sync <= 1;
            end
            else begin
                v_sync <= 0;
            end

            if(row_cnt < `WIDTH) begin
                h_sync <= 1;
            end
            else if((row_cnt >= `WIDTH) && (row_cnt < (`WIDTH + 580))) begin
                h_sync <= 0;
            end
            else begin
                h_sync <= h_sync;
            end

            case({col_cnt[0],row_cnt[0]})
            2'b00: pixel_in = 0;
            2'b01: pixel_in = 1;
            2'b10: pixel_in = 2;
            2'b11: pixel_in = 3;
            endcase

        if(rd_en) begin
            cor_pixel_cnt <= (cor_pixel_cnt == 1920*1080 - 1) ? 'd0 : cor_pixel_cnt + 1'b1;
           if(cor_pixel_cnt == 1920*1080 - 1) begin
            corrected_flag  <= 1'b0;
           end
        end

        if(!almost_full) begin
            wr_en       <= 1'b1;
        end
        else begin
            wr_en       <= 1'b0;
        end

        if(!almost_empty & corrected_en) begin
            rd_en       <= 1'b1;
            coor_en     <= 1'b1;
        end
        else begin
            rd_en       <= 1'b0;
            coor_en     <= 1'b0;
        end

        if(wr_en) begin
            wr_x    <= (wr_x == (`WIDTH)) ? 'd1 : (wr_x+ 1'b1);
            if(wr_x == (`WIDTH )) begin
                wr_y    <= (wr_y == (`HEIGHT)) ? 'd1 : (wr_y + 1'b1);
            end
        end

            //----------------------------------------
        end

    end
    endtask



    buffer_ctrl u_buffer_ctrl(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .h_sync       (hsync       ),
        .v_sync       (v_sync       ),
        .pixel_in     (pixel_in     ),
        .rd_x         (rd_y         ),
        .rd_y         (rd_x         ),
        .coor_en      (coor_en        ),
        .corrected_req(corrected_en ),
        .pixel_out_en (pixel_out_en ),
        .pixel_out_11 (pixel_out_11 ),
        .pixel_out_12 (pixel_out_12 ),
        .pixel_out_21 (pixel_out_21 ),
        .pixel_out_22 (pixel_out_22 )
    );


    position_fifo position_fifo_1 (
    .clk(clk),      // input wire clk
    .srst(!rst_n),    // input wire srst
    .din({wr_x,wr_y}),      // input wire [31 : 0] din
    .wr_en(wr_en),  // input wire wr_en
    .rd_en(corrected_en & !empty),  // input wire rd_en
    .dout(dout),    // output wire [15 : 0] dout
    .full(full),    // output wire full
    .almost_full(almost_full), 
    .empty(empty) , // output wire empty
    .almost_empty(almost_empty) 
);
    


endmodule
