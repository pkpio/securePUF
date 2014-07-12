`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:58 04/14/2014 
// Design Name: 
// Module Name:    TemperatureSensor 
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
module SystemMonitor(
    input wire clk,
	 input wire [6:0] DADDR_IN,
	 output  wire DRDY_OUT,
    output wire [15:0] DO_OUT
    );
	 

//wire [6:0] DADDR_IN;
wire DEN_IN, DWE_IN, VP_IN, VN_IN;
wire [15:0] DI_IN;

//assign DADDR_IN = 7'h00;
assign DEN_IN = 1'b1;
assign DWE_IN = 1'b0;
assign VP_IN = 1'b0;
assign VN_IN = 1'b0;
assign DI_IN = 16'h0000;

SysMon SysMon1(
      .DADDR_IN(DADDR_IN[6:0]),
      .DCLK_IN(clk),
      .DEN_IN(DEN_IN),
      .DI_IN(DI_IN[15:0]),
      .DWE_IN(DWE_IN),
      .DO_OUT(DO_OUT[15:0]),
      .DRDY_OUT(DRDY_OUT),
      .VP_IN(VP_IN),
      .VN_IN(VN_IN)
      );
		
endmodule
