// file: TemperatureMonitor_exdes.v
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
// Clocking wizard example design
//----------------------------------------------------------------------------
// This example design instantiates the generated VHDL file containing the
// System Monitor instantiation.
//----------------------------------------------------------------------------

`timescale 1ns / 1 ps


module TemperatureMonitor_exdes(
          DADDR_IN,            // Address bus for the dynamic reconfiguration port
          DCLK_IN,             // Clock input for the dynamic reconfiguration port
          DEN_IN,              // Enable Signal for the dynamic reconfiguration port
          DI_IN,               // Input data bus for the dynamic reconfiguration port
          DWE_IN,              // Write Enable for the dynamic reconfiguration port
          DO_OUT,              // Output data bus for dynamic reconfiguration port
          DRDY_OUT,            // Data ready signal for the dynamic reconfiguration port
          VP_IN,               // Dedicated Analog Input Pair
          VN_IN);
     
     input VP_IN;
     input VN_IN;
    input [6:0] DADDR_IN;
    input DCLK_IN;
    input DEN_IN;
    input [15:0] DI_IN;
    input DWE_IN;
   output [15:0] DO_OUT;
   output DRDY_OUT;

    wire GND_BIT;
    wire [2:0] GND_BUS3;
    
     wire FLOAT_VCCAUX;
     
      wire FLOAT_VCCINT;
     
      wire FLOAT_USER_TEMP_ALARM;
    assign GND_BIT = 0;

TemperatureMonitor
sysmon_wiz_inst (
      .DADDR_IN(DADDR_IN[6:0]),
      .DCLK_IN(DCLK_IN),
      .DEN_IN(DEN_IN),
      .DI_IN(DI_IN[15:0]),
      .DWE_IN(DWE_IN),
      .DO_OUT(DO_OUT[15:0]),
      .DRDY_OUT(DRDY_OUT),
      .VP_IN(VP_IN),
      .VN_IN(VN_IN)
      );

endmodule
