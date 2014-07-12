gui_open_window Wave
gui_list_select -id Hier.1 { glbl testbench }
gui_list_select -id Data.1 { testbench.reset }
gui_sg_create TEMAC_Group
gui_list_add_group -id Wave.1 {TEMAC_Group}
gui_list_add_divider -id Wave.1 -after TEMAC_Group { Test_semaphores }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { Management_Signals }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { EMAC0_Tx_GMII_MII_Interface }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { EMAC0_Rx_GMII_MII_Interface }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { EMAC0_Flow_Control }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { EMAC0_Rx_Client_Interface }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { EMAC0_Tx_Client_Interface }
gui_list_add_divider -id Wave.1 -after TEMAC_Group { System_Signals }
gui_list_add -id Wave.1 -after System_Signals {{testbench.reset} {testbench.gtx_clk} {testbench.host_clk}}
gui_list_add -id Wave.1 -after EMAC0_Tx_Client_Interface {{testbench.dut.tx_clk_0}}
gui_list_add -id Wave.1 -after EMAC0_Tx_Client_Interface {{testbench.dut.v5_emac_ll.tx_data_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Tx_Client_Interface {{testbench.dut.v5_emac_ll.tx_data_valid_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Tx_Client_Interface {{testbench.dut.v5_emac_ll.tx_ack_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Tx_Client_Interface {{testbench.tx_ifg_delay_0}}
gui_list_add -id Wave.1 -after EMAC0_Rx_Client_Interface {{testbench.dut.rx_clk_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Rx_Client_Interface {{testbench.dut.v5_emac_ll.rx_data_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Rx_Client_Interface {{testbench.dut.v5_emac_ll.rx_data_valid_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Rx_Client_Interface {{testbench.dut.v5_emac_ll.rx_good_frame_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Rx_Client_Interface {{testbench.dut.v5_emac_ll.rx_bad_frame_0_i}}
gui_list_add -id Wave.1 -after EMAC0_Flow_Control {{testbench.pause_val_0}}
gui_list_add -id Wave.1 -after EMAC0_Flow_Control {{testbench.pause_req_0}}
gui_list_add -id Wave.1 -after EMAC0_Tx_GMII_MII_Interface {{testbench.gmii_tx_clk_0} {testbench.gmii_txd_0} {testbench.gmii_tx_en_0} {testbench.gmii_tx_er_0}}
gui_list_add -id Wave.1 -after EMAC0_Rx_GMII_MII_Interface {{testbench.gmii_rx_clk_0} {testbench.gmii_rxd_0} {testbench.gmii_rx_dv_0} {testbench.gmii_rx_er_0}}


gui_list_add -id Wave.1 -after Test_semaphores {{testbench.emac0_configuration_busy} {testbench.emac0_monitor_finished_1g} {testbench.emac0_monitor_finished_100m} {testbench.emac0_monitor_finished_10m}}
gui_zoom -window Wave.1 -full
