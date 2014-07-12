// Ken Eguro
//		Alpha version - 2/11/09
//		Version 1.0 - 1/4/10
//		Version 1.0.1 - 5/7/10
//		Version 1.1 - 8/1/11

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
	input		wire 					clk,
	input		wire 					reset,
																														//A user application can only check the status of the run register and reset it to zero
	input		wire 					userRunValue,																//Read run register value
	output	reg					userRunClear,																//Reset run register
	
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
	output	wire 		[7:0]												LED, 
	input wire RST
);

		///////
		//input wire [7:0] RAND,
		//reg [12:0] ADDRA;
		///////
		
				
//****

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
.I0(clk_sh), // 1-bit input: Clock input (S=0)
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

parameter N_CB = 64;
wire [7:0] test_result;
testPUF #(N_CB) testPUF(
    .clk_1(clk_1), // main clock for FSM
    .clk_2(clk_2), // its freq is half that of clk_1, for the test 1.2 and 1.3 testing block will receive one input bit for two resonse bits from PUF
    .clk_RNG(clk_RNG), // its freq is 8 times that of clk_1, challenge bits are generated at a higher rate
	 .rst(RST),
    .mem_we(wea), // write enable for memory
    .mem_waddr(waddr), // write address for memory
    .mem_din(dina), // data in for memory
    .test_result(test_result)
    );

assign LED[7:0] = test_result;	

//*****


	//FSM states
	localparam  IDLE = 0;							// Waiting
	localparam  READING_IN_PARAMETERS = 1;	// Get values from the reg32 parameters
	localparam  RUN = 2;							// Run (read from input, compute and write to output)

	//Signal declarations
	//State registers
	reg [1:0] currState;
	
	//Counter
	reg paramCount;
	
	//Message parameters
	reg [31:0] length;
	reg [31:0] multiplier;

	wire [31:0] lengthMinus1;
	assign lengthMinus1 = length - 1;

	// We don't write to the register file and we only write whole bytes to the output memory
	assign register32WriteData = 32'd0;
	assign register32WriteEn = 0;
	assign outputMemoryWriteByteMask = {OUTMEM_BYTE_WIDTH{1'b1}};
	
	//Variables for execution
	reg [1:0] lastPendingReads;
	wire [1:0] currPendingReads;
	wire [((INMEM_BYTE_WIDTH * 8) - 1):0] inputFifoDataOut;
	wire inputFifoEmpty;
	wire [1:0] inputFifoCount;
	wire fifoRead;
	wire	[(INMEM_ADDRESS_WIDTH - 1):0] nextInputAddress;
	reg inputDone;

	initial begin
		currState = IDLE;
		length = 0;
		
		userRunClear = 0;
		
		register32Address = 0;
		
		inputMemoryReadReq = 0;
		inputMemoryReadAdd = 0;
	
		outputMemoryWriteReq = 0;
		outputMemoryWriteAdd = 0;
		outputMemoryWriteData = 0;
		
		paramCount = 0;
		
		lastPendingReads = 0;
		inputDone = 0;
	end

	always @(posedge clk_sh) begin
		if(reset) begin
			currState <= IDLE;
			length <= 0;
			
			userRunClear <= 0;
			
			register32Address <= 0;
			
			inputMemoryReadReq <= 0;
			inputMemoryReadAdd <= 0;
			
			outputMemoryWriteReq <= 0;
			outputMemoryWriteAdd <= 0;
			outputMemoryWriteData <= 0;
			
			paramCount <= 0;
			
			lastPendingReads <= 0;
			inputDone <= 0;
			///////
			raddr <= 0;
			///////
		end
		else begin
			case(currState)
				IDLE: begin
					//Stop trying to clear the userRunRegister
					userRunClear <= 0;
					inputMemoryReadReq <= 0;
					
					//Wait till the run register goes high
					if(userRunValue == 1 && userRunClear != 1) begin
						//Start reading from the register file
						currState <= READING_IN_PARAMETERS;
						register32Address <= 0;
						register32CmdReq <= 1;
						paramCount <= 0;
					end
					///////
					raddr <= 0; // EDIT
					///////
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
							length <= multiplier;
							multiplier <= register32ReadData;
							paramCount <= 1;
							
							//Have we recieved the read for the second register?
							if(paramCount == 1)begin
								//Start requesting input data and execution
								currState <= RUN;
								inputMemoryReadReq <= 1;
								inputMemoryReadAdd <= 0;
								outputMemoryWriteAdd <= 0;
								inputDone <= 0;
							end
					end
				end
				RUN: begin
					//Logic to feed FIFO
					//If there is enough space in the fifo and there are more values to read, try to request a read the
					// next clock cycle
					if((currPendingReads + inputFifoCount < 4'd3) && inputDone == 0) begin
						inputMemoryReadReq <= 1;
					end
					else begin
						inputMemoryReadReq <= 0;
					end
					
					//If the input memory accepted the last read, we can increment the address
					if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd != lengthMinus1[(INMEM_ADDRESS_WIDTH - 1):0])begin
						inputMemoryReadAdd <= inputMemoryReadAdd + 1;
					end
					else if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd == lengthMinus1[(INMEM_ADDRESS_WIDTH - 1):0])begin
						inputDone <= 1;
					end
					
					//Logic on output side of FIFO
					//We should read from the input fifo if 
					// 1) the input fifo is not empty this cycle AND
					// 2) the output data is not currently valid or if we are writing the value this cycle
					if(fifoRead == 1) begin
						//If we are reading from the fifo this cycle, update the output registers.
						outputMemoryWriteReq <= 1;
						outputMemoryWriteData <= douta;// (inputFifoDataOut * multiplier) % 256; // EDIT
						///////
						raddr <= raddr + 1; // EDIT
						///////
					end
					//If we are not reading from the fifo this cycle, but we are are writing this cycle, then stop writing
					else if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1) begin
						outputMemoryWriteReq <= 0;
						//Are we done with all of the values yet?
						if(outputMemoryWriteAdd == lengthMinus1[(OUTMEM_ADDRESS_WIDTH - 1):0]) begin
							//If we just wrote the last output, go back to being idle
							currState <= IDLE;
							userRunClear <= 1;
						end
					end

					//If we just wrote a value to the output memory this cycle, increment the address
					if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1 && outputMemoryWriteAdd != lengthMinus1[(OUTMEM_ADDRESS_WIDTH - 1):0]) begin
						outputMemoryWriteAdd <= outputMemoryWriteAdd + 1;
					end
					
					lastPendingReads <= currPendingReads;
				end
			endcase
		end
	end
	
	//The current number of pending reads is:
	//	1) the last number of pending reads +1 if the memory is currently accepting a read request
	// 2) the last number of pending reads -1 if the memory is currently providing valid data
	// 3) the last number of pending reads if neither or both conditions are met.
	assign currPendingReads = ((inputMemoryReadReq == 1 && inputMemoryReadAck == 1) ~^ inputMemoryReadDataValid) ? lastPendingReads:
										((inputMemoryReadReq == 1 && inputMemoryReadAck == 1) ? lastPendingReads + 1 : lastPendingReads - 1);

	//We should read from the input fifo if 
	// 1) the input fifo is not currently empty and
	// 2) the output data is not currently valid or if we are writing the value this cycle
	assign fifoRead = ((outputMemoryWriteReq == 0) || (outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1)) && (inputFifoEmpty == 0);

	//We need to be able to buffer up to 4 values from the input memory.
	//Even if we stop requesting new values, pending reads will come back and we need to put them somewhere 
	FIFO #(.WIDTH((INMEM_BYTE_WIDTH * 8)))inFIFO(
			.clk(clk_sh),
			.reset(reset),
			.dataIn(inputMemoryReadData),
			.dataInWrite(inputMemoryReadDataValid),
			.dataOut(inputFifoDataOut),
			.dataOutRead(fifoRead),
			.empty(inputFifoEmpty),
			.currCount(inputFifoCount));
			
			
	


endmodule

//We need to be able to buffer up to N values from the input memory.
//Even if we stop requesting new values, pending reads will come back and we need to put them somewhere 
//In this case, we will make N = 4.
module FIFO#(
	parameter WIDTH = 8
)(	input 	wire 							clk,
	input 	wire 							reset,
	input 	wire [(WIDTH - 1): 0] 	dataIn,
	input 	wire 							dataInWrite,
	output 	wire [(WIDTH - 1): 0]	dataOut,
	input 	wire 							dataOutRead,
	output	wire 							empty,
	output 	wire [1:0] 					currCount);

	//Make an array of WIDTH-sized registers
	reg [(WIDTH - 1): 0] mem [0:3];
	reg [1:0] readAdd;
	reg [1:0] writeAdd;
	
	reg [1:0] count;
	
	initial begin
		count = 2'd0;
		readAdd = 2'd0;
		writeAdd = 2'd0;
	end
	always@(posedge clk) begin
		if(reset)begin
			count <= 2'd0;
			readAdd <= 2'd0;
			writeAdd <= 2'd0;
		end
		else begin
			if(dataInWrite == 1) begin
				writeAdd <= writeAdd + 1;
				mem[writeAdd] <= dataIn;
			end
			if(dataOutRead == 1) begin
				readAdd <= readAdd + 1;
			end
			count <= currCount;
		end
	end
	
	assign currCount = (dataInWrite == 1 && dataOutRead == 0 && count != 2'd3) ? (count + 1):
								((dataInWrite == 0 && dataOutRead == 1 && count != 2'd0) ? (count - 1) : count);
	assign empty = (count == 2'd0 && dataInWrite != 1);
	assign dataOut = (count == 2'd0) ? dataIn : (mem[readAdd]);
endmodule
	