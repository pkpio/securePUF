`timescale 1ns / 1ps
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:  07/13/14
// Modify Date		:	07/16/14
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
//	So, we make an new register arrays that start at index 1 so that we won't
//	have to worry about how the shifts happen in the equation.
//	
//	Transformation from paper,
//	C[(N+i+1)/2] = D[i]  for i = 1 										----- (1)
//	C[(i+1)/2] = D[i] xor D[i+1]  for i = 1, 3, 5, ... N-1		----- (2)
//	C[(N+i+2)/2] = D[i] xor D[i+1] for i = 2, 4, 6, ..... N-2	----- (3)
//
//////////////////////////////////////////////////////////////////////////////////

module pufInputNetwork	#(parameter Width = 32)
								(input wire [Width-1:0] dataIn,
								output wire [Width-1:0] dataOut);
								
	parameter N = Width;
	
	// Offset added registers to easy transformation.
	wire [Width:1] os_dataIn;
	wire [Width:1] os_dataOut;

	assign os_dataIn[Width:1] = dataIn[Width-1:0];
	assign dataOut[Width-1:0] = os_dataOut[Width:1];

	//Equation (1)
	assign os_dataOut[(Width+2)/2]  = os_dataIn[1];

	genvar i;
	generate
		for (i = 2; i < N; i=i+1) begin:m
		
			// i is odd --- (2)
			if(i%2 != 0) begin
				assign os_dataOut[(i+1)/2] = os_dataIn[i] + os_dataIn[i+1];
			end
			
			// i is even --- (3)
			else begin
				assign os_dataOut[(N+i+2)/2] = os_dataIn[i] + os_dataIn[i+1];
			end
			
		end
	endgenerate


endmodule
