`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:  07/13/14
// Modify Date		:	16/01/13
// Module Name		:  pufInterconNetwork
// Project Name   :  PDL
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	14.4 ISE
//
// Description:
// This module maps the data received by to parallel PUF instances following
// the interconnect network criteria. Read comments.
//
//////////////////////////////////////////////////////////////////////////////////
module pufInterconNetwork(CHALLENGE, PDL_CONFIG, RESPONSE, trigger, reset);

output [5:0] RESPONSE;
input [63:0] CHALLENGE;
input [127:0] PDL_CONFIG;
input trigger;
input reset;

wire [63:0] CHALLENGE;
wire [127:0] PDL_CONFIG;
wire [5:0] RESPONSE;

// -TODO-
// Same config bits for both top and bottom switch for PUF part.
// Check the available space in PlanAHead and decide lengths.

/////////////////////////////////////////////////////////////////////////////
//	Note: 
// 			Regarding the PUF instantiation
// The 64 bits of CHALLENGE are PUF challeges.
// The 128 bits of PDL_CONFIG are PDL configuration bits
// PDL and PUF is essential made of same basic element - LUT6
// 
//	With in CHALLENGE,
//	bits are circuilarly rotated and same bit is used for both top 
// and bottom line
//
//
//	Within PDL_CONFIG, (no rotation)
//			127-64 is for top row
//			63-0 is for bottom row
//
//				Regarding the interconnect network
// The PUF model also implements an interconnect network as described in the
// Light Weight Secure PUFs paper. However, the interconnect network is only
// on the core PUF and not on the PDL section. So, as per the interconnect
// network we will circularly shift only the inputs to the PUF network. PDL
// Challenge bits are given as is without any circular rotation
/////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf1 (	.s_tp( {CHALLENGE[31:0], PDL_CONFIG[31:0]} ),
					.s_btm( {CHALLENGE[31:0], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[0]));
					
(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf2 (	.s_tp( {CHALLENGE[0], CHALLENGE[31:1], PDL_CONFIG[31:0]} ),
					.s_btm( {CHALLENGE[0], CHALLENGE[31:1], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[1]));
					
(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf3 (	.s_tp( {CHALLENGE[1:0], CHALLENGE[31:2], PDL_CONFIG[31:0]}),
					.s_btm( {CHALLENGE[1:0], CHALLENGE[31:2], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[2]));
					
(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf4 (	.s_tp( {CHALLENGE[2:0], CHALLENGE[31:3], PDL_CONFIG[31:0]} ),
					.s_btm( {CHALLENGE[2:0], CHALLENGE[31:3], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[3]));
					
(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf5 (	.s_tp( {CHALLENGE[3:0], CHALLENGE[31:4], PDL_CONFIG[31:0]} ),
					.s_btm( {CHALLENGE[3:0], CHALLENGE[31:4], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[4]));
					
(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf6 (	.s_tp( {CHALLENGE[4:0], CHALLENGE[31:5], PDL_CONFIG[31:0]} ),
					.s_btm( {CHALLENGE[4:0], CHALLENGE[31:5], PDL_CONFIG[95:64]} ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[5]));

endmodule
