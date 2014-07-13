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
//
// This is probably what you are looking for.
//
// This module takes 2 signals and pdl configuration bits for 2 lines as inputs.
// Instantiates 64 pdl_switches and sends the received 2 signals along the switches
// Also assigns the configuration bits to switches.
// Final output signal is passed through arbiter and response is evaluated.
// The evaluated response will be sent back to higher modules.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module pdl_puf (s_tp, s_btm, s1, s2, reset, o);

// s: The challenge vector of size PUFlength
// q: The input trigger signal to the PUF (launch signal)
// reset: Resets the PUF output to zero and prepares it for the next round
// o: The output of the arbiters (response)
// s1: a sum bit from adder1;
// s2: a sum bit from adder2

  parameter PUFlength = 63;

  input [PUFlength:0] s_tp, s_btm;
  input  s1, s2, reset;
  output o;

	 wire [PUFlength:0] i1,i2;
	 wire puf_out;


(* KEEP_HIERARCHY="TRUE" *)
pdl_switch sarray [PUFlength:0] (
  .i1({s1,i1[PUFlength:1]}),
  .i2({s2,i2[PUFlength:1]}),
  .select_tp(s_tp[PUFlength:0]),
  .select_btm(s_btm[PUFlength:0]),
  .o1(i1[PUFlength:0]),
  .o2(i2[PUFlength:0])
  );


// Arbiter to decide which signal reached first.
FDC FDC1 (.Q (puf_out),
          .C (i2[0]),
          .CLR (reset),
          .D (i1[0]));


(* BEL ="D6LUT" *) (* LOCK_PINS = "all" *)
LUT1 #(
	.INIT(2'b10) // Specify LUT Contents
) LUT1_inst_2 (
	.O(o),       // LUT general output
	.I0(puf_out) // LUT input
);


endmodule
