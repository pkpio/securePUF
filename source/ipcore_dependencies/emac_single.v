//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Wrapper
// Project    : Virtex-5 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : emac_single.v
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
//------------------------------------------------------------------------------
// Description:  This wrapper file instantiates the full Virtex-5 Ethernet 
//               MAC (EMAC) primitive.  For one or both of the two Ethernet MACs
//               (EMAC0/EMAC1):
//
//               * all unused input ports on the primitive will be tied to the
//                 appropriate logic level;
//
//               * all unused output ports on the primitive will be left 
//                 unconnected;
//
//               * the Tie-off Vector will be connected based on the options 
//                 selected from CORE Generator;
//
//               * only used ports will be connected to the ports of this 
//                 wrapper file.
//
//               This simplified wrapper should therefore be used as the 
//               instantiation template for the EMAC in customer designs.
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps


//------------------------------------------------------------------------------
// The module declaration for the top level wrapper.
//------------------------------------------------------------------------------
(* X_CORE_INFO = "v5_emac_v1_8, Coregen 13.1" *)
(* CORE_GENERATION_INFO = "emac_single,v5_emac_v1_8,{c_emac0=true,c_emac1=false,c_has_mii_emac0=false,c_has_mii_emac1=false,c_has_gmii_emac0=true,c_has_gmii_emac1=true,c_has_rgmii_v1_3_emac0=false,c_has_rgmii_v1_3_emac1=false,c_has_rgmii_v2_0_emac0=false,c_has_rgmii_v2_0_emac1=false,c_has_sgmii_emac0=false,c_has_sgmii_emac1=false,c_has_gpcs_emac0=false,c_has_gpcs_emac1=false,c_tri_speed_emac0=false,c_tri_speed_emac1=false,c_speed_10_emac0=false,c_speed_10_emac1=false,c_speed_100_emac0=false,c_speed_100_emac1=false,c_speed_1000_emac0=true,c_speed_1000_emac1=true,c_has_host=false,c_has_dcr=false,c_has_mdio_emac0=false,c_has_mdio_emac1=false,c_client_16_emac0=false,c_client_16_emac1=false,c_add_filter_emac0=false,c_add_filter_emac1=false,c_has_clock_enable_emac0=false,c_has_clock_enable_emac1=false,}" *)
module emac_single
(
    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXCLIENTCLKOUT,
    CLIENTEMAC0RXCLIENTCLKIN,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXDVLDMSW,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    EMAC0CLIENTTXCLIENTCLKOUT,
    CLIENTEMAC0TXCLIENTCLKIN,
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    CLIENTEMAC0TXDVLDMSW,
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
    PHYEMAC0TXGMIIMIICLKIN,
    EMAC0PHYTXGMIIMIICLKOUT,

    // GMII Interface - EMAC0
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0,




    DCM_LOCKED_0,

    // Asynchronous Reset
    RESET
);

    //--------------------------------------------------------------------------
    // Port Declarations
    //--------------------------------------------------------------------------


    // Client Receiver Interface - EMAC0
    output          EMAC0CLIENTRXCLIENTCLKOUT;
    input           CLIENTEMAC0RXCLIENTCLKIN;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXDVLDMSW;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    output          EMAC0CLIENTTXCLIENTCLKOUT;
    input           CLIENTEMAC0TXCLIENTCLKIN;
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    input           CLIENTEMAC0TXDVLDMSW;
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
    output          EMAC0PHYTXGMIIMIICLKOUT;
    input           PHYEMAC0TXGMIIMIICLKIN;

    // GMII Interface - EMAC0
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0;




    input           DCM_LOCKED_0;

    // Asynchronous Reset
    input           RESET;


    //--------------------------------------------------------------------------
    // Wire Declarations 
    //--------------------------------------------------------------------------


    wire    [15:0]  client_rx_data_0_i;
    wire    [15:0]  client_tx_data_0_i;




    //--------------------------------------------------------------------------
    // Main Body of Code 
    //--------------------------------------------------------------------------


    // 8-bit client data on EMAC0
    assign EMAC0CLIENTRXD = client_rx_data_0_i[7:0];
    assign #4000 client_tx_data_0_i = {8'b00000000, CLIENTEMAC0TXD};




    //--------------------------------------------------------------------------
    // Instantiate the Virtex-5 Embedded Ethernet EMAC
    //--------------------------------------------------------------------------
    TEMAC v5_emac
    (
        .RESET                          (RESET),

        // EMAC0
        .EMAC0CLIENTRXCLIENTCLKOUT      (EMAC0CLIENTRXCLIENTCLKOUT),
        .CLIENTEMAC0RXCLIENTCLKIN       (CLIENTEMAC0RXCLIENTCLKIN),
        .EMAC0CLIENTRXD                 (client_rx_data_0_i),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (EMAC0CLIENTRXDVLDMSW),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),

        .EMAC0CLIENTTXCLIENTCLKOUT      (EMAC0CLIENTTXCLIENTCLKOUT),
        .CLIENTEMAC0TXCLIENTCLKIN       (CLIENTEMAC0TXCLIENTCLKIN),
        .CLIENTEMAC0TXD                 (client_tx_data_0_i),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (CLIENTEMAC0TXDVLDMSW),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),

        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),

        .PHYEMAC0GTXCLK                 (GTX_CLK_0),
        .EMAC0PHYTXGMIIMIICLKOUT        (EMAC0PHYTXGMIIMIICLKOUT),
        .PHYEMAC0TXGMIIMIICLKIN         (PHYEMAC0TXGMIIMIICLKIN),

        .PHYEMAC0RXCLK                  (GMII_RX_CLK_0),
        .PHYEMAC0RXD                    (GMII_RXD_0),
        .PHYEMAC0RXDV                   (GMII_RX_DV_0),
        .PHYEMAC0RXER                   (GMII_RX_ER_0),
        .EMAC0PHYTXCLK                  (),
        .EMAC0PHYTXD                    (GMII_TXD_0),
        .EMAC0PHYTXEN                   (GMII_TX_EN_0),
        .EMAC0PHYTXER                   (GMII_TX_ER_0),
        .PHYEMAC0MIITXCLK               (),
        .PHYEMAC0COL                    (1'b0),
        .PHYEMAC0CRS                    (1'b0),

        .CLIENTEMAC0DCMLOCKED           (DCM_LOCKED_0),
        .EMAC0CLIENTANINTERRUPT         (),
        .PHYEMAC0SIGNALDET              (1'b0),
        .PHYEMAC0PHYAD                  (5'b00000),
        .EMAC0PHYENCOMMAALIGN           (),
        .EMAC0PHYLOOPBACKMSB            (),
        .EMAC0PHYMGTRXRESET             (),
        .EMAC0PHYMGTTXRESET             (),
        .EMAC0PHYPOWERDOWN              (),
        .EMAC0PHYSYNCACQSTATUS          (),
        .PHYEMAC0RXCLKCORCNT            (3'b000),
        .PHYEMAC0RXBUFSTATUS            (2'b00),
        .PHYEMAC0RXBUFERR               (1'b0),
        .PHYEMAC0RXCHARISCOMMA          (1'b0),
        .PHYEMAC0RXCHARISK              (1'b0),
        .PHYEMAC0RXCHECKINGCRC          (1'b0),
        .PHYEMAC0RXCOMMADET             (1'b0),
        .PHYEMAC0RXDISPERR              (1'b0),
        .PHYEMAC0RXLOSSOFSYNC           (2'b00),
        .PHYEMAC0RXNOTINTABLE           (1'b0),
        .PHYEMAC0RXRUNDISP              (1'b0),
        .PHYEMAC0TXBUFERR               (1'b0),
        .EMAC0PHYTXCHARDISPMODE         (),
        .EMAC0PHYTXCHARDISPVAL          (),
        .EMAC0PHYTXCHARISK              (),

        .EMAC0PHYMCLKOUT                (),
        .PHYEMAC0MCLKIN                 (1'b0),
        .PHYEMAC0MDIN                   (1'b1),
        .EMAC0PHYMDOUT                  (),
        .EMAC0PHYMDTRI                  (),
        .EMAC0SPEEDIS10100              (),

        // EMAC1
        .EMAC1CLIENTRXCLIENTCLKOUT      (),
        .CLIENTEMAC1RXCLIENTCLKIN       (1'b0),
        .EMAC1CLIENTRXD                 (),
        .EMAC1CLIENTRXDVLD              (),
        .EMAC1CLIENTRXDVLDMSW           (),
        .EMAC1CLIENTRXGOODFRAME         (),
        .EMAC1CLIENTRXBADFRAME          (),
        .EMAC1CLIENTRXFRAMEDROP         (),
        .EMAC1CLIENTRXSTATS             (),
        .EMAC1CLIENTRXSTATSVLD          (),
        .EMAC1CLIENTRXSTATSBYTEVLD      (),

        .EMAC1CLIENTTXCLIENTCLKOUT      (),
        .CLIENTEMAC1TXCLIENTCLKIN       (1'b0),
        .CLIENTEMAC1TXD                 (16'h0000),
        .CLIENTEMAC1TXDVLD              (1'b0),
        .CLIENTEMAC1TXDVLDMSW           (1'b0),
        .EMAC1CLIENTTXACK               (),
        .CLIENTEMAC1TXFIRSTBYTE         (1'b0),
        .CLIENTEMAC1TXUNDERRUN          (1'b0),
        .EMAC1CLIENTTXCOLLISION         (),
        .EMAC1CLIENTTXRETRANSMIT        (),
        .CLIENTEMAC1TXIFGDELAY          (8'h00),
        .EMAC1CLIENTTXSTATS             (),
        .EMAC1CLIENTTXSTATSVLD          (),
        .EMAC1CLIENTTXSTATSBYTEVLD      (),

        .CLIENTEMAC1PAUSEREQ            (1'b0),
        .CLIENTEMAC1PAUSEVAL            (16'h0000),

        .PHYEMAC1GTXCLK                 (1'b0),
        .EMAC1PHYTXGMIIMIICLKOUT        (),
        .PHYEMAC1TXGMIIMIICLKIN         (1'b0),

        .PHYEMAC1RXCLK                  (1'b0),
        .PHYEMAC1RXD                    (8'h00),
        .PHYEMAC1RXDV                   (1'b0),
        .PHYEMAC1RXER                   (1'b0),
        .PHYEMAC1MIITXCLK               (1'b0),
        .EMAC1PHYTXCLK                  (),
        .EMAC1PHYTXD                    (),
        .EMAC1PHYTXEN                   (),
        .EMAC1PHYTXER                   (),
        .PHYEMAC1COL                    (1'b0),
        .PHYEMAC1CRS                    (1'b0),

        .CLIENTEMAC1DCMLOCKED           (1'b1),
        .EMAC1CLIENTANINTERRUPT         (),
        .PHYEMAC1SIGNALDET              (1'b0),
        .PHYEMAC1PHYAD                  (5'b00000),
        .EMAC1PHYENCOMMAALIGN           (),
        .EMAC1PHYLOOPBACKMSB            (),
        .EMAC1PHYMGTRXRESET             (),
        .EMAC1PHYMGTTXRESET             (),
        .EMAC1PHYPOWERDOWN              (),
        .EMAC1PHYSYNCACQSTATUS          (),
        .PHYEMAC1RXCLKCORCNT            (3'b000),
        .PHYEMAC1RXBUFSTATUS            (2'b00),
        .PHYEMAC1RXBUFERR               (1'b0),
        .PHYEMAC1RXCHARISCOMMA          (1'b0),
        .PHYEMAC1RXCHARISK              (1'b0),
        .PHYEMAC1RXCHECKINGCRC          (1'b0),
        .PHYEMAC1RXCOMMADET             (1'b0),
        .PHYEMAC1RXDISPERR              (1'b0),
        .PHYEMAC1RXLOSSOFSYNC           (2'b00),
        .PHYEMAC1RXNOTINTABLE           (1'b0),
        .PHYEMAC1RXRUNDISP              (1'b0),
        .PHYEMAC1TXBUFERR               (1'b0),
        .EMAC1PHYTXCHARDISPMODE         (),
        .EMAC1PHYTXCHARDISPVAL          (),
        .EMAC1PHYTXCHARISK              (),

        .EMAC1PHYMCLKOUT                (),
        .PHYEMAC1MCLKIN                 (1'b0),
        .PHYEMAC1MDIN                   (1'b0),
        .EMAC1PHYMDOUT                  (),
        .EMAC1PHYMDTRI                  (),
        .EMAC1SPEEDIS10100              (),

        // Host Interface 
        .HOSTCLK                        (1'b0),
        .HOSTOPCODE                     (2'b00),
        .HOSTREQ                        (1'b0),
        .HOSTMIIMSEL                    (1'b0),
        .HOSTADDR                       (10'b0000000000),
        .HOSTWRDATA                     (32'h00000000),
        .HOSTMIIMRDY                    (),
        .HOSTRDDATA                     (),
        .HOSTEMAC1SEL                   (1'b0),

        // DCR Interface
        .DCREMACCLK                     (1'b0),
        .DCREMACABUS                    (10'h000),
        .DCREMACREAD                    (1'b0),
        .DCREMACWRITE                   (1'b0),
        .DCREMACDBUS                    (32'h00000000),
        .EMACDCRACK                     (),
        .EMACDCRDBUS                    (),
        .DCREMACENABLE                  (1'b0),
        .DCRHOSTDONEIR                  ()
    );
    //------
    // EMAC0
    //------
    // PCS/PMA logic is not in use
    //synthesis attribute EMAC0_PHYINITAUTONEG_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_PHYINITAUTONEG_ENABLE = "FALSE";
    //synthesis attribute EMAC0_PHYISOLATE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_PHYISOLATE = "FALSE";
    //synthesis attribute EMAC0_PHYLOOPBACKMSB of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_PHYLOOPBACKMSB = "FALSE";
    //synthesis attribute EMAC0_PHYPOWERDOWN of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_PHYPOWERDOWN = "FALSE";
    //synthesis attribute EMAC0_PHYRESET of v5_emac is "TRUE"
    defparam v5_emac.EMAC0_PHYRESET = "TRUE";
    //synthesis attribute EMAC0_CONFIGVEC_79 of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_CONFIGVEC_79 = "FALSE";
    //synthesis attribute EMAC0_GTLOOPBACK of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_GTLOOPBACK = "FALSE";
    //synthesis attribute EMAC0_UNIDIRECTION_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_UNIDIRECTION_ENABLE = "FALSE";
    //synthesis attribute EMAC0_LINKTIMERVAL of v5_emac is 9'h000
    defparam v5_emac.EMAC0_LINKTIMERVAL = 9'h000;

    // Configure the MAC operating mode
    // MDIO is not enabled
    //synthesis attribute EMAC0_MDIO_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_MDIO_ENABLE = "FALSE";  
    // Speed is defaulted to 1000Mb/s
    //synthesis attribute EMAC0_SPEED_LSB of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_SPEED_LSB = "FALSE";
    //synthesis attribute EMAC0_SPEED_MSB of v5_emac is "TRUE"
    defparam v5_emac.EMAC0_SPEED_MSB = "TRUE"; 
    //synthesis attribute EMAC0_USECLKEN of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_USECLKEN = "FALSE";
    //synthesis attribute EMAC0_BYTEPHY of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_BYTEPHY = "FALSE";
   
    //synthesis attribute EMAC0_RGMII_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RGMII_ENABLE = "FALSE";
    //synthesis attribute EMAC0_SGMII_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_SGMII_ENABLE = "FALSE";
    //synthesis attribute EMAC0_1000BASEX_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_1000BASEX_ENABLE = "FALSE";
    // The Host I/F is not  in use
    //synthesis attribute EMAC0_HOST_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_HOST_ENABLE = "FALSE";  
    // 8-bit interface for Tx client
    //synthesis attribute EMAC0_TX16BITCLIENT_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TX16BITCLIENT_ENABLE = "FALSE";
    // 8-bit interface for Rx client
    //synthesis attribute EMAC0_RX16BITCLIENT_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RX16BITCLIENT_ENABLE = "FALSE";    
    // The Address Filter (not enabled)
    //synthesis attribute EMAC0_ADDRFILTER_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_ADDRFILTER_ENABLE = "FALSE";  

    // MAC configuration defaults
    // Rx Length/Type checking enabled (standard IEEE operation)
    //synthesis attribute EMAC0_LTCHECK_DISABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_LTCHECK_DISABLE = "FALSE";  
    // Rx Flow Control (not enabled)
    //synthesis attribute EMAC0_RXFLOWCTRL_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXFLOWCTRL_ENABLE = "FALSE";  
    // Tx Flow Control (not enabled)
    //synthesis attribute EMAC0_TXFLOWCTRL_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXFLOWCTRL_ENABLE = "FALSE";  
    // Transmitter is not held in reset not asserted (normal operating mode)
    //synthesis attribute EMAC0_TXRESET of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXRESET = "FALSE";  
    // Transmitter Jumbo Frames (not enabled)
    //synthesis attribute EMAC0_TXJUMBOFRAME_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXJUMBOFRAME_ENABLE = "FALSE";  
    // Transmitter In-band FCS (not enabled)
    //synthesis attribute EMAC0_TXINBANDFCS_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXINBANDFCS_ENABLE = "FALSE";  
    // Transmitter Enabled
    //synthesis attribute EMAC0_TX_ENABLE of v5_emac is "TRUE"
    defparam v5_emac.EMAC0_TX_ENABLE = "TRUE";  
    // Transmitter VLAN mode (not enabled)
    //synthesis attribute EMAC0_TXVLAN_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXVLAN_ENABLE = "FALSE";  
    // Transmitter Half Duplex mode (not enabled)
    //synthesis attribute EMAC0_TXHALFDUPLEX of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXHALFDUPLEX = "FALSE";  
    // Transmitter IFG Adjust (not enabled)
    //synthesis attribute EMAC0_TXIFGADJUST_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_TXIFGADJUST_ENABLE = "FALSE";  
    // Receiver is not held in reset not asserted (normal operating mode)
    //synthesis attribute EMAC0_RXRESET of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXRESET = "FALSE";  
    // Receiver Jumbo Frames (not enabled)
    //synthesis attribute EMAC0_RXJUMBOFRAME_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXJUMBOFRAME_ENABLE = "FALSE";  
    // Receiver In-band FCS (not enabled)
    //synthesis attribute EMAC0_RXINBANDFCS_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXINBANDFCS_ENABLE = "FALSE";  
    // Receiver Enabled
    //synthesis attribute EMAC0_RX_ENABLE of v5_emac is "TRUE"
    defparam v5_emac.EMAC0_RX_ENABLE = "TRUE";  
    // Receiver VLAN mode (not enabled)
    //synthesis attribute EMAC0_RXVLAN_ENABLE of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXVLAN_ENABLE = "FALSE";  
    // Receiver Half Duplex mode (not enabled)
    //synthesis attribute EMAC0_RXHALFDUPLEX of v5_emac is "FALSE"
    defparam v5_emac.EMAC0_RXHALFDUPLEX = "FALSE";  

    // Set the Pause Address Default
    //synthesis attribute EMAC0_PAUSEADDR of v5_emac is 48'hFFEEDDCCBBAA
    defparam v5_emac.EMAC0_PAUSEADDR = 48'hFFEEDDCCBBAA;

    //synthesis attribute EMAC0_UNICASTADDR of v5_emac is 48'h000000000000
    defparam v5_emac.EMAC0_UNICASTADDR = 48'h000000000000;
 
    //synthesis attribute EMAC0_DCRBASEADDR of v5_emac is 8'h00
    defparam v5_emac.EMAC0_DCRBASEADDR = 8'h00;

endmodule

