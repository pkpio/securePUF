`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:06:00 06/14/2010 
// Design Name: 
// Module Name:    system 
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
module pufMapping(CHALLENGE, RESPONSE, trigger, reset);

output [15:0] RESPONSE;
input [127:0] CHALLENGE;
input trigger;
input reset;

wire [127:0] CHALLENGE;
wire [15:0] RESPONSE;

(* KEEP_HIERARCHY="TRUE" *)
PDL_PUF puf1 (	.s_tp({CHALLENGE[63:0]}),
					.s_btm(CHALLENGE[127:64]),
					.q(trigger), 
					.reset(reset), 
					.o(RESPONSE[0]));

PDL_PUF puf2 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[1]));

PDL_PUF puf3 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[2]));

PDL_PUF puf4 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[3]));

PDL_PUF puf5 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[4]));

PDL_PUF puf6 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .q(trigger), .reset(reset), .o(RESPONSE[5]));

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
