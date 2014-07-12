// Ken Eguro
//		Alpha version - 2/11/09
//		Version 1.0 - 1/4/10
//		Version 1.0.1 - 5/7/10
//		Version 1.1 - 8/1/11

`timescale 1ns / 1ps
`default_nettype none
	
module ethernet2BlockMem #(
	//************ Input and output block memory parameters
	//The user's circuit communicates with the input and output memories as N-byte chunks
	//This should be some power of 2 >= 1.
	parameter INMEM_USER_BYTE_WIDTH = 1,
	parameter OUTMEM_USER_BYTE_WIDTH = 1,
	
	//How many N-byte words does the user's circuit use?
	parameter INMEM_USER_ADDRESS_WIDTH = 17,
	parameter OUTMEM_USER_ADDRESS_WIDTH = 13,
	
	//Does the user side of the memory have extra registers?
	parameter INMEM_USER_REGISTER = 1,

	//What MAC address should the FPGA use?
	parameter MAC_ADDRESS = 48'hAAAAAAAAAAAA
)(
	input		wire 			refClock,																		//This should be a 200 Mhz reference clock
	input		wire 			clockLock,     																//This active high signal indicates when the clock generation circuit is stable
	input		wire 			hardResetLow,    																//This active low signal is from a physical switch - this should cause the GMII, 
																													//		systemACE, ethernet controller and the user's circuit to all reset
	input		wire 			ethClock,																		//This should be a 125 MHz source clock
	
	// GMII PHY interface for hard EMAC
	output	wire [7:0] 	GMII_TXD,																		//GMII TX data output
	output	wire 			GMII_TX_EN,																		//GMII TX enable output
	output	wire 			GMII_TX_ER,																		//GMII TX error output
	output	wire 			GMII_GTX_CLK,																	//GMII GTX clock output - notice, this is not the same as the GMII_TX_CLK input!
	input		wire [7:0] 	GMII_RXD,																		//GMII RX data input
	input		wire 			GMII_RX_DV,																		//GMII RX data valid input
	input		wire 			GMII_RX_ER,																		//GMII RX error input
	input		wire 			GMII_RX_CLK,																	//GMII RX clock input
	output	wire 			GMII_RESET_B,																	//GMII reset (active low)

	//SystemACE interface
	input		wire 			sysACE_CLK,																		//33 MHz clock
	output	wire [6:0]	sysACE_MPADD,																	//SystemACE Address
	inout		wire [15:0]	sysACE_MPDATA,																	//SystemACE Data
	output	wire 			sysACE_MPCE,																	//SystemACE active low chip enable
	output	wire 			sysACE_MPWE,																	//SystemACE active low write enable
	output	wire 			sysACE_MPOE,																	//SystemACE active low output enable
	//input	wire 				sysACE_MPBRDY,																//SystemACE active high buffer ready signal - currently unused
	//input	wire 				sysACE_MPIRQ,																//SystemACE active high interrupt request - currently unused
	
	//User circuit interface
	input 	wire 			userInterfaceClk,																//This is the clock to which the user circuit's register file and memories accesses are synchronized
	output 	wire 			userLogicReset,																//This signal should be used to reset the user's circuit
																													//This will be asserted at configuration time, when the physical button is pressed or when the
																													//		sendReset command is received over the Ethernet.
																												
	output 	wire 			userRunValue,																	//Run register value
	input 	wire 			userRunClear,																	//Reset run register? (active high)

	//User interface to parameter register file
	input 	wire 			register32CmdReq,																//Parameter register handshaking request signal
	output	wire 			register32CmdAck,																//Parameter register handshaking acknowledgment signal
	input		wire [31:0] register32WriteData,															//Parameter register write data
	input 	wire [7:0] 	register32Address,															//Parameter register address
	input 	wire 			register32WriteEn,															//Parameter register write enable
	output 	wire 			register32ReadDataValid,													//Indicates that a read request has returned with data
	output 	wire [31:0] register32ReadData,															//Parameter register read data

	//User interface to input memory
	input 	wire 														inputMemoryReadReq,				//Input memory handshaking request signal
	output	wire 														inputMemoryReadAck,				//Input memory handshaking acknowledgment signal
	input		wire [(INMEM_USER_ADDRESS_WIDTH - 1):0] 		inputMemoryReadAdd,				//Input memory read address line
	output 	wire 														inputMemoryReadDataValid,		//Indicates that a read request has returned with data
	output	wire [((INMEM_USER_BYTE_WIDTH * 8) - 1):0] 	inputMemoryReadData,				//Input memory read data line
	
	//User interface to output memory
	input 	wire 														outputMemoryWriteReq,			//Output memory handshaking request signal
	output 	wire 														outputMemoryWriteAck,			//Output memory handshaking acknowledgment signal
	input		wire [(OUTMEM_USER_ADDRESS_WIDTH - 1):0] 		outputMemoryWriteAdd,			//Output memory write address line
	input		wire [((OUTMEM_USER_BYTE_WIDTH * 8) - 1):0] 	outputMemoryWriteData,			//Output memory write data line
	input 	wire [(OUTMEM_USER_BYTE_WIDTH - 1):0]			outputMemoryWriteByteMask		//Output memory write byte mask
);
	//************Handle all reset lines
	//This reset line is active low when the physical reset button (active low) is pressed or before the clock circuitry is locked (active high).
	wire				hardResetClockLockLow;
	assign			hardResetClockLockLow = hardResetLow && clockLock;

	// If we have trouble capturing incoming data, we may need to align the RX data with the RX clock.
	// This will require an IDELAY & IDELAYCTRL module.
	// The reset line (active high) of the IDELAYCTRL must be asserted for 50 ns 
	//	 	(10 clock cycles at 200Mhz).  For safety, let's have 3 extra cycles.
	// Since this reset is asserted for so long, we can also use it as a synchronous reset for the 
	//		user circuits, etc down to 20MHz.  It will be also be used to reset everything in the
	//		API side except the PHY (note on this below).
	wire				hardResetClockLockLong;
	reg [12:0] 	delayCtrl0Reset;
	wire 				gmii_rx_clk_delay;
	
	always @(posedge refClock, negedge hardResetClockLockLow) begin
	  if (hardResetClockLockLow == 1'b0)begin
			delayCtrl0Reset <= 13'b1111111111111;
	  end
	  else begin
			delayCtrl0Reset <= {delayCtrl0Reset[11:0], 1'b0};
	  end
	end
	assign hardResetClockLockLong = delayCtrl0Reset[12];

	IDELAYCTRL delayCtrl0(
	  .RDY(),
	  .REFCLK(refClock),
	  .RST(hardResetClockLockLong)
	);
	
	IDELAY #(
		.IOBDELAY_TYPE("FIXED"),
		.IOBDELAY_VALUE(0)
	) delayRXClk(
		.I(GMII_RX_CLK),
		.C(1'b0),
		.INC(1'b0),
		.CE(1'b0),
		.RST(1'b0),
		.O(gmii_rx_clk_delay)
	);
	
	//In general, we do not want to reset the GMII connection unnecessarily because this will also cause
	//		the PHY to reset.  The PHY takes 5-7 seconds to negotiate the connection and come back to life.
	//This can be a problem if we want to do fast reconfiguration of the whole chip.
	//Most of the time resetting the PHY is not necessary, but if worst comes to worst we want to be able to
	//		reset the PHY by using the physical reset button on the board (assuming it is connected).  
	//To avoid resetting when a new configuration is loaded, we specifically do not hook this up to 
	//		the reset that includes the clock locking signal.
	//Normally, this should not be an issue for end users as they will not be editing the controller code.
	//This should work and keep the line high unless the button is pushed.  However, in theory since we are 
	//		connecting this to an IBUF (all primary input signals go through these), could we get some glitching 
	//		on the line when reconfiguring?  We have not noticed this in testing.
	assign GMII_RESET_B = hardResetLow;
	
	
	//************Instantiate the GMII to LocalLink logic from COREgen
	// User local link TX connections
	wire 	[7:0] 	tx_ll_data_out;
	wire       		tx_ll_sof_out;
	wire        	tx_ll_eof_out;
	wire				tx_ll_src_rdy_out;
	wire				tx_ll_dst_rdy_in;

	//User local link RX connections
	wire [7:0] 	rx_ll_data_in;
	wire   	     	rx_ll_sof_in;
	wire        	rx_ll_eof_in;
	wire        	rx_ll_src_rdy_in;
	wire        	rx_ll_dst_rdy_out;

	emac_single_locallink emac_ll(
		// EMAC0 Clocking
		// TX Clock output from EMAC
 		.TX_CLK_OUT                          (),				//We only pay attention to this signal when we are in 10/100 mode
																			//	(which the Xilinx logic doens't seem to support correctly)
		// EMAC0 TX Clock input from BUFG
		.TX_CLK_0                            (ethClock),

		// Local link Receiver Interface - EMAC0
		.RX_LL_CLOCK_0                       (ethClock),
		.RX_LL_RESET_0                       (hardResetClockLockLong),
		.RX_LL_DATA_0                        (rx_ll_data_in),
		.RX_LL_SOF_N_0                       (rx_ll_sof_in),
		.RX_LL_EOF_N_0                       (rx_ll_eof_in),
		.RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_in),
		.RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_out),
		.RX_LL_FIFO_STATUS_0                 (),

		// Unused Receiver signals - EMAC0
//    .EMAC0CLIENTRXDVLD                   (EMAC0CLIENTRXDVLD),
//    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
//    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
//    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
//    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),

		// Local link Transmitter Interface - EMAC0
		.TX_LL_CLOCK_0                       (ethClock),
		.TX_LL_RESET_0                       (hardResetClockLockLong),
		.TX_LL_DATA_0                        (tx_ll_data_out),
		.TX_LL_SOF_N_0                       (tx_ll_sof_out),
		.TX_LL_EOF_N_0                       (tx_ll_eof_out),
		.TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_out),
		.TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_in),

		// Unused Transmitter signals - EMAC0
//    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
//    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
//    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
//    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),
		.CLIENTEMAC0TXIFGDELAY               (8'd0),			//Added to remove warning


		// MAC Control Interface - EMAC0
//    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
//    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),
		.CLIENTEMAC0PAUSEREQ                (1'd0),			//Added to remove warning
		.CLIENTEMAC0PAUSEVAL                (16'd0),			//Added to remove warning


		.GTX_CLK_0                           (ethClock),

		// GMII Interface - EMAC0
		.GMII_TXD_0                          (GMII_TXD),
		.GMII_TX_EN_0                        (GMII_TX_EN),
		.GMII_TX_ER_0                        (GMII_TX_ER),
		.GMII_TX_CLK_0                       (GMII_GTX_CLK),		//This is an output from the EMAC block from Xilinx.  This is odd since the 
		.GMII_RXD_0                          (GMII_RXD),				//		GMII TX clk should be an output of the phy - GMII GTX clk should be a 
		.GMII_RX_DV_0                        (GMII_RX_DV),			//		input to the phy.  What this really represents is how fast the EMAC is 
		.GMII_RX_ER_0                        (GMII_RX_ER),			//		actually running - this is just an loop-around of the TX_CLK_0 line from above
		.GMII_RX_CLK_0                       (gmii_rx_clk_delay),

		// Asynchronous Reset Input
		.RESET                               (hardResetClockLockLong)
	);
	
	//************Instantiate the LocalLink to RAM and SystemACE interface
	ethernetController #(
		//Forward parameters to controller
		.INMEM_USER_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
		.OUTMEM_USER_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
		.INMEM_USER_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
		.OUTMEM_USER_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH),
		.INMEM_USER_REGISTER(INMEM_USER_REGISTER),
		.MAC_ADDRESS(MAC_ADDRESS)
	)	EC(
		.controllerSideClock(ethClock),									//This clock runs the LocalLink FIFOs and the controller side of the memory - must be >= 125MHz
		.reset(hardResetClockLockLong),									//Reset for the controller

		//Interface to eth<->LocalLink module
		.rx_ll_data_in(rx_ll_data_in),       						// Input data
		.rx_ll_sof_in(rx_ll_sof_in),     								// Input start of frame
		.rx_ll_eof_in(rx_ll_eof_in),     								// Input end of frame
		.rx_ll_src_rdy_in(rx_ll_src_rdy_in),  						// Input source ready (emac module)
		.rx_ll_dst_rdy_out(rx_ll_dst_rdy_out), 						// Input receiver ready (this module)

		.tx_ll_data_out(tx_ll_data_out),      						// Output data
		.tx_ll_sof_out(tx_ll_sof_out), 			   					// Output start of frame
		.tx_ll_eof_out(tx_ll_eof_out),     							// Output end of frame
		.tx_ll_src_rdy_out(tx_ll_src_rdy_out), 						// Output source ready (this module)
		.tx_ll_dst_rdy_in(tx_ll_dst_rdy_in),		  					// Output receiver ready (emac module)

		//SystemACE interface
		.sysACE_CLK(sysACE_CLK),											//33 MHz clock
		.sysACE_MPADD(sysACE_MPADD),										//SystemACE Address
		.sysACE_MPDATA(sysACE_MPDATA),									//SystemACE Data
		.sysACE_MPCE(sysACE_MPCE),										//SystemACE active low chip enable
		.sysACE_MPWE(sysACE_MPWE),										//SystemACE active low write enable
		.sysACE_MPOE(sysACE_MPOE),										//SystemACE active low output enable
		//.sysACE_MPBRDY(sysACE_MPBRDY),									//SystemACE active high buffer ready signal - currently unused
		//.sysACE_MPIRQ(sysACE_MPIRQ),									//SystemACE active high interrupt request - currently unused

		//User interface to user logic
		.userInterfaceClock(userInterfaceClk),						//This is the clock to which the user-side register file and memories accesses are synchronized
		.userLogicReset(userLogicReset),								//Reset signal to the user-side circuit.
		
																					//A user application can only check the status of the run register and reset it to zero
		.userRunValue(userRunValue),										//Run register value
		.userRunClear(userRunClear),										//Does the user circuit want to reset the run register? (active high)
		
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
endmodule