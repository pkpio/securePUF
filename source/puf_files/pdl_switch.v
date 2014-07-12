//////////////////////////////////////////////////////////////////////////////////
//
// Author           :   Praveen Kumar Pendyala
// Create Date      :   05/27/13
// Modify Date      :   16/01/14
// Module Name      :   pdl_puf
// Project Name     :   PDL
// Target Devices   :   Xilinx Vertix 5, XUPV5 110T
// Tool versions    :   13.2 ISE
//
// Description:
// Each pdl switch consists of 2 blocks - top_block and bottom_block
// The relative signal delay can adjusted by giving different configuration bits
// for each block. The one with greater 1's in the configuration bits usually
// provides greater delay for signal.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module pdl_switch(i1, i2, select_tp, select_btm, o1, o2);

    input i1, i2;
    input select_tp, select_btm;
    output o1, o2;

	(* KEEP_HIERARCHY="TRUE" *) pdl_block pdl_top (.i(i1), .o(o1), .t(select_tp));
	(* KEEP_HIERARCHY="TRUE" *) pdl_block pdl_bottom (.i(i2), .o(o2), .t(select_btm));

endmodule