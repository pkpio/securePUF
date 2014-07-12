// Ken Eguro
//		Alpha version - 2/11/09
//		Version 1.0 - 1/4/10
//		Version 1.0.1 - 5/7/10
//		Version 1.1 - 8/1/11

`timescale 1ns / 1ps
`default_nettype none

module fifo36Wrapper(
	input 	wire 			writeClk,
	input 	wire [35:0] writeData,
	input 	wire 			writeEnable,
	output 	wire 			full,
	input 	wire 			readClk,
	output 	wire [35:0] readData,
	input 	wire 			readEnable,
	output 	wire 			empty,
	input 	wire 			reset
);
	//This is straight from the Virtex 5 HDL Design Guide
	FIFO18_36 #(
		.SIM_MODE("SAFE"), // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
		.ALMOST_FULL_OFFSET(12'h080), // Sets almost full threshold
		.ALMOST_EMPTY_OFFSET(12'h080), // Sets the almost empty threshold
		.DO_REG(1), // Enable output register (0 or 1)
		// Must be 1 if EN_SYN = "FALSE"
		.EN_SYN("FALSE"), // Specifies FIFO as Asynchronous ("FALSE")
		// or Synchronous ("TRUE")
		.FIRST_WORD_FALL_THROUGH("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
	) FIFO18_inst (
		.ALMOSTEMPTY(), // 1-bit almost empty output flag
		.ALMOSTFULL(), // 1-bit almost full output flag
		.DO(readData[31:0]), // 32-bit data output
		.DOP(readData[35:32]), // 4-bit parity data output
		.EMPTY(empty), // 1-bit empty output flag
		.FULL(full), // 1-bit full output flag
		.RDCOUNT(), // 9-bit read count output
		.RDERR(), // 1-bit read error output
		.WRCOUNT(), // 9-bit write count output
		.WRERR(), // 1-bit write error
		.DI(writeData[31:0]), // 32-bit data input
		.DIP(writeData[35:32]), // 4-bit parity input
		.RDCLK(readClk), // 1-bit read clock input
		.RDEN(readEnable), // 1-bit read enable input
		.RST(reset), // 1-bit reset input
		.WRCLK(writeClk), // 1-bit write clock input
		.WREN(writeEnable) // 1-bit write enable input
	);
endmodule
