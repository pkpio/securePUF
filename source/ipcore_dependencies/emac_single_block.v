//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Wrapper Top Level
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : emac_single_block.v
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
// Description:  This is the EMAC block level Verilog design for the Virtex-5 
//               Embedded Ethernet MAC Example Design.  It is intended that
//               this example design can be quickly adapted and downloaded onto
//               an FPGA to provide a real hardware test environment.
//
//               The block level:
//
//               * instantiates all clock management logic required (BUFGs, 
//                 DCMs) to operate the EMAC and its example design;
//
//               * instantiates appropriate PHY interface modules (GMII, MII,
//                 RGMII, SGMII or 1000BASE-X) as required based on the user
//                 configuration.
//
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the top level design.
//-----------------------------------------------------------------------------
module emac_single_block
(
    // EMAC0 Clocking
    // TX Clock output from EMAC
    TX_CLK_OUT,
    // EMAC0 TX Clock input from BUFG
    TX_CLK_0,

    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    EMAC0CLIENTTXACK,
    CLIENTEMAC0TXFIRSTBYTE,
    CLIENTEMAC0TXUNDERRUN,
    EMAC0CLIENTTXCOLLISION,
    EMAC0CLIENTTXRETRANSMIT,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,

    // MAC Control Interface - EMAC0
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,

    // Clock Signal - EMAC0
    GTX_CLK_0,

    // GMII Interface - EMAC0
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_TX_CLK_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0 ,

    // Asynchronous Reset Input
    RESET
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------
    // EMAC0 Clocking
    // TX Clock output from EMAC
    output          TX_CLK_OUT;
    // EMAC0 TX Clock input from BUFG
    input           TX_CLK_0;

    // Client Receiver Interface - EMAC0
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    output          EMAC0CLIENTTXACK;
    input           CLIENTEMAC0TXFIRSTBYTE;
    input           CLIENTEMAC0TXUNDERRUN;
    output          EMAC0CLIENTTXCOLLISION;
    output          EMAC0CLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;

    // MAC Control Interface - EMAC0
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;

    // Clock Signal - EMAC0
    input           GTX_CLK_0;

    // GMII Interface - EMAC0
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    output          GMII_TX_CLK_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0 ;

    // Asynchronous Reset
    input           RESET;

//-----------------------------------------------------------------------------
// Wire and Reg Declarations 
//-----------------------------------------------------------------------------

    // Asynchronous reset signals
    wire            reset_ibuf_i;
    wire            reset_i;

    // EMAC0 client clocking signals
    wire            rx_client_clk_out_0_i;
    wire            rx_client_clk_in_0_i;
    wire            tx_client_clk_out_0_i;
    wire            tx_client_clk_in_0_i;
    wire            tx_gmii_mii_clk_out_0_i;
    wire            tx_gmii_mii_clk_in_0_i;

    // EMAC0 Physical interface signals
    wire            gmii_tx_en_0_i;
    wire            gmii_tx_er_0_i;
    wire     [7:0]  gmii_txd_0_i;
    wire            gmii_rx_dv_0_r;
    wire            gmii_rx_er_0_r;
    wire     [7:0]  gmii_rxd_0_r;
    wire            gmii_rx_clk_0_i;


    // 125MHz reference clock for EMAC0
    wire            gtx_clk_ibufg_0_i;



//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------


    //-------------------------------------------------------------------------
    // Main Reset Circuitry
    //-------------------------------------------------------------------------

    assign reset_ibuf_i = RESET;

    assign reset_i = reset_ibuf_i;

    //-------------------------------------------------------------------------
    // GMII circuitry for the Physical Interface of EMAC0
    //-------------------------------------------------------------------------

    gmii_if gmii0 (
        .RESET(reset_i),
        .GMII_TXD(GMII_TXD_0),
        .GMII_TX_EN(GMII_TX_EN_0),
        .GMII_TX_ER(GMII_TX_ER_0),
        .GMII_TX_CLK(GMII_TX_CLK_0),
        .GMII_RXD(GMII_RXD_0),
        .GMII_RX_DV(GMII_RX_DV_0),
        .GMII_RX_ER(GMII_RX_ER_0),
        .TXD_FROM_MAC(gmii_txd_0_i),
        .TX_EN_FROM_MAC(gmii_tx_en_0_i),
        .TX_ER_FROM_MAC(gmii_tx_er_0_i),
        .TX_CLK(tx_gmii_mii_clk_in_0_i),
        .RXD_TO_MAC(gmii_rxd_0_r),
        .RX_DV_TO_MAC(gmii_rx_dv_0_r),
        .RX_ER_TO_MAC(gmii_rx_er_0_r),
        .RX_CLK(gmii_rx_clk_0_i));

 

    //------------------------------------------------------------------------
    // GTX_CLK Clock Management - 125 MHz clock frequency supplied by the user
    // (Connected to PHYEMAC#GTXCLK of the EMAC primitive)
    //------------------------------------------------------------------------
    assign gtx_clk_ibufg_0_i = GTX_CLK_0; 



    //------------------------------------------------------------------------
    // GMII PHY side transmit clock for EMAC0
    //------------------------------------------------------------------------
    assign tx_gmii_mii_clk_in_0_i = TX_CLK_0;
 
    
    //------------------------------------------------------------------------
    // GMII PHY side Receiver Clock for EMAC0
    //------------------------------------------------------------------------
    assign gmii_rx_clk_0_i = GMII_RX_CLK_0;    

    //------------------------------------------------------------------------
    // GMII client side transmit clock for EMAC0
    //------------------------------------------------------------------------
    assign tx_client_clk_in_0_i = TX_CLK_0;

    //------------------------------------------------------------------------
    // GMII client side receive clock for EMAC0
    //------------------------------------------------------------------------
    assign rx_client_clk_in_0_i = gmii_rx_clk_0_i;




    //------------------------------------------------------------------------
    // Connect previously derived client clocks to example design output ports
    //------------------------------------------------------------------------
    // EMAC0 Clocking
    // TX Clock output from EMAC
    assign TX_CLK_OUT                = tx_gmii_mii_clk_out_0_i;




    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper (emac_single.v) 
    //------------------------------------------------------------------------
    emac_single v5_emac_wrapper_inst
    (
        // Client Receiver Interface - EMAC0
        .EMAC0CLIENTRXCLIENTCLKOUT      (rx_client_clk_out_0_i),
        .CLIENTEMAC0RXCLIENTCLKIN       (rx_client_clk_in_0_i),
        .EMAC0CLIENTRXD                 (EMAC0CLIENTRXD),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),

        // Client Transmitter Interface - EMAC0
        .EMAC0CLIENTTXCLIENTCLKOUT      (tx_client_clk_out_0_i),
        .CLIENTEMAC0TXCLIENTCLKIN       (tx_client_clk_in_0_i),
        .CLIENTEMAC0TXD                 (CLIENTEMAC0TXD),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (1'b0),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),

        // MAC Control Interface - EMAC0
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),

        // Clock Signals - EMAC0
        .GTX_CLK_0                      (gtx_clk_ibufg_0_i),

        .EMAC0PHYTXGMIIMIICLKOUT        (tx_gmii_mii_clk_out_0_i),
        .PHYEMAC0TXGMIIMIICLKIN         (tx_gmii_mii_clk_in_0_i),

        // GMII Interface - EMAC0
        .GMII_TXD_0                     (gmii_txd_0_i),
        .GMII_TX_EN_0                   (gmii_tx_en_0_i),
        .GMII_TX_ER_0                   (gmii_tx_er_0_i),
        .GMII_RXD_0                     (gmii_rxd_0_r),
        .GMII_RX_DV_0                   (gmii_rx_dv_0_r),
        .GMII_RX_ER_0                   (gmii_rx_er_0_r),
        .GMII_RX_CLK_0                  (gmii_rx_clk_0_i),


        .DCM_LOCKED_0                   (1'b1  ),

        // Asynchronous Reset
        .RESET                          (reset_i)
        );


  
 



endmodule
