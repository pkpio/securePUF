`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:06:38 07/09/2014 
// Design Name: 
// Module Name:    PUF_dummy 
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
module PUF_dummy #(parameter N_CB = 64)(
    input wire clk,
    input wire [N_CB-1:0] challenge,
    output wire response
    );

assign response = challenge[10];

endmodule
