#!/bin/sh

/bin/rm -rf simv* csrc DVEfiles AN.DB

echo "Compiling Core Simulation Models"
vlogan +v2k \
      ../../implement/results/routed.v \
      ../configuration_tb.v \
      ../emac0_phy_tb.v \
      ../demo_tb.v

vcs  +neg_tchk -debug -PP -sdf max:testbench.dut:../../implement/results/routed.sdf testbench glbl
./simv -ucli -i ucli_commands.key
dve -vpd vcdplus.vpd -session vcs_session.tcl

