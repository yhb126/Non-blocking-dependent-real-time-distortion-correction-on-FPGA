`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/03 11:48:41
// Design Name: 
// Module Name: tb_location_mapping
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


module tb_location_mapping();   
    reg                     clk;
    reg                     rst_n;
    reg                     corrected_en;

    wire [15:0]             int_x  ;
    wire [15:0]             int_y  ;
    wire [15:0]             float_x;
    wire [15:0]             float_y;
    wire                    rd_en  ;

    parameter PERIOD = 20;

    initial begin
        rst_n           = 1'b0;
        clk             = 1'b0;
        #200
        rst_n           = 1'b1;
    end

    always #(PERIOD)  clk = !clk;

    reg [63:0]              data_cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            corrected_en        <= 1'b0;
            data_cnt            <= 'd0;
        end
        else begin
            data_cnt            <= (data_cnt == (1920*1280)) ? 'd0 : (data_cnt + 1'b1);
            if((data_cnt >= 2) && (data_cnt <= 10)) begin
                corrected_en    <= 1'b0;
            end
            else if((data_cnt >= 1920*100) && (data_cnt <= 1920*101)) begin
                corrected_en    <= 1'b0;
            end
            else begin
                corrected_en    <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if(data_cnt == (1920*1280)) begin
            $finish;
        end
    end

    reg [11:0]              output_cnt = 0;
    integer                 fd;
    initial begin
        fd = $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/corrected_position.txt","w+");
        $fdisplay(fd,"head:");
    end

    always @(posedge clk) begin
        if(rd_en) begin
            $fwrite(fd,"%d,%d ",int_x,int_y);
            output_cnt      <= output_cnt + 1'b1;
            if((output_cnt == 1919)) begin
                output_cnt  <= 12'd0;
                $fdisplay(fd,"");
                $fdisplay(fd,"head:");
            end
        end
    end
    Location_mapping u_Location_mapping(
        .clk          (clk          ),
        .rst_n        (rst_n        ),
        .corrected_en (corrected_en ),
        .int_x        (int_x        ),
        .int_y        (int_y        ),
        .float_x      (float_x      ),
        .float_y      (float_y      ),
        .position_en        (rd_en        )
    );
    
endmodule
