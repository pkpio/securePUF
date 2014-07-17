// file: SysMon_tb.v
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.

//----------------------------------------------------------------------------
// System Monitor wizard demonstration testbench
//----------------------------------------------------------------------------
// This demonstration testbench instantiates the example design for the 
//   System Monitor wizard. Input clock is generated in this testbench.
//----------------------------------------------------------------------------

// This testbench does not implement  checking of averaging and calibration
// Bipolar signals are applied with Vn = 0

`timescale 1ps/1ps
`define wait_eoc @(negedge EOC_TB)
`define wait_eos @(posedge EOS_TB)
`define wait_drdy @(negedge DRDY_TB)
`define wait_done @(posedge BUSY_TB)
`define wait_busy @(negedge BUSY_TB)

module SysMon_tb ();

  // timescale is 1ps/1ps
  localparam  ONE_NS      = 1000;

  localparam time PER1    = 20*ONE_NS;
  // Declare the input clock signals
  reg         DCLK_TB     = 1;


  wire [6:0] DADDR_TB;
  wire DEN_TB;
  wire DWE_TB;
  wire [15:0] DI_TB;
  wire [15:0] DO_TB;
  wire DRDY_TB;


  wire [2:0] ALM_unused;




  wire FLOAT_VCCAUX_ALARM;
  wire FLOAT_VCCINT_ALARM;
  wire FLOAT_USER_TEMP_ALARM;


  wire BUSY_TB;

  wire [4:0] CHANNEL_TB;

  wire EOC_TB;

  wire EOS_TB;

  wire JTAGBUSY_TB;

  wire JTAGLOCKED_TB;

  wire JTAGMODIFIED_TB;



// Input clock generation

always begin
  DCLK_TB = #(PER1/2) ~DCLK_TB;
end


  assign DADDR_TB = {2'b00, CHANNEL_TB};
  assign DI_TB = 16'b0000000000000000;
  assign DWE_TB = 1'b0;
  assign DEN_TB = EOC_TB;

// Start of the testbench

initial
  begin
   $display ("Single channel avereraging is enabled");
   $display ("This TB does not verify averaging");
   $display ("Please increase the simulation duration to see complete waveform") ;
//// Single Channel setup
/////////////////////////////////////////////////////////////
//// Single Channel Mode - Temperature channel selected ////
/////////////////////////////////////////////////////////////
/// Channel selected is Temp. channel
  `wait_done;
  `wait_eoc;
  $display("EOC is asserted");
  if (CHANNEL_TB == 0) begin
    $display ("Monitored Temperature");
  end
  else begin
    $display ("Temperature is not monitored");
    $display ("ERROR !!!");
    $finish;
  end
  `wait_drdy;
  $display ("DRDY is asserted. Valid data is on the DO bus");
    $display ("Averaging Complete") ;
    $finish;
  `wait_eoc;
  $display ("EOC is asserted.");
  if( CHANNEL_TB == 0) begin
    $display ("Monitored Temperature.");
  end
  else begin
    $display ("USER TEMP is not monitored.");
    $display ("ERROR !!!");
    $finish;
  end
  `wait_drdy;
  $display ("DRDY is asserted. Valid data is on the DO bus");
    $display ("Averaging Complete") ;
    $finish;
  end

  // Instantiation of the example design
  //---------------------------------------------------------
  SysMon_exdes dut (
      .DADDR_IN(DADDR_TB[6:0]),
      .DCLK_IN(DCLK_TB),
      .DEN_IN(DEN_TB),
      .DI_IN(DI_TB[15:0]),
      .DWE_IN(DWE_TB),
      .BUSY_OUT(BUSY_TB),
      .CHANNEL_OUT(CHANNEL_TB[4:0]),
      .DO_OUT(DO_TB[15:0]),
      .DRDY_OUT(DRDY_TB),
      .EOC_OUT(EOC_TB),
      .EOS_OUT(EOS_TB),
      .JTAGBUSY_OUT(JTAGBUSY_TB),
      .JTAGLOCKED_OUT(JTAGLOCKED_TB),
      .JTAGMODIFIED_OUT(JTAGMODIFIED_TB),
      .VP_IN(1'b0),
      .VN_IN(1'b0)

         );

endmodule



