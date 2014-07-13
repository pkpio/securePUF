`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:29:10 04/17/2008 
// Design Name: 
// Module Name:    DelayElement 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pdl_block(i,o,t);

(* KEEP = "TRUE" *) (* S = "TRUE" *) input i;
(* KEEP = "TRUE" *) (* S = "TRUE" *) input  t;
(* KEEP = "TRUE" *) (* S = "TRUE" *) output o;

(* KEEP = "TRUE" *) (* S = "TRUE" *) wire  w;
(* KEEP = "TRUE" *) (* S = "TRUE" *) wire  t;


(* BEL ="D6LUT" *) (* LOCK_PINS = "all" *)
LUT6 #(
	.INIT(64'h5655555555555555) // Specify LUT Contents
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
	.INIT(64'h5655555555555555) // Specify LUT Contents
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