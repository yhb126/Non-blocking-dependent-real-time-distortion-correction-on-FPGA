//-----------------------------------------------------------------------------
// Title         : xdil_dpram
// Project       : Generic
//-----------------------------------------------------------------------------
// File          : xdil_dpram.v
// Author        :   <SongRui@XIDIAN-SR>
// Created       : 25.07.2010
// Last modified : 25.07.2010
//-----------------------------------------------------------------------------
// Description :
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2010 by xidian univ. This model is the confidential and
// proprietary property of xidian univ. and the possession or use of this
// file requires a written license from xidian univ..
//------------------------------------------------------------------------------
// Modification history :
// 25.07.2010 : created
//-----------------------------------------------------------------------------
`include "F:/Final_Design_byYhb/Prj/ldc_2018_3/Prj/ldc/ldc.srcs/sources_1/imports/new/Parameter.vh"
// `define RAM_INFERRED
// `define XILINX_RAM
// `define REG_DEL #3

module xdil_dpram(/*AUTOARG*/
   // Outputs
   rd,
   // Inputs
   wrclk, waddr, we, wd, rdclk, raddr
   );
   

   
   // synopsys template
   parameter NumWords = 128;
   parameter AddrBits = 7;
   parameter NumBits  = 16;
   
   input wrclk;
   input [AddrBits-1:0]                  waddr;
   input                                 we;
   input [NumBits-1:0]                   wd;

   input                                 rdclk;
   input [AddrBits-1:0]                  raddr;
   output [NumBits-1:0]                  rd;

   //---------------------
   //-- FPGA Inferred RAM
   //---------------------

`ifdef RAM_INFERRED
   reg [NumBits-1:0]                     rd;
 `ifdef XILINX_RAM
   (* ram_style = "block_ram" *)reg [NumBits-1:0]                     mem[NumWords-1:0] /* synthesis syn_ramstyle="block_ram" */;
 `else
   reg [NumBits-1:0]                     mem[NumWords-1:0] /* synthesis syn_ramstyle="M4K" */;
 `endif

   always @(posedge wrclk)
     begin
        if (we) mem[waddr] <= `REG_DEL wd;
     end

   always @(posedge rdclk)
     begin
        rd <= `REG_DEL mem[raddr];
     end

`endif

endmodule // xdil_dpram