//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// Create Date		:  05/27/13
// Modify Date		:	18/07/14
// Module Name		:   SircHandler
// Project Name   :  securePUF
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	13.2 ISE
//
// Description:
// This module handles all sirc related actions which are,
// 1. Receive 128-bits of pdl configuration data and 2 32-bit operands from PC.
// 2. Evaluate the PUFs response for the given configuration and operands.
// 3. Send the responses back to PC.
//
//	NOTE:
// About parameter op_mode
// This decides the mode of operation of the device for a given sirc session (pc-board-pc)
// The notation is,
// 32h'00000000 - calibration
// 32h'00000001 - temperature read
// 32h'YYYYYYYX - normal test mode. (at least one Y is non-zero)
// 
//
//	Bugs :
//	- While writing back to memory the first element is written twice (i.e., to memory addresses 0 and 1).
//   Temporarily fix by writing 1 extra bit and also reading 1 extra but in software.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

//This module demonstrates how a user can read from the parameter register file,
//	read from the input memory buffer, and write to the output memory buffer.
//We also show the basics of how the user's circuit should interact with
// userRunValue and userRunClear.
module SircHandler #(
	//************ Input and output block memory parameters
	//The user's circuit communicates with the input and output memories as N-byte chunks
	//This should be some power of 2 >= 1.
	parameter INMEM_BYTE_WIDTH = 1,
	parameter OUTMEM_BYTE_WIDTH = 1,

	//How many N-byte words does the user's circuit use?
	parameter INMEM_ADDRESS_WIDTH = 17,
	parameter OUTMEM_ADDRESS_WIDTH = 13
)(
	input		wire 				clk,
	input		wire 				reset,
																												//A user application can only check the status of the run register and reset it to zero
	input		wire 				userRunValue,																//Read run register value
	output	reg				userRunClear,																//Reset run register

	//Parameter register file connections
	output 	reg															register32CmdReq,					//Parameter register handshaking request signal - assert to perform read or write
	input		wire 															register32CmdAck,					//Parameter register handshaking acknowledgment signal - when the req and ack ar both true fore 1 clock cycle, the request has been accepted
	output 	wire 		[31:0]											register32WriteData,				//Parameter register write data
	output 	reg		[7:0]												register32Address,				//Parameter register address
	output	wire 															register32WriteEn,				//When we put in a request command, are we doing a read or write?
	input 	wire 															register32ReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input 	wire 		[31:0]											register32ReadData,				//Parameter register read data

	//Input memory connections
	output 	reg															inputMemoryReadReq,				//Input memory handshaking request signal - assert to begin a read request
	input		wire 															inputMemoryReadAck,				//Input memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(INMEM_ADDRESS_WIDTH - 1):0] 			inputMemoryReadAdd,				//Input memory read address - can be set the same cycle that the req line is asserted
	input 	wire 															inputMemoryReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input		wire 		[((INMEM_BYTE_WIDTH * 8) - 1):0] 		inputMemoryReadData,				//Input memory read data

	//Output memory connections
	output 	reg															outputMemoryWriteReq,			//Output memory handshaking request signal - assert to begin a write request
	input 	wire 															outputMemoryWriteAck,			//Output memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(OUTMEM_ADDRESS_WIDTH - 1):0] 			outputMemoryWriteAdd,			//Output memory write address - can be set the same cycle that the req line is asserted
	output	reg		[((OUTMEM_BYTE_WIDTH * 8) - 1):0]		outputMemoryWriteData,			//Output memory write data
	output 	wire 		[(OUTMEM_BYTE_WIDTH - 1):0]				outputMemoryWriteByteMask,		//Allows byte-wise writes when multibyte words are used - each of the OUTMEM_USER_BYTE_WIDTH line can be 0 (do not write byte) or 1 (write byte)

	//8 optional LEDs for visual feedback & debugging
	output wire [7:0]	LED,
	input wire RST,
	input wire start,
	input wire sw
);

/////////////////////////////////////////////// Siam's main code start //////////////////////////////////////////////////////

	wire clk_1, clk_2, clk_RNG, clk_sh;
	CLOCK_TRNG CLOCK_TRNG1(
	    .CLKIN1_IN(clk),      // IN 167 MHz
	    .CLKOUT0_OUT(clk_1),     // OUT
	    .CLKOUT1_OUT(clk_2),// OUT
	    .CLKOUT2_OUT(clk_RNG),   // OUT
	    .CLKOUT3_OUT(clk_sh));    // OUT
		 
	// memory
	wire wea;	 
	wire [12:0] addra, waddr;
	reg [12:0] raddr;
	wire [7:0] dina, douta;
	assign addra = wea? waddr : raddr;
	wire mem_clk;

	BUFGMUX_CTRL MEMCLK (
	.O(mem_clk), // 1-bit output: Clock output
	.I0(clk), // 1-bit input: Clock input (S=0) //EDit from clk_sh
	.I1(clk_1), // 1-bit input: Clock input (S=1)
	.S(wea) // 1-bit input: Clock select
	);

	RMEM rmem1 (
	  .clka(mem_clk), // input clka
	  .wea(wea), // input [0 : 0] wea
	  .addra(addra), // input [12 : 0] addra
	  .dina(dina), // input [7 : 0] dina
	  .douta(douta) // output [7 : 0] douta
	);

	parameter N_CB = 32;
	//wire [7:0] test_result;
	
	
	//******   TEST PUF CODE MOVED TO BOTTOM **//

	//assign LED[7:0] = test_result;
	//assign LED[7:0] = {~wea, ~wea, ~wea, ~wea, ~wea, ~wea, ~wea, ~wea};

/////////////////////////////////////////// Siam's main code ends /////////////////////////////////////////////////////////	



/////////////////////////////////////////// Praveen's modified SIRC FSM start ////////////////////////////////////////////


	//FSM states
	localparam  IDLE = 0;							// Waiting
	localparam  READING_IN_PARAMETERS = 1;	// Get values from the reg32 parameters
	localparam  READ = 2;							// Run (read from input, compute and write to output)
	localparam  WAIT_READ = 3;
	localparam  COMPUTE = 4;
	localparam  WRITE = 5;

	//Signal declarations
	//State registers
	reg [2:0] currState;

	//Challenge = configuration bits for PDLs
	//Challenge and Response holding registers as 2D matrices
	//SIRC sends each byte as 8-bit long so we are using 2D-arrays
	reg	[7:0]	challenge [0:15];
	reg	[7:0]	response	[0:1];

	//Challenge and Response holding variables as a single dimensional 128 bit arrays
	//The above redundant declaration could be avoided by appropriate conditions while reading or writing back
	//We use this because verilog doesn't support passing multidimensional arrays to other modules
	wire [127:0] challengeReg;
	wire [15:0]	responseReg;

	//Buffer to hold the responses in two runs. Will be merged into a single response finally.
	reg [31:0]	responseRegBuffer;


	//Flattening 2D arrays to 1D
	//Endianness has been adjusted in other modules and/or while building reponse 2D array
	assign challengeReg = {
		challenge[15],challenge[14],challenge[13],challenge[12],challenge[11],challenge[10],challenge[9],challenge[8],
		challenge[7],challenge[6],challenge[5],challenge[4],challenge[3],challenge[2],challenge[1],challenge[0]};

	//Endianness has been adjusted in other modules and/or while building challenge 1D array
	always @(*) begin
		{response[0], response[1]} <= responseReg;
	end

	//Counter
	reg paramCount;

	//Parameters from PC
	reg [31:0] op_mode;			// Mode of PUF operation.
	reg [31:0] pc_challenge;
	
	reg calibrate;
	reg read_temp;
	reg test_start;
	wire test_done;

	// We don't write to the register file and we only write whole bytes to the output memory
	assign register32WriteData = 32'd0;
	assign register32WriteEn = 0;
	assign outputMemoryWriteByteMask = {OUTMEM_BYTE_WIDTH{1'b1}};

	//Variables for execution
	reg inputDone;
	reg [5:0] memCount;	//Will be used while reading from memory to 128 bit challenge regs. Similarly while writing back from response regs
	reg [4:0] regCount;
	reg [7:0] bitCount;
	reg [5:0] resp_wait_count;
	reg [5:0] slowRmemCount;

	//PUF execution variables
	reg challenge_ready;
	wire response_ready;

	initial begin
		currState = IDLE;
		pc_challenge = 0;
		op_mode = 0;

		userRunClear = 0;

		register32Address = 0;

		inputMemoryReadReq = 0;
		inputMemoryReadAdd = 0;

		outputMemoryWriteReq = 0;
		outputMemoryWriteAdd = 0;
		outputMemoryWriteData = 0;

		paramCount = 0;

		inputDone = 0;
		challenge_ready = 0;
	end


	always @(posedge clk) begin		// Edit to clock as per siam's code
		if(reset) begin
			currState <= IDLE;

			userRunClear <= 0;

			register32Address <= 0;

			inputMemoryReadReq <= 0;
			inputMemoryReadAdd <= 0;

			outputMemoryWriteReq <= 0;
			outputMemoryWriteAdd <= 0;
			outputMemoryWriteData <= 0;

			paramCount <= 0;

			inputDone <= 0;
			challenge_ready <= 0;

		end
		else begin
			case(currState)
				IDLE: begin
					//Stop trying to clear the userRunRegister
					userRunClear <= 0;
					inputMemoryReadReq <= 0;
					challenge_ready <= 0;

					//Wait till the run register goes high
					if(userRunValue == 1 && userRunClear != 1) begin
						//Start reading from the register file
						currState <= READING_IN_PARAMETERS;
						register32Address <= 0;
						register32CmdReq <= 1;
						paramCount <= 0;
					end
				end
				READING_IN_PARAMETERS: begin
					//We need to read 2 values from the parameter register file.
					//If the register file accepted the read, increment the address
					if(register32CmdAck == 1 && register32CmdReq == 1) begin
						register32Address <= register32Address + 1;
					end

					//If we just accepted a read from address 1, stop requesting reads
					if(register32CmdAck == 1 && register32Address == 8'd1)begin
						register32CmdReq <= 0;
					end

					//If a read came back, shift in the value from the register file
					if(register32ReadDataValid) begin
							op_mode <= pc_challenge;
							pc_challenge <= register32ReadData;
							paramCount <= 1;

							//The above block act as a shift register for operands A and B
							if(paramCount == 1)begin
								//Start requesting input data and execution
								currState <= READ;
								inputMemoryReadReq <= 1;
								inputMemoryReadAdd <= 0;
								outputMemoryWriteAdd <= 0;
								inputDone <= 0;
								memCount <= 0;
								
								// Check the mode of operation requested by PC.
								
								// Calibration mode
								if(op_mode == 32'h00000000) begin
									calibrate <= 1;
									read_temp <= 0;
								end
								
								// temperature test mode
								else if (op_mode == 32'h00000001) begin
									read_temp <= 1;
									calibrate <= 0;
								end
								
								// Normal test mode
								else begin
									calibrate <= 0;
									read_temp <= 0;
								end
								
								// Mode setting  complete.
								
							end
					end
				end
				READ: begin
					//Read for length of length obtained from params
					if(inputDone == 0) begin
						inputMemoryReadReq <= 1;
					end
					else begin
						inputMemoryReadReq <= 0;
					end

					//If the input memory accepted the last read, we can increment the address
					if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd != 15)begin
						inputMemoryReadAdd <= inputMemoryReadAdd + 1;
						currState <= WAIT_READ;
					end
					else if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd == 15)begin
						inputDone <= 1;
						currState <= WAIT_READ;
					end
				end

				WAIT_READ: begin
					if (inputMemoryReadDataValid == 1) begin

						if(memCount <= 15) begin
							challenge[memCount] <= inputMemoryReadData;
							memCount <= memCount+1;
							currState <= READ;
						end
						else begin
							currState <= COMPUTE;
							regCount <= 0;
							bitCount <= 0;
							resp_wait_count <= 0;
							challenge_ready <= 0;
						end
					end
				end

				COMPUTE: begin
					// - TODO -
					// Issue trigger from test_puf block in test mode
					// Multiple triggers as multiple runs in each state of test_puf.
					if(regCount == 0) begin
						challenge_ready <= 1;
						regCount <= regCount+1;
					end
					else begin
						challenge_ready <= 0;
					end

					// Calib mode - wait for sometime for evaluation
					if(calibrate == 1) begin						
						if(resp_wait_count == 10) begin
							currState <= WRITE;
							memCount <= 0;
							regCount <= 0;
							outputMemoryWriteAdd <= 0;
						end
						
						resp_wait_count <= resp_wait_count + 1;
					end
					
					// Test mode - wait for signal from Siam's code as it is using  a different clock
					if(calibrate != 1) begin
						test_start <= 1;
						
						if(test_done == 1) begin
							currState <= WRITE;
							memCount <= 0;
							regCount <= 0;
							test_start <= 0;
							outputMemoryWriteAdd <= 0;
							
							//////////// TEMP ////////////
							raddr <= 0;
							slowRmemCount <= 0;
						end
					end

				end

				WRITE: begin
					outputMemoryWriteReq <= 1;
					
					// Read memory is too slow.
					if(slowRmemCount == 10) begin
						slowRmemCount <= 0;
						
						// Write back raw responses in calibrate mode
						if(calibrate == 1) begin
							if(outputMemoryWriteAdd <= 1) begin
								outputMemoryWriteData <= response[outputMemoryWriteAdd];
							end
						end
						
						// Write back siam's module values to PC.
						else begin
							outputMemoryWriteData <= douta;
						end

						//If we just wrote a value to the output memory this cycle, increment the address
						//NOTE : Due to bug described above we write on bit more by using length instead of lengthMinus1
						if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1 && outputMemoryWriteAdd != 550) begin
							outputMemoryWriteAdd <= outputMemoryWriteAdd + 1;
							raddr <= raddr + 1;
							memCount <= memCount+1;
							currState <= WRITE;
						end

						//Stop writing and go back to IDLE state if writing reached length of data
						if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1 && outputMemoryWriteAdd == 550) begin
							outputMemoryWriteReq <= 0;
							currState <= IDLE;
							userRunClear <= 1;
						end
					end
					
					else begin
						slowRmemCount <= slowRmemCount + 1;
					end
					
				end

			endcase
		end
   end

/////////////////////////////////////////// Praveen's modified SIRC FSM end ////////////////////////////////////////////
	testPUF #(
		.N_CB(N_CB),
		.CHALLENGE_WIDTH(32),
		.PDL_CONFIG_WIDTH(128),
		.RESPONSE_WIDTH(6)		/*** Make sure these params are added in test_puf **/
		) testPUF(
		/*********** Siam's port variables ********/
	    .clk_1(clk_1), // main clock for FSM
	    .clk_2(clk_2), // its freq is half that of clk_1, for the test 1.2 and 1.3 testing block will receive one input bit for two resonse bits from PUF
	    .clk_RNG(clk_RNG), // its freq is 8 times that of clk_1, challenge bits are generated at a higher rate
		 .rst(RST),  // -TODO- replace this
		 //.start(start), // -TODO - replace this
		 .sw(sw), // -TODO - replace this
	    .mem_we(wea), // write enable for memory
	    .mem_waddr(waddr), // write address for memory
	    .mem_din(dina), // data in for memory
	    //.test_result(test_result),

	    /*********** Praveen's port variables *******/
	   .clk(clk),
		.reset(reset),
		.calb_trigger(challenge_ready),
		.pdl_config(challengeReg),
		.pc_challenge(pc_challenge[31:0]),
		.done(response_ready),
		.raw_response(responseReg[5:0]),
		
		.calibrate(calibrate),		// Tells if puf in calib mode or not
		.read_temp(read_temp),		// Tells the test to do a temperature test
		.test_start(test_start),
		.test_done(test_done),
		.LED(LED)
	 );

endmodule
