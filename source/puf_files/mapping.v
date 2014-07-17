//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:   05/27/13
// Modify Date		:	16/07/14
// Module Name		:   mapping
// Project Name     :   PDL
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	13.2 ISE
//
// Description:
// This module maps the data received from the SircHandler to the puf.
// Does all singal mappings to input, interconnect and output networks.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module mapping #(
	parameter CHALLENGE_WIDTH = 32,
	parameter PDL_CONFIG_WIDTH = 128,
	parameter RESPONSE_WIDTH = 6
)(
	input wire clk,
	input wire reset,
	input wire trigger,
	input wire [CHALLENGE_WIDTH-1:0] challenge,
	input wire [PDL_CONFIG_WIDTH-1:0] pdl_config,
	output reg done,
	output wire [RESPONSE_WIDTH-1:0] raw_response,
	output wire xor_response
	);

	//FSM States
	localparam IDLE = 0;
	localparam COMPUTE = 1;
	
	//State Register
	reg mp_state;
	
	//Actual challenge after transformation
	wire [CHALLENGE_WIDTH-1:0] actual_challenge;

	
/////////////  			 Input network			/////////////
	
	(* KEEP_HIERARCHY="TRUE" *)
	pufInputNetwork #(.Width(CHALLENGE_WIDTH))
					pin(
						.dataIn(challenge[CHALLENGE_WIDTH-1:0]),
						.dataOut(actual_challenge[CHALLENGE_WIDTH-1:0])
					);
					
					
////////////	Interconnect network & PUF		///////////////
	(* KEEP_HIERARCHY="TRUE" *)
	pufInterconNetwork picn (
						.CHALLENGE(actual_challenge[CHALLENGE_WIDTH-1:0]),
						.PDL_CONFIG(pdl_config[PDL_CONFIG_WIDTH-1:0]),
						.RESPONSE(raw_response),
						.trigger(trigger),
						.reset(reset)
						);
						
////////////		Output network				///////////////
	(* KEEP_HIERARCHY="TRUE" *)
	pufOutputNetwork pon (
						.response(raw_response),
						.xor_response(xor_response)
						);

endmodule
