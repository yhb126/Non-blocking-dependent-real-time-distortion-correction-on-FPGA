`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 17:02:17
// Design Name: 
// Module Name: tb_interpolation
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


module tb_Quadratic_Interpolation;

// Quadratic_Interpolation Parameters
parameter PERIOD  = 10;


// Quadratic_Interpolation Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [15:0]  float_x                      = 0 ;
reg   [15:0]  float_y                      = 0 ;
reg   interpola_en                         = 0 ;
reg   [7:0]  data_11                       = 0 ;
reg   [7:0]  data_12                       = 0 ;
reg   [7:0]  data_21                       = 0 ;
reg   [7:0]  data_22                       = 0 ;

// Quadratic_Interpolation Outputs
wire  [7:0]  data_out                      ;
wire  data_out_en                          ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

Quadratic_Interpolation  u_Quadratic_Interpolation (
    .clk                     ( clk                  ),
    .rst_n                   ( rst_n                ),
    .float_x                 ( float_x       [15:0] ),
    .float_y                 ( float_y       [15:0] ),
    .interpola_en            ( interpola_en         ),
    .data_11                 ( data_11       [7:0]  ),
    .data_12                 ( data_12       [7:0]  ),
    .data_21                 ( data_21       [7:0]  ),
    .data_22                 ( data_22       [7:0]  ),

    .data_out                ( data_out      [7:0]  ),
    .data_out_en             ( data_out_en          )
);

initial
begin
    repeat(100) @(posedge clk);
    interpolation_test;
    repeat(100) @(posedge clk);
    $finish;
end

task interpolation_test;
begin: loop1
    reg [7:0] i;
    for(i = 1; i<= 128; i=i+1) begin
        @(posedge clk);
        interpola_en <= 1'b1;
        data_11     <= i;
        data_21     <= i*2;
        data_12     <= data_11;
        data_22     <= data_21;
        float_x     <= i * 16'h0200;
        float_y     <= i * 16'h0200;
    end
end
endtask

endmodule