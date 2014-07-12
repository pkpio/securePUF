view structure
view signals
view wave
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {System Signals}
add wave -noupdate -format Logic /testbench/reset
add wave -noupdate -format Logic /testbench/gtx_clk
add wave -noupdate -format Logic /testbench/host_clk
add wave -noupdate -divider {EMAC0 Tx Client Interface}
add wave -noupdate -label tx_client_clk_0 -format Logic /testbench/dut/tx_clk_0
add wave -noupdate -label dut/tx_data_0_i -format Literal -hex /testbench/dut/\\v5_emac_ll/tx_data_0_i\\
add wave -noupdate -label dut/tx_data_valid_0_i -format Logic /testbench/dut/\\v5_emac_ll/tx_data_valid_0_i\\
add wave -noupdate -label dut/tx_ack_0_i -format Logic /testbench/dut/\\v5_emac_ll/tx_ack_0_i\\
add wave -noupdate -format Literal -hex /testbench/tx_ifg_delay_0
add wave -noupdate -divider {EMAC0 Rx Client Interface}
add wave -noupdate -label rx_client_clk_0 -format Logic /testbench/dut/rx_clk_0_i
add wave -noupdate -label dut/rx_data_0_i -format Literal -hex /testbench/dut/\\v5_emac_ll/rx_data_0_i\\
add wave -noupdate -label dut/rx_data_valid_0_i -format Logic /testbench/dut/EMAC0CLIENTRXDVLD
add wave -noupdate -label dut/rx_good_frame_0_i -format Logic /testbench/dut/\\v5_emac_ll/rx_good_frame_0_i\\
add wave -noupdate -label dut/rx_bad_frame_0_i -format Logic /testbench/dut/\\v5_emac_ll/rx_bad_frame_0_i\\
add wave -noupdate -divider {EMAC0 Flow Control}
add wave -noupdate -format Literal -hex /testbench/pause_val_0
add wave -noupdate -format Logic /testbench/pause_req_0
add wave -noupdate -divider {EMAC0 Tx GMII/MII Interface}
add wave -noupdate -format Logic /testbench/gmii_tx_clk_0
add wave -noupdate -format Literal -hex /testbench/gmii_txd_0
add wave -noupdate -format Logic /testbench/gmii_tx_en_0
add wave -noupdate -format Logic /testbench/gmii_tx_er_0
add wave -noupdate -divider {EMAC0 Rx GMII/MII Interface}
add wave -noupdate -format Logic /testbench/gmii_rx_clk_0
add wave -noupdate -format Literal -hex /testbench/gmii_rxd_0
add wave -noupdate -format Logic /testbench/gmii_rx_dv_0
add wave -noupdate -format Logic /testbench/gmii_rx_er_0
add wave -noupdate -divider {Test semaphores}
add wave -noupdate -format Logic /testbench/emac0_configuration_busy
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_1g
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_100m
add wave -noupdate -format Logic /testbench/emac0_monitor_finished_10m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
WaveRestoreZoom {0 ps} {4310754 ps}
