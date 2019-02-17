# Copyright (c) 2017, Yang Zhang, Haipeng Zha, and Huimei Cheng
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
    # * Redistributions of source code must retain the above copyright
      # notice, this list of conditions and the following disclaimer.
    # * Redistributions in binary form must reproduce the above copyright
      # notice, this list of conditions and the following disclaimer in the
      # documentation and/or other materials provided with the distribution.
    # * Neither the name of the University of Southern California nor the
      # names of its contributors may be used to endorse or promote products
      # derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL YANG ZHANG, HAIPENG ZHA, AND HUIMEI CHENG BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: starting retiming $clockstring"

# if run retiming directly, should have ff_to_latch already
if {[list_design] == 0} {
	source $env(EDGE_ROOT)/scripts/environment/common_setting.tcl
	define_design_lib WORK -path $WORK_FOLDER
	read_file -format verilog $FF2LATCH_NETLIST
	current_design $DESIGN_NAME
	read_sdc $FF2LATCH_SDC
	set_dont_touch_network edge_clk_m
	set_dont_touch_network edge_clk_s
	link
}

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: analyze,link,elab done $clockstring"

current_design $DESIGN_NAME
set_host_options -max_cores $NUM_CORES
set HALF_PERIOD [expr $CLK_PERIOD/2]
set HIGH_PERIOD [expr $CLK_PERIOD/4]
set SLAVE_START [expr $CLK_PERIOD/2]

remove_clock edge_clk_s
remove_clock edge_clk_m
create_clock -name "edge_clk_s" -period $CLK_PERIOD -waveform [list 0 $HIGH_PERIOD] [get_ports edge_clk_s]
create_clock -name "edge_clk_m" -period $CLK_PERIOD -waveform [list $SLAVE_START [expr $SLAVE_START + $HIGH_PERIOD]] [get_ports edge_clk_m]

set_max_delay -from [remove_from_collection [all_inputs] [get_ports "edge_clk_s edge_clk_m"]] $HALF_PERIOD
set_max_delay -to [all_outputs] $HALF_PERIOD

set_max_time_borrow 0 [get_clocks {edge_clk_m edge_clk_s}]
#set_input_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_m] [remove_from_collection [all_inputs] [get_ports "edge_clk_m edge_clk_s"]]
#set_output_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_s] [all_outputs]
#set_max_time_borrow [expr $CLK_PERIOD / 10] [list clk clk_bar]

#dump_slack "$DESIGN_NAME/retiming/slack_before.txt"

set_dont_retime [all_fanout -from edge_clk_m -only_cells ] true
#set_dont_retime [all_fanout -from edge_clk_s -endpoints_only -only_cells ] true
#optimize_registers -latch -print_critical_loop -minimum_period_only -delay_threshold $HALF_PERIOD

#keep the scan cell in heiararchy

ungroup -all

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: set_dont_retime done $clockstring"

# dont touch reset path from reset to master latches
set reset_to_cells [all_fanout -from edge_reset -only_cells]
set master_from_cells [all_fanin -to [concat [get_pins -of_objects *edgeM*] [get_pins -of_objects [get_cells -of_objects edge_clk_m]]] -only_cells -levels 1]
set reset_master_cells [remove_from_collection -intersect $reset_to_cells $master_from_cells]
set_dont_touch $reset_master_cells true

# compile to latches
compile_ultra -no_autoungroup -retime

#set_dont_touch $reset_master_cells false


#current_design $DESIGN_NAME
#ungroup -all -flatten
redirect $RETIMING_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
#dump_slack "$DESIGN_NAME/retiming/slack_after.txt"
write_file -hierarchy -format verilog -out $RETIMING_NETLIST
write_sdc $RETIMING_SDC
write_sdf $RETIMING_SDF
rename_design ${DESIGN_NAME} ${DESIGN_NAME}_retiming
write_file -hierarchy -format verilog -out $RETIMING_NETLIST_T
write_sdf $RETIMING_SDF_T
rename_design ${DESIGN_NAME}_retiming ${DESIGN_NAME}
set sh_command_log_file "${RETIMING_LOG}/command.log"
file copy -force filenames.log ${RETIMING_LOG}/filenames.log

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: compile_ultra, write_file done $clockstring"

#if { !$env(DEBUG) } {
#        exit
#}

