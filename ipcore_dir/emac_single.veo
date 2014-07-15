//-----------------------------------------------------------------------------
// Title      : Verilog instantiation template
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : emac_single.veo
// Version    : 1.8
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
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
//
//-----------------------------------------------------------------------------
// Description: Verilog instantiation template for the Virtex-5 Embedded
//              Tri-Mode Ethernet MAC Wrapper (block-level wrapper).
//-----------------------------------------------------------------------------


// The following must be inserted into your Verilog file for this core to
// be instantiated. Change the port connections to your own signal names.

    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper (emac_single_block.v)
    //------------------------------------------------------------------------
    emac_single_block v5_emac_block_inst
    (
    // EMAC0 Clocking
    // TX Clock output from EMAC
    .TX_CLK_OUT                          (TX_CLK_OUT),
    // EMAC0 TX Clock input from BUFG
    .TX_CLK_0                            (TX_CLK_0),

    // Client Receiver Interface - EMAC0
    .EMAC0CLIENTRXD                      (EMAC0CLIENTRXD),
    .EMAC0CLIENTRXDVLD                   (EMAC0CLIENTRXDVLD),
    .EMAC0CLIENTRXGOODFRAME              (EMAC0CLIENTRXGOODFRAME),
    .EMAC0CLIENTRXBADFRAME               (EMAC0CLIENTRXBADFRAME),
    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),

    // Client Transmitter Interface - EMAC0
    .CLIENTEMAC0TXD                      (CLIENTEMAC0TXD),
    .CLIENTEMAC0TXDVLD                   (CLIENTEMAC0TXDVLD),
    .EMAC0CLIENTTXACK                    (EMAC0CLIENTTXACK),
    .CLIENTEMAC0TXFIRSTBYTE              (CLIENTEMAC0TXFIRSTBYTE),
    .CLIENTEMAC0TXUNDERRUN               (CLIENTEMAC0TXUNDERRUN),
    .EMAC0CLIENTTXCOLLISION              (EMAC0CLIENTTXCOLLISION),
    .EMAC0CLIENTTXRETRANSMIT             (EMAC0CLIENTTXRETRANSMIT),
    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),


    .GTX_CLK_0                           (GTX_CLK_0),

    // GMII Interface - EMAC0
    .GMII_TXD_0                          (GMII_TXD_0),
    .GMII_TX_EN_0                        (GMII_TX_EN_0),
    .GMII_TX_ER_0                        (GMII_TX_ER_0),
    .GMII_TX_CLK_0                       (GMII_TX_CLK_0),
    .GMII_RXD_0                          (GMII_RXD_0),
    .GMII_RX_DV_0                        (GMII_RX_DV_0),
    .GMII_RX_ER_0                        (GMII_RX_ER_0),
    .GMII_RX_CLK_0                       (GMII_RX_CLK_0),

    // Asynchronous Reset Input
    .RESET                               (RESET));
