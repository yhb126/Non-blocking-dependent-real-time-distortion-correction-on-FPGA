`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/17 11:15:40
// Design Name: 
// Module Name: tb_ldc
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
//~ `New testbench
`timescale  1ns / 1ps
`define HEIGHT 1080
`define WIDTH 1920
`define SYNC 580

module tb_ldc_top;

// ldc_top Parameters
parameter PERIOD  = 10;


// ldc_top Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   i_v_sync                             = 0 ;
reg   i_h_sync                             = 0 ;
reg   [7:0]  i_pixel                       = 0 ;

// ldc_top Outputs
wire  o_v_sync                             ;
wire  o_h_sync                             ;
wire  [7:0]  o_pixel                       ;
wire [7:0]  data_out;
wire        data_out_en;
      
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

ldc_top  u_ldc_top (
    .clk                     ( clk             ),
    .rst_n                   ( rst_n           ),
    .i_v_sync                ( i_v_sync        ),
    .i_h_sync                ( i_h_sync        ),
    .i_pixel                 ( i_pixel   [7:0] ),
       
    .o_v_sync                ( o_v_sync        ),
    .o_h_sync                ( o_h_sync        ),
    .o_pixel                 ( o_pixel   [7:0] )
);


reg data_out_en_q;
wire line_over;
always @(posedge clk) begin
    data_out_en_q       <= data_out_en;
end 
assign line_over = !data_out_en & data_out_en_q;



integer fd_r1;
integer fd_r2;
integer fd_r3;
integer fd_w1;
integer fd_w2;
integer fd_w3;
initial begin
    fd_r1 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/image_origin_data_1280_1.txt","rb");
    fd_r2 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/image_origin_data_1280_2.txt","rb");
    fd_r3 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/image_origin_data_1280_3.txt","rb");
end

initial begin
    fd_w1 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/corrected_img_1280_1.txt","w");
    fd_w2 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/corrected_img_1280_2.txt","w");
    fd_w3 =  $fopen("F:/Final_Design_byYhb/Prj/ldc_2018_3/Data/corrected_img_1280_3.txt","w");
    data_save1;
    repeat(100)@(posedge clk);
    data_save2;
    repeat(100)@(posedge clk);
    data_save3;
    repeat(100)@(posedge clk);
    $fclose(fd_w1);
    $fclose(fd_w2);
    $finish;
end

task data_save1;
begin: loop2
    reg [11:0]  m;
    reg [11:0]  n;
    @(posedge o_v_sync);
    for(m = 0; m <`HEIGHT;m=m+1) begin
        @(posedge o_h_sync);
        for(n = 0; n< `WIDTH; n=n+1) begin
            @(posedge clk);
            $fwrite(fd_w1,"%d ",o_pixel);
        end
    end
end
endtask

task data_save2;
begin: loop3
    reg [11:0]  m;
    reg [11:0]  n;
    @(posedge o_v_sync);
    for(m = 0; m <`HEIGHT;m=m+1) begin
        @(posedge o_h_sync);
        for(n = 0; n< `WIDTH; n=n+1) begin
            @(posedge clk);
            $fwrite(fd_w2,"%d ",o_pixel);
        end
    end
end
endtask

task data_save3;
begin: loop5
    reg [11:0]  m;
    reg [11:0]  n;
    @(posedge o_v_sync);
    for(m = 0; m <`HEIGHT;m=m+1) begin
        @(posedge o_h_sync);
        for(n = 0; n< `WIDTH; n=n+1) begin
            @(posedge clk);
            $fwrite(fd_w3,"%d ",o_pixel);
        end
    end
    $finish;
end
endtask



initial
begin
    repeat(1000) @(posedge clk);
    rst_n = 1'b1;
    repeat(100) @(posedge clk);
    ram_write_test;
    repeat(300000)@(posedge clk);
    ram_write_test2;
    repeat(300000)@(posedge clk);
    ram_write_test3;
    $fclose(fd_r1);
    $fclose(fd_r2);
    $fclose(fd_r3);
end

    task ram_write_test;
    begin: loop1
        reg[11:0] i;
        reg[11:0] j;
        i_v_sync <= 1;
        for(i=0 ; i<`HEIGHT; i=i+1) begin
            repeat(`SYNC) @(posedge clk); 
            // if(i < `HEIGHT) begin
                i_h_sync <= 1;
                for(j=0;j<`WIDTH;j=j+1) begin
                    @(posedge clk);
                    $fscanf(fd_r1,"%d ",i_pixel);
                end
            i_h_sync  <= 0;
        end
        i_v_sync <= 0;
    end
    endtask    


    task ram_write_test2;
    begin: loop4
        reg[11:0] i1;
        reg[11:0] j1;
        i_v_sync <= 1;
        for(i1=0 ; i1<`HEIGHT; i1=i1+1) begin
            repeat(`SYNC) @(posedge clk); 
            // if(i < `HEIGHT) begin
                i_h_sync <= 1;
                for(j1=0;j1<`WIDTH;j1=j1+1) begin
                    @(posedge clk);
                    $fscanf(fd_r2,"%d ",i_pixel);
                end
            i_h_sync  <= 0;
            // end
            // else begin
            //     for(j=0;j<=`WIDTH;j=j+1) begin
            //         @(posedge clk);
            //         i_h_sync <= 0;
            //         if(data_out_en) begin
            //             $fwrite(fd_w,"%d,%d:%d ",i,j,data_out);
            //         end
            //     end
            // end
        end
        i_v_sync <= 0;
    end
    endtask    

    task ram_write_test3;
    begin: loop4
        reg[11:0] i1;
        reg[11:0] j1;
        i_v_sync <= 1;
        for(i1=0 ; i1<`HEIGHT; i1=i1+1) begin
            repeat(`SYNC) @(posedge clk); 
            // if(i < `HEIGHT) begin
                i_h_sync <= 1;
                for(j1=0;j1<`WIDTH;j1=j1+1) begin
                    @(posedge clk);
                    $fscanf(fd_r3,"%d ",i_pixel);
                end
            i_h_sync  <= 0;
            // end
            // else begin
            //     for(j=0;j<=`WIDTH;j=j+1) begin
            //         @(posedge clk);
            //         i_h_sync <= 0;
            //         if(data_out_en) begin
            //             $fwrite(fd_w,"%d,%d:%d ",i,j,data_out);
            //         end
            //     end
            // end
        end
        i_v_sync <= 0;
    end
    endtask  
    

endmodule