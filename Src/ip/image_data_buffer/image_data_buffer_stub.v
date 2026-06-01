// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Mar  4 20:02:36 2025
// Host        : DESKTOP-098APIQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/Final_Design_byYhb/Prj/ldc_2018_3/Src/ip/image_data_buffer/image_data_buffer_stub.v
// Design      : image_data_buffer
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module image_data_buffer(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[16:0],dina[7:0],clkb,enb,addrb[16:0],doutb[7:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [16:0]addra;
  input [7:0]dina;
  input clkb;
  input enb;
  input [16:0]addrb;
  output [7:0]doutb;
endmodule
