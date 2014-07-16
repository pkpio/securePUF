 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:20 09/15/2007 
// Design Name: 
// Module Name:    puf 
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
//`include "switchBlock.v"

module PDL_PUF(s_tp, s_btm, q, reset, o);

// s: The challenge vector of size PUFlength
// q: The input trigger signal to the PUF (launch signal)
// reset: Resets the PUF output to zero and prepares it for the next round
// o: The output of the arbiters (response)
 
    parameter PUFlength = 63;

    input [PUFlength:0] s_tp, s_btm;
    input  q, reset;
    output o;
	 
	 wire [PUFlength:0] i1,i2;
	 wire q_buf, puf_out;

	 
(* BEL ="D6LUT" *) //(* LOCK_PINS = "all" *)
LUT1 #(
	.INIT(2'b10) // Specify LUT Contents
) LUT1_inst_1 (
	.O(q_buf), // LUT general output
	.I0(q) // LUT input
);

	 
(* KEEP_HIERARCHY="TRUE" *)
pdl_based_switch sarray [PUFlength:0] (.i1({q_buf,i1[PUFlength:1]}),.i2({q_buf,i2[PUFlength:1]}), .select_tp(s_tp[PUFlength:0]), .select_btm(s_btm[PUFlength:0]),.o1(i1[PUFlength:0]),.o2(i2[PUFlength:0]));

FDC FDC1 (.Q (puf_out),
          .C (i2[0]),
          .CLR (reset),
          .D (i1[0]));

			 
(* BEL ="D6LUT" *) //(* LOCK_PINS = "all" *)
LUT1 #(
	.INIT(2'b10) // Specify LUT Contents
) LUT1_inst_2 (
	.O(o), // LUT general output
	.I0(puf_out) // LUT input
);			 
			 
        
endmodule
