`timescale 1ns / 1ps
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:  07/13/14
// Modify Date		:	07/14/14
// Module Name		:  pufInputNetwork
// Project Name   :  PDL
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	14.4 ISE
//
// Description:
// This module does the transformation on input data before assigning as challenges
// such that they satisfy the Strict Avalanche Criterion (SAC)as described in paper.
//	
//	Note:
//	The input network in the paper is offsetted by 1. i.e., starts at index 1.
//	So, taking N = N-1 similary 0th bit as base, we get new equations as,
//	
//	C[32] = D[0]
//	C[(i+1)/2] = D[i] xor D[i+1]  for i = 1, 3, 5, ... N-2
//	C[(N+i+1)/2] = D[i] xor D[i+1] for i = 2, 4, ..... N-1
//
//////////////////////////////////////////////////////////////////////////////////

module pufInputNetwork	#(parameter Width = 64)
								(input wire [Width-1:0] dataIn,
								output wire [Width-1:0] dataOut);
								
	parameter N = Width-1;	// N is 63 and index starts at 0. Read above note.
	
	genvar i;
	generate
		for (i = 1; i < N; i=i+1) begin:m
		
			// i is odd
			if(i%2 != 0) begin
				assign dataOut[(i+1)/2] = dataIn[i] + dataIn[i+1];
			end
			
			// i is even
			else begin
				assign dataOut[(N+i+1)/2] = dataIn[i] + dataIn[i+1];
			end
			
		end
	endgenerate


endmodule
