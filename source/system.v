

`timescale 1ns / 1ps
`default_nettype none

module system #(
	parameter INMEM_USER_BYTE_WIDTH = 1,
	parameter OUTMEM_USER_BYTE_WIDTH = 1,

	parameter INMEM_USER_ADDRESS_WIDTH = 17,
	parameter OUTMEM_USER_ADDRESS_WIDTH = 13,

	parameter INMEM_USER_REGISTER = 1,

	parameter MAC_ADDRESS = 48'hAAAAAAAAAAAA
)(	
	input		wire			CLK_200N,			// Primary 200 MHz clock input
	input		wire			CLK_200P,			// Primary 200 MHz clock input
	input		wire			RESET,				// Active low reset from board-level button - resets everything on the board, from the
														
	//GMII PHY interface for EMAC0
	output	wire	[7:0]	GMII_TXD_0,			//GMII TX data output
	output	wire			GMII_TX_EN_0,		//GMII TX enable output
	output	wire			GMII_TX_ER_0,		//GMII TX error output
	output	wire			GMII_GTX_CLK_0,	//GMII GTX clock output - notice, this is not the same as the GMII_TX_CLK input!
	input    wire	[7:0]	GMII_RXD_0,			//GMII RX data input
	input		wire			GMII_RX_DV_0,		//GMII RX data valid input
	input		wire			GMII_RX_ER_0,		//GMII RX error input
	input		wire			GMII_RX_CLK_0,		//GMII RX clock input
	output	wire			GMII_RESET_B,		//GMII reset (active low)

	//SystemACE interface
	input		wire				sysACE_CLK1,		//33 MHz clock
	output 	wire	[6:0]		sysACE_MPADD,	//SystemACE Address
	inout 	wire	[15:0]	sysACE_MPDATA,	//SystemACE Data
	output	wire				sysACE_MPCE,	//SystemACE active low chip enable
	output	wire				sysACE_MPWE,	//SystemACE active low write enable
	output	wire				sysACE_MPOE,	//SystemACE active low output enable

	output	wire	[12:0]		LED,				//8 optional LEDs for visual feedback & debugging,
	/////
	input wire RST
	/////
);

//****

wire clk_1, clk_2, clk_RNG, sysACE_CLK;

wire clk_user_interface;		//Buffered version of user clock

CLOCK_TRNG CLOCK_TRNG1(
    .CLK_IN1(sysACE_CLK1),      // IN
    .CLK_OUT1(clk_1),     // OUT
    .CLK_OUT2(clk_2),// OUT
    .CLK_OUT3(clk_RNG),   // OUT
    .CLK_OUT4(sysACE_CLK));    // OUT
	 
// memory
wire wea;	 
wire [12:0] addra, raddr;
wire [12:0] waddr;
wire [7:0] dina, douta;
assign addra = wea? waddr : raddr;
wire mem_clk;

BUFGMUX_CTRL MEMCLK (
.O(mem_clk), // 1-bit output: Clock output
.I0(clk_user_interface), // 1-bit input: Clock input (S=0)
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
testPUF #(N_CB) test(
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
assign LED[8] = ~wea;	
assign LED[12:9] = 0;

//****

	//************Handle global asynchronous reset from physical switch on board
	// Buffer active low reset signal from board (for ML505, XUPV5 and other Virtex 5 boards)
	//wire hard_reset_low;
	// Buffer active high reset signal from board (for ML605)
	wire hard_reset_high;
		
	//************DISABLE RESET
	//If a physical reset switch is not desired, uncomment the next line and commenting out the IBUF declaration on the following line
	//assign hard_reset_low = 1'b1;
	//IBUF reset_ibuf (.I(RESET), .O(hard_reset_low));
	IBUF reset_ibuf (.I(RESET), .O(hard_reset_high));



	//************	Generate a single-ended 200 MHz reference clock, a 125MHz ethernet clock,
	//					and the user circuit clock from the external 200MHz double-ended clock
	// 125 = 200 * 5 / 8
	//wire clk_200_i;			//200 MHz clock single-ended clock before buffering
	wire clk_200;			//200 MHz clock after buffering
	wire clk_125_eth_i;	//125 MHz clock from PLL
	wire clk_125_eth;	//125 MHz clock after buffering
	wire pllFB;			//PLL feedback
	wire pllLock;			//PLL locked signal
	//************USER CLOCK
	//This is the clock for the user's interface to which the input/output buffers, register file and soft reset are synchronized.
	wire clk_user_interface_i;	//User clock directly from PLL
//	wire clk_user_interface;		//Buffered version of user clock
	
	IBUFGDS bufCLK_DS ( .I(CLK_200P), .IB(CLK_200N), .O(clk_200) );

	PLL_BASE #(
		.COMPENSATION("SYSTEM_SYNCHRONOUS"), 	// "SYSTEM_SYNCHRONOUS",
		.BANDWIDTH("OPTIMIZED"), 					// "HIGH", "LOW" or "OPTIMIZED"

		.CLKFBOUT_MULT(5), 							// Multiplication factor for all output clocks - 1000 = 200 * 5 / 1
		.DIVCLK_DIVIDE(1), 							// Division factor for all clocks (1 to 52)
		.CLKFBOUT_PHASE(0.0), 						// Phase shift (degrees) of all output clocks
		.REF_JITTER(0.100), 							// Input reference jitter (0.000 to 0.999 UI%)
		.CLKIN_PERIOD(5.0), 							// Clock period (ns) of input clock on CLKIN

		.CLKOUT0_DIVIDE(8), 							// Division factor - 125 = 1000 / 8
		.CLKOUT0_PHASE(0.0), 						// Phase shift (degrees) (0.0 to 360.0)
		.CLKOUT0_DUTY_CYCLE(0.5), 					// Duty cycle (0.01 to 0.99)

		//************USER CLOCK
		//If a 167 MHz clock is not appropriate for the interface to the user's circuit, make changes here or
		//		comment out the following 3 lines and create a new PLL
		//Also, don't forget to update system.ucf!
		.CLKOUT1_DIVIDE(6), 							// Division factor - 167 = 1000/6
		.CLKOUT1_PHASE(0.0), 						// Phase shift (degrees) (0.0 to 360.0)
		.CLKOUT1_DUTY_CYCLE(0.5) 					// Duty cycle (0.01 to 0.99)
	) clkBPLL (
		.CLKOUT0(clk_125_eth_i),					// 125 MHz
		//************USER CLOCK
		//If the user's circuit requires a different PLL, comment out the following line
		.CLKOUT1(clk_user_interface_i),					
		.CLKFBOUT(pllFB), 							// Clock feedback output
		.CLKIN(clk_200), 							// Clock input
		.CLKFBIN(pllFB), 							// Clock feedback input
		.LOCKED(pllLock), 							// Active high PLL lock signal
		//.RST(~hard_reset_low)						// The only thing that will reset the PLL is the physical reset button
		.RST(hard_reset_high)						// The only thing that will reset the PLL is the physical reset button
	);

	//Buffer clock signals coming out of PLL (these should be inserted automatically)
	//BUFG bufCLK_200 (.O(clk_200), .I(clk_200_i));
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
		.hardResetLow(~hard_reset_high),									//If this line goes low, the physical button told us to reset everything.
		//.hardResetLow(hard_reset_low),									//If this line goes low, the physical button told us to reset everything.
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

///////

///////

	//************Instantiate user module
	simpleTestModuleOne #(
		//Forward parameters to user circuit
		.INMEM_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
		.OUTMEM_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
		.INMEM_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
		.OUTMEM_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH)
	) tm(										
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
		//.LED(LED),
		/////
		.RAND(douta),
		.ADDRA(raddr)
		/////
	); 


endmodule 