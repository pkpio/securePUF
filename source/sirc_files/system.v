// Ken Eguro
//		Alpha version - 2/11/09
//		Version 1.0 - 1/4/10
//		Version 1.0.1 - 5/7/10
//		Version 1.1 - 8/1/11
//
//	To use this code, please refer to the README document for information regarding generating
//		the necessary modules from COREgen and setting the MAC address of the FPGA.
//	When replacing the default "user circuit" with their own, the user will probably need to:
//		1) set input and output block memory parameters in the "system" module (IN/OUTMEM_USER_BYTE_WIDTH, IN/OUTMEM_USER_ADDRESS_WIDTH, INMEM_USER_REGISTER)
//		2) if any of the parameters are changed from their default values, update the .xco and regenerate input and/or output memories in COREGen
//		3) set desired MAC address for the FPGA in the "system" module (MAC_ADDRESS parameter)
//		4) if something other than a 167MHz user circuit clock is desired, edit the "clkBPLL" module/system.ucf appropriately or add a new clock module
//				(hints are given below, search for "USER CLOCK")
//		5) determine if they want to disable the physical whole-system reset button on the board itself
//				(hints are given below, search for "DISABLE RESET")
//		6) replace simpleTestModule with their own code

`timescale 1ns / 1ps
`default_nettype none

module system #(
	//************ Input and output block memory parameters
	//The user's circuit communicates with the input and output memories as N-byte chunks
	//These should be defined as {1, 2, 4, 8, 16, 32} corresponding to an 8, 16, 32, 64, 128, or 256-bit interface.
	//If this value is changed, reflect the changes in the input/output memory .xco and regenerate the core.
	//Note that if more than 1 byte is used by the user, the organization of the bytes are little endian.  For example if N=4,
	// address 32-bit word 0 = {b3:b2:b1:b0}
	// address 32-bit word 1 = {b7:b6:b5:b4}...
	parameter INMEM_USER_BYTE_WIDTH = 1,
	parameter OUTMEM_USER_BYTE_WIDTH = 1,
	//How many address lines are required by the input and output buffers?
	//Stated another way, the "BYTE_WIDTH" parameter determined the width of the words,
	// the "ADDRESS_WIDTH" parameter determines the 2^M word height of buffer.
	//If this value is changed, reflect the changes in the input/output memory .xco and regenerate the core.
	parameter INMEM_USER_ADDRESS_WIDTH = 17,
	parameter OUTMEM_USER_ADDRESS_WIDTH = 13,
	//Was the input memory generated with the "Register Port B Output of Memory Core" box checked?
	//This should be 0 if not, 1 if so.  If this value is changed, reflect the modification in the
	// input memory .xco and regenerate the core.  Technically, it is also possible to account for selecting the
	// "Register Port B Output of Memory Primitives" option.  Either way, the value of this parameter should be equal 
	//		to the value reported by COREGen in the "Latency Added by Output register(s)", "Port B:" field.
	parameter INMEM_USER_REGISTER = 1,
	//What MAC address should the FPGA use?
	//This value is set within the project and does *not* require regeneration of the ethernet core.
	parameter MAC_ADDRESS = 48'hAAAAAAAAAAAA
)(	
	input		wire 			CLK_100,				// Primary 100 MHz clock input
	input		wire 			RESET,				// Active low reset from board-level button - resets everything on the board, from the
														//		user's circuit to the API controller to the ethernet PHY & clock generation circuits.
														//	Should not normally need to be used.  Try the software command sendReset() instead.
														//	However, in the worst-case situation where the board stops responding to all 
														//		ethernet commands, it is available to reset everything including the PHY

	//GMII PHY interface for EMAC0
	output	wire [7:0]	GMII_TXD_0,			//GMII TX data output
	output	wire 			GMII_TX_EN_0,		//GMII TX enable output
	output	wire 			GMII_TX_ER_0,		//GMII TX error output
	output	wire 			GMII_GTX_CLK_0,	//GMII GTX clock output - notice, this is not the same as the GMII_TX_CLK input!
	input    wire [7:0]	GMII_RXD_0,			//GMII RX data input
	input		wire 			GMII_RX_DV_0,		//GMII RX data valid input
	input		wire 			GMII_RX_ER_0,		//GMII RX error input
	input		wire 			GMII_RX_CLK_0,		//GMII RX clock input
	output	wire 			GMII_RESET_B,		//GMII reset (active low)

	//SystemACE interface
	input		wire 			sysACE_CLK,			//33 MHz clock
	output 	wire [6:0]	sysACE_MPADD,		//SystemACE Address
	inout 	wire [15:0]	sysACE_MPDATA,		//SystemACE Data
	output	wire 			sysACE_MPCE,		//SystemACE active low chip enable
	output	wire 			sysACE_MPWE,		//SystemACE active low write enable
	output	wire 			sysACE_MPOE,		//SystemACE active low output enable
	//input	wire 				sysACE_MPBRDY,	//SystemACE active high buffer ready signal - currently unused
	//input	wire 				sysACE_MPIRQ,	//SystemACE active high interrupt request - currently unused

	output	wire [7:0]	LED,					//8 optional LEDs for visual feedback & debugging
	/////
	input wire RST
	/////
);


	//************Handle global asynchronous reset from physical switch on board
	// Buffer active low reset signal from board.
	wire hard_reset_low;
	//************DISABLE RESET
	//If a physical reset switch is not desired, uncomment the next line and commenting out the IBUF declaration on the following line
	//assign hard_reset_low = 1'b1;
	IBUF reset_ibuf (.I(RESET), .O(hard_reset_low));



	//************Generate a 200 MHz reference clock, a 125MHz ethernet clock and the user circuit clock from the 100 MHz clock provided
	// 200 = 100 * 10 / 5
	// 125 = 100 * 10 / 8
	wire clk_200_i;		//200 MHz clock from PLL
	wire clk_200;			//200 MHz clock after buffering
	wire clk_125_eth_i;	//125 MHz clock from PLL
	wire clk_125_eth;	//125 MHz clock after buffering
	wire pllFB;			//PLL feedback
	wire pllLock;			//PLL locked signal
	//************USER CLOCK
	//This is the clock for the user's interface to which the input/output buffers, register file and soft reset are synchronized.
	wire clk_user_interface_i;	//User clock directly from PLL
	wire clk_user_interface;		//Buffered version of user clock
	PLL_BASE #(
		.COMPENSATION("SYSTEM_SYNCHRONOUS"), 	// "SYSTEM_SYNCHRONOUS",
		.BANDWIDTH("OPTIMIZED"), 					// "HIGH", "LOW" or "OPTIMIZED"

		.CLKFBOUT_MULT(10), 						// Multiplication factor for all output clocks - 1000 = 100 * 10 / 1
		.DIVCLK_DIVIDE(1), 							// Division factor for all clocks (1 to 52)
		.CLKFBOUT_PHASE(0.0), 						// Phase shift (degrees) of all output clocks
		.REF_JITTER(0.100), 						// Input reference jitter (0.000 to 0.999 UI%)
		.CLKIN_PERIOD(10.0), 						// Clock period (ns) of input clock on CLKIN

		.CLKOUT0_DIVIDE(5), 						// Division factor - 200 = 1000 / 5
		.CLKOUT0_PHASE(0.0), 						// Phase shift (degrees) (0.0 to 360.0)
		.CLKOUT0_DUTY_CYCLE(0.5), 				// Duty cycle (0.01 to 0.99)
		.CLKOUT1_DIVIDE(8), 						// Division factor - 125 = 1000 / 8
		.CLKOUT1_PHASE(0.0), 						// Phase shift (degrees) (0.0 to 360.0)
		.CLKOUT1_DUTY_CYCLE(0.5), 				// Duty cycle (0.01 to 0.99)
		//************USER CLOCK
		//If a 167 MHz clock is not appropriate for the interface to the user's circuit, make changes here or
		//		comment out the following 3 lines and create a new PLL
		//Also, don't forget to update system.ucf!
		.CLKOUT2_DIVIDE(6), 						// Division factor - 167 = 1000/6
		.CLKOUT2_PHASE(0.0), 						// Phase shift (degrees) (0.0 to 360.0)
		.CLKOUT2_DUTY_CYCLE(0.5) 					// Duty cycle (0.01 to 0.99)
	) clkBPLL (
		.CLKOUT0(clk_200_i),						// 200 MHz
		.CLKOUT1(clk_125_eth_i),					// 125 MHz
		//************USER CLOCK
		//If the user's circuit requires a different PLL, comment out the following line
		.CLKOUT2(clk_user_interface_i),	//167MHz				
		.CLKFBOUT(pllFB), 							// Clock feedback output
		.CLKIN(CLK_100), 							// Clock input
		.CLKFBIN(pllFB), 							// Clock feedback input
		.LOCKED(pllLock), 							// Active high PLL lock signal
		.RST(~hard_reset_low)						// The only thing that will reset the PLL is the physical reset button
	);

	//Buffer clock signals coming out of PLL
	BUFG bufCLK_200 (.O(clk_200), .I(clk_200_i));
	BUFG bufCLK_125 (.O(clk_125_eth), .I(clk_125_eth_i));
	BUFG bufCLK_user (.O(clk_user_interface), .I(clk_user_interface_i));
	


	//************Instantiate ethernet communication controller
	//This is a line that tells that user's circuit to reset.
	//Notice, this is not a reset for the entire system, just the user's circuit
	wire userLogicReset;
	
	//Wires from the user design to the communication controller
	wire userRunValue;																			//Read run register value
	wire userRunClear;																			//Reset run register
	
	//Interface to parameter register file
	wire register32CmdReq;																		//Parameter register handshaking request signal
	wire register32CmdAck;																		//Parameter register handshaking acknowledgment signal
	wire [31:0] register32WriteData;														//Parameter register write data
	wire [7:0] register32Address;															//Parameter register address
	wire register32WriteEn;																	//Parameter register write enable
	wire register32ReadDataValid;															//Indicates that a read request has returned with data
	wire [31:0] register32ReadData;														//Parameter register read data
									
	//Interface to input memory
	wire inputMemoryReadReq;																	//Input memory handshaking request signal
	wire inputMemoryReadAck;																	//Input memory handshaking acknowledgment signal
	wire [(INMEM_USER_ADDRESS_WIDTH - 1):0] 		inputMemoryReadAdd;			//Input memory read address line
	wire inputMemoryReadDataValid;															//Indicates that a read request has returned with data
	wire [((INMEM_USER_BYTE_WIDTH * 8) - 1):0] 	inputMemoryReadData;			//Input memory read data line

	//Interface to output memory
	wire outputMemoryWriteReq;																//Output memory handshaking request signal
	wire outputMemoryWriteAck;																//Output memory handshaking acknowledgment signal
	wire [(OUTMEM_USER_ADDRESS_WIDTH - 1):0] 		outputMemoryWriteAdd;		//Output memory write address line
	wire [((OUTMEM_USER_BYTE_WIDTH * 8) - 1):0]	outputMemoryWriteData;		//Output memory write data line
	wire [(OUTMEM_USER_BYTE_WIDTH - 1):0]			outputMemoryWriteByteMask;	//Output memory write byte mask

	ethernet2BlockMem #(
		//Forward parameters to controller
		.INMEM_USER_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
		.OUTMEM_USER_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
		.INMEM_USER_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
		.OUTMEM_USER_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH),
		.INMEM_USER_REGISTER(INMEM_USER_REGISTER),
		.MAC_ADDRESS(MAC_ADDRESS)
	) E2M(
		.refClock(clk_200),													//This should be a 200 Mhz reference clock
		.clockLock(pllLock),												//This line from the clock generator indicates when the clocks are stable
		.hardResetLow(hard_reset_low),									//If this line goes low, the physical button told us to reset everything.
		.ethClock(clk_125_eth),											//This should be a 125 MHz source clock
		
		// GMII Interface - EMAC0
		.GMII_TXD(GMII_TXD_0),												//GMII TX data output
		.GMII_TX_EN(GMII_TX_EN_0),										//GMII TX enable output
		.GMII_TX_ER(GMII_TX_ER_0),										//GMII TX error output
		.GMII_GTX_CLK(GMII_GTX_CLK_0),									//GMII GTX clock output - notice, this is not the same as the GMII_TX_CLK input!
		.GMII_RXD(GMII_RXD_0),												//GMII RX data input
		.GMII_RX_DV(GMII_RX_DV_0),										//GMII RX data valid input
		.GMII_RX_ER(GMII_RX_ER_0),										//GMII RX error input
		.GMII_RX_CLK(GMII_RX_CLK_0),										//GMII RX clock input
		.GMII_RESET_B(GMII_RESET_B),										//GMII reset (active low)

		//SystemACE Interface
		.sysACE_CLK(sysACE_CLK),											//33 MHz clock
		.sysACE_MPADD(sysACE_MPADD),										//SystemACE Address
		.sysACE_MPDATA(sysACE_MPDATA),									//SystemACE Data in/out
		.sysACE_MPCE(sysACE_MPCE),										//SystemACE active low chip enable
		.sysACE_MPWE(sysACE_MPWE),										//SystemACE active low write enable
		.sysACE_MPOE(sysACE_MPOE),										//SystemACE active low output enable
		//.sysACE_MPBRDY(sysACE_MPBRDY),									//SystemACE active high buffer ready signal - currently unused
		//.sysACE_MPIRQ(sysACE_MPIRQ),									//SystemACE active high interrupt request - currently unused

		//************User-side interface
		.userInterfaceClk(clk_user_interface),						//This is the clock to which the user's interface to the controller is synchronized (register file, i/o buffers & reset)
		.userLogicReset(userLogicReset),								//This signal should be used to reset the user's circuit
																					//This will be asserted at configuration time, when the physical button is pressed or when the
																					//		sendReset command is received over the Ethernet.
		.userRunValue(userRunValue),										//Read run register value
		.userRunClear(userRunClear),										//Reset run register (active high)
		
		//User interface to parameter register file
		.register32CmdReq(register32CmdReq),							//Parameter register handshaking request signal
		.register32CmdAck(register32CmdAck),							//Parameter register handshaking acknowledgment signal
		.register32WriteData(register32WriteData),					//Parameter register write data
		.register32Address(register32Address),						//Parameter register address
		.register32WriteEn(register32WriteEn),						//Parameter register write enable
		.register32ReadDataValid(register32ReadDataValid),		//Indicates that a read request has returned with data
		.register32ReadData(register32ReadData),						//Parameter register read data
		
		//User interface to input memory
		.inputMemoryReadReq(inputMemoryReadReq),						//Input memory handshaking request signal
		.inputMemoryReadAck(inputMemoryReadAck),						//Input memory handshaking acknowledgment signal
		.inputMemoryReadAdd(inputMemoryReadAdd),						//Input memory read address line
		.inputMemoryReadDataValid(inputMemoryReadDataValid),		//Indicates that a read request has returned with data
		.inputMemoryReadData(inputMemoryReadData),					//Input memory read data line
		
		//User interface to output memory
		.outputMemoryWriteReq(outputMemoryWriteReq),				//Output memory handshaking request signal
		.outputMemoryWriteAck(outputMemoryWriteAck),				//Output memory handshaking acknowledgment signal
		.outputMemoryWriteAdd(outputMemoryWriteAdd),				//Output memory write address line
		.outputMemoryWriteData(outputMemoryWriteData),				//Output memory write data line
		.outputMemoryWriteByteMask(outputMemoryWriteByteMask)	//Output memory write byte mask
	);



	//************Instantiate user module
	SircHandler #(
		//Forward parameters to user circuit
		.INMEM_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
		.OUTMEM_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
		.INMEM_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
		.OUTMEM_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH)
	) sh(										
      .clk(clk_user_interface),										//For simplicity sake (although it doesn't have to), the entire user circuit can run off of the same 
																					//		clock used to synchronize the interface.
      .reset(userLogicReset),											//When this signal is asserted (it is synchronous to userInterfaceClk), the user's circuit should reset
		
		.userRunValue(userRunValue),										//Read run register value - when this is asserted, the user's circuit has control over the i/o buffers & register file
		.userRunClear(userRunClear),										//Reset run register	- assert this signal for 1 clock cycle to indicate that the user's circuit has completed computation and
																					//		wishes to return control over the i/o buffers and register file back to the controller
		
		//User interface to parameter register file
		.register32CmdReq(register32CmdReq),							//Parameter register handshaking request signal
		.register32CmdAck(register32CmdAck),							//Parameter register handshaking acknowledgment signal
		.register32WriteData(register32WriteData),					//Parameter register write data
		.register32Address(register32Address),						//Parameter register address
		.register32WriteEn(register32WriteEn),						//Parameter register write enable
		.register32ReadDataValid(register32ReadDataValid),		//Indicates that a read request has returned with data
		.register32ReadData(register32ReadData),						//Parameter register read data
		
		//User interface to input memory
		.inputMemoryReadReq(inputMemoryReadReq),						//Input memory handshaking request signal - assert to begin a read request
		.inputMemoryReadAck(inputMemoryReadAck),						//Input memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
		.inputMemoryReadAdd(inputMemoryReadAdd),						//Input memory read address - can be set the same cycle that the req line is asserted
		.inputMemoryReadDataValid(inputMemoryReadDataValid),		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
		.inputMemoryReadData(inputMemoryReadData),					//Input memory read data
		
		//User interface to output memory
		.outputMemoryWriteReq(outputMemoryWriteReq),				//Output memory handshaking request signal - assert to begin a write request
		.outputMemoryWriteAck(outputMemoryWriteAck),				//Output memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
		.outputMemoryWriteAdd(outputMemoryWriteAdd),				//Output memory write address - can be set the same cycle that the req line is asserted
		.outputMemoryWriteData(outputMemoryWriteData),				//Output memory write data
		.outputMemoryWriteByteMask(outputMemoryWriteByteMask),	//Allows byte-wise writes when multibyte words are used - each of the OUTMEM_USER_BYTE_WIDTH line can be 0 (do not write byte) or 1 (write byte)
		
		//Optional connection to 8 LEDs for debugging, etc.
		.LED(LED),
		.RST(RST)
		 );
endmodule