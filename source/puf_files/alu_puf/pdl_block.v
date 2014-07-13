//////////////////////////////////////////////////////////////////////////////////
//
// Author           :   Praveen Kumar Pendyala
// Create Date      :   05/27/13
// Modify Date      :   16/01/14
// Module Name      :   pdl_block
// Project Name     :   PDL
// Target Devices   :   Xilinx Vertix 5, XUPV5 110T
// Tool versions    :   13.2 ISE
//
// Description:
// Each pdl block consists of two 6 input LUTs.
// Initialised to 64'h5655555555555555 which translates each LUT as an inverter.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module pdl_block(i,o,t);

(* KEEP = "TRUE" *) (* S = "TRUE" *) input i;
(* KEEP = "TRUE" *) (* S = "TRUE" *) input  t;
(* KEEP = "TRUE" *) (* S = "TRUE" *) output o;

(* KEEP = "TRUE" *) (* S = "TRUE" *) wire  w;
(* KEEP = "TRUE" *) (* S = "TRUE" *) wire  t;


(* BEL ="D6LUT" *) (* LOCK_PINS = "all" *)
LUT6 #(
	.INIT(64'h5555555555555555) // Specify LUT Contents
) LUT6_inst_1 (
	.O(w), // LUT general output
	.I0(i), // LUT input
	.I1(t), // LUT input
	.I2(t), // LUT input
	.I3(t), // LUT input
	.I4(t), // LUT input
	.I5(t) // LUT input
);
// End of LUT6_inst instantiation

(* BEL ="D6LUT" *) (* LOCK_PINS = "all" *)
LUT6 #(
	.INIT(64'h5555555555555555) // Specify LUT Contents
) LUT6_inst_0 (
	.O(o), // LUT general output
	.I0(w), // LUT input
	.I1(t), // LUT input
	.I2(t), // LUT input
	.I3(t), // LUT input
	.I4(t), // LUT input
	.I5(t) // LUT input
);
// End of LUT6_inst instantiation


endmodule