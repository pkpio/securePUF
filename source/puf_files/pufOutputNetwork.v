`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:  07/13/14
// Modify Date		:	07/14/14
// Module Name		:  pufInterconNetwork
// Project Name   :  PDL
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	14.4 ISE
//
// Description:
// The output network. Not in accordance with paper. A 6 input xor as output.
//
//////////////////////////////////////////////////////////////////////////////////
module pufOutputNetwork(
			input wire [5:0] response,
			output wire xor_response
    );
	 
	 // xor is equivalent to add w/o carry for 1-bit case.
	 assign xor_response = response[5] ^ response[4] ^ response[3] ^ response[2] ^ response[1] ^ response[0];

endmodule
