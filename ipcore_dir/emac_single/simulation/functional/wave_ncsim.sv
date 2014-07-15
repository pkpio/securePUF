# SimVision Command Script

#
# groups
#

if {[catch {group new -name {System Signals} -overlay 0}] != ""} {
    group using {System Signals}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.reset \
    :testbench.gtx_clk \
    :testbench.host_clk

if {[catch {group new -name {EMAC0 TX Client Interface} -overlay 0}] != ""} {
    group using {EMAC0 TX Client Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.dut.tx_clk_0 \
    :testbench.dut.v5_emac_ll.tx_data_0_i \
    :testbench.dut.v5_emac_ll.tx_data_valid_0_i \
    :testbench.dut.v5_emac_ll.tx_ack_0_i \
    :testbench.tx_ifg_delay_0

if {[catch {group new -name {EMAC0 RX Client Interface} -overlay 0}] != ""} {
    group using {EMAC0 RX Client Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.dut.rx_clk_0_i \
    :testbench.dut.v5_emac_ll.rx_data_0_i \
    :testbench.dut.v5_emac_ll.rx_data_valid_0_i \
    :testbench.dut.v5_emac_ll.rx_good_frame_0_i \
    :testbench.dut.v5_emac_ll.rx_bad_frame_0_i

if {[catch {group new -name {EMAC0 Flow Control} -overlay 0}] != ""} {
    group using {EMAC0 Flow Control}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.pause_val_0 \
    :testbench.pause_req_0

if {[catch {group new -name {EMAC0 TX GMII/MII Interface} -overlay 0}] != ""} {
    group using {EMAC0 TX GMII/MII Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.gmii_tx_clk_0 \
    :testbench.gmii_txd_0 \
    :testbench.gmii_tx_en_0 \
    :testbench.gmii_tx_er_0 
if {[catch {group new -name {EMAC0 RX GMII/MII Interface} -overlay 0}] != ""} {
    group using {EMAC0 RX GMII/MII Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.gmii_rx_clk_0 \
    :testbench.gmii_rxd_0 \
    :testbench.gmii_rx_dv_0 \
    :testbench.gmii_rx_er_0 


if {[catch {group new -name {Test semaphores} -overlay 0}] != ""} {
    group using {Test semaphores}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :testbench.emac0_configuration_busy \
    :testbench.emac0_monitor_finished_1g \
    :testbench.emac0_monitor_finished_100m \
    :testbench.emac0_monitor_finished_10m

#
# Waveform windows
#
if {[window find -match exact -name "Waveform 1"] == {}} {
    window new WaveWindow -name "Waveform 1" -geometry 906x585+25+55
} else {
    window geometry "Waveform 1" 906x585+25+55
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units fs \
    -valuewidth 75
cursor set -using TimeA -time 50,000,000,000fs
cursor set -using TimeA -marching 1
waveform baseline set -time 0

set id [waveform add -signals [list :testbench.reset \
	:testbench.gtx_clk ]]

set groupId [waveform add -groups {{System Signals}}]


set groupId [waveform add -groups {{EMAC0 TX Client Interface}}]

set groupId [waveform add -groups {{EMAC0 RX Client Interface}}]

set groupId [waveform add -groups {{EMAC0 TX GMII/MII Interface}}]

set groupId [waveform add -groups {{EMAC0 RX GMII/MII Interface}}]



set groupId [waveform add -groups {{Management Interface}}]

set groupId [waveform add -groups {{Test semaphores}}]

waveform xview limits 0fs 10us

simcontrol run -time 2000us

