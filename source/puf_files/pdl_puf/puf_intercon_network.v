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
module pufInterconNetwork(CHALLENGE, RESPONSE, trigger, reset);

output [5:0] RESPONSE;
input [127:0] CHALLENGE;
input trigger;
input reset;

wire [127:0] CHALLENGE;
wire [5:0] RESPONSE;

/////////////////////////////////////////////////////////////////////////////
//	Note: 
// 			Regarding the PUF instantiation
// The 1st 64 bits (63-0) are PUF challeges.
// The 2nd 64 bits (127-64) are PDL configuration bits
// PDL and PUF is essential made of same basic element - LUT6
// Within 63-0, (circularly rotated)
//			31-0 is for top row
//			63-32 is for bottom row
//	Within 127-64, (no rotation)
//			127-96 is for top row
//			95-63 is for bottom row
//
//				Regarding the interconnect network
// The PUF model also implements an interconnect network as described in the
// Light Weight Secure PUFs paper. However, the interconnect network is only
// on the core PUF and not on the PDL section. So, as per the interconnect
// network we will circularly shift only the inputs to the PUF network. PDL
// Challenge bits are given as is without any circular rotation
/////////////////////////////////////////////////////////////////////////////

(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf1 (	.s_tp( {CHALLENGE[31:0], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[63:32], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[0]));
					
PDL_PUF puf2 (	.s_tp( {CHALLENGE[0], CHALLENGE[31:1], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[32], CHALLENGE[63:33], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[1]));
					
PDL_PUF puf3 (	.s_tp( {CHALLENGE[1:0], CHALLENGE[31:2], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[33:32], CHALLENGE[63:34], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[2]));
					
PDL_PUF puf4 (	.s_tp( {CHALLENGE[2:0], CHALLENGE[31:3], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[34:32], CHALLENGE[63:35], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[3]));
					
PDL_PUF puf5 (	.s_tp( {CHALLENGE[3:0], CHALLENGE[31:4], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[35:32], CHALLENGE[63:36], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[4]));
					
PDL_PUF puf6 (	.s_tp( {CHALLENGE[4:0], CHALLENGE[31:5], CHALLENGE[127:96]} ),
					.s_btm( {CHALLENGE[36:32], CHALLENGE[63:37], CHALLENGE[95:63] } ),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[5]));

/*		We shall be only 6 structures currently
PDL_PUF puf7 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[6]));
PDL_PUF puf8 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[7]));
PDL_PUF puf9 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[8]));
PDL_PUF puf10 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[9]));
PDL_PUF puf11 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[10]));
PDL_PUF puf12 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[11]));
PDL_PUF puf13 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[12]));
PDL_PUF puf14 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[13]));
PDL_PUF puf15 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[14]));
PDL_PUF puf16 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[15]));
*/

endmodule
