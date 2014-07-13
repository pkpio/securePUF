//////////////////////////////////////////////////////////////////////////////////
//
// Author           :   Praveen Kumar Pendyala
// Create Date      :   05/27/13
// Modify Date      :   16/01/14
// Module Name      :   alu_puf
// Project Name     :   PDL
// Target Devices   :   Xilinx Vertix 5, XUPV5 110T
// Tool versions    :   13.2 ISE
//
// Description:
// This is an ALU based PUF. Implements two adders that operate on the same operands
// concurrently and produce results. The result signals are passed through pdl_puf
// for tuning assymetric routing delay using pdls and responses are computed based on
// which signal is faster for each bit of response.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module AluPuf(CHALLENGE, RESPONSE, trigger, reset, a, b);

output [15:0] RESPONSE;
input [127:0] CHALLENGE;
input trigger;
input reset;
input wire [15:0] a;
input wire [15:0] b;

wire [127:0] CHALLENGE;
wire [15:0] RESPONSE;

(* KEEP = "TRUE" *)
reg [15:0] a1;
reg [15:0] a2;
reg [15:0] b1;
reg [15:0] b2;

wire [15:0] c1;
wire [15:0] c2;

always @ (posedge trigger) begin
	a1 <= a;
	a2 <= a;
	b1 <= b;
	b2 <= b;
end

(* KEEP="TRUE" *)
assign c1 = (trigger==1)?(a1+b1):0;
assign c2 = (trigger==1)?(a2+b2):0;

(* KEEP_HIERARCHY="TRUE" *)
pdl_puf puf1 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[0]), .s2(c2[0]), .reset(reset), .o(RESPONSE[0]));
pdl_puf puf2 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[1]), .s2(c2[1]), .reset(reset), .o(RESPONSE[1]));
pdl_puf puf3 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[2]), .s2(c2[2]), .reset(reset), .o(RESPONSE[2]));
pdl_puf puf4 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[3]), .s2(c2[3]), .reset(reset), .o(RESPONSE[3]));
pdl_puf puf5 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[4]), .s2(c2[4]), .reset(reset), .o(RESPONSE[4]));
pdl_puf puf6 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[5]), .s2(c2[5]), .reset(reset), .o(RESPONSE[5]));
pdl_puf puf7 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[6]), .s2(c2[6]), .reset(reset), .o(RESPONSE[6]));
pdl_puf puf8 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[7]), .s2(c2[7]), .reset(reset), .o(RESPONSE[7]));
pdl_puf puf9 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[8]), .s2(c2[8]), .reset(reset), .o(RESPONSE[8]));
pdl_puf puf10 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[9]), .s2(c2[9]), .reset(reset), .o(RESPONSE[9]));
pdl_puf puf11 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[10]), .s2(c2[10]), .reset(reset), .o(RESPONSE[10]));
pdl_puf puf12 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[11]), .s2(c2[11]), .reset(reset), .o(RESPONSE[11]));
pdl_puf puf13 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[12]), .s2(c2[12]), .reset(reset), .o(RESPONSE[12]));
pdl_puf puf14 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[13]), .s2(c2[13]), .reset(reset), .o(RESPONSE[13]));
pdl_puf puf15 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[14]), .s2(c2[14]), .reset(reset), .o(RESPONSE[14]));
pdl_puf puf16 (.s_tp(CHALLENGE[63:0]), .s_btm(CHALLENGE[127:64]), .s1(c1[15]), .s2(c2[15]), .reset(reset), .o(RESPONSE[15]));


endmodule

