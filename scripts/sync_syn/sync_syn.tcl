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
echo "TIMESTAMP: starting sync_syn $clockstring"

source $env(EDGE_ROOT)/scripts/environment/common_setting.tcl

#Pre-compile
define_design_lib WORK -path $WORK_FOLDER

source $env(EDGE_FILE_TCL)

#link dedign
elaborate ${DESIGN_NAME}
link
current_design ${DESIGN_NAME}

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: analyze,link,elab done $clockstring"

#rename reset net
create_port -direction "in" {edge_reset}
create_net {edge_reset}
set edge_reset_pins [get_pins -of_objects $RESET_NAME]
remove_net $RESET_NAME
remove_port $RESET_NAME
connect_net edge_reset [get_ports edge_reset]
connect_net edge_reset $edge_reset_pins

#rename clk net
create_port -direction "in" {edge_clk_s}
create_net {edge_clk_s}
set edge_clk_s_pins [get_pins -of_objects $CLOCK_NAME]
remove_net $CLOCK_NAME
remove_port $CLOCK_NAME
connect_net edge_clk_s [get_ports edge_clk_s]
connect_net edge_clk_s $edge_clk_s_pins



#set constraints
set HALF_PERIOD [expr $CLK_PERIOD/2]
create_clock -name "edge_clk_s" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD] [get_ports edge_clk_s]
set_dont_touch_network edge_clk_s
set_ideal_network edge_clk_s 

set IN_MAX $CLK_PERIOD
set OUT_MAX $CLK_PERIOD

#set_max_delay -from [remove_from_collection [all_inputs] [get_ports "edge_clk_s edge_reset"]] $IN_MAX
#set_max_delay -to [all_outputs] $OUT_MAX
#set_input_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_s] [remove_from_collection [all_inputs] [get_ports "edge_clk_s"]]
#set_output_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_s] [all_outputs]
set_load 0.02672 [all_outputs]

set target_library "$target_library EDGE.db"
set link_library [concat * $target_library]
set_register_type -exact -flip_flop EDGE_DFF_R

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: link library done $clockstring"

#run synthesis
compile_ultra -no_autoungroup 

ungroup -all -flatten
redirect $SYNC_SYN_LOG/change_names { change_names -rules verilog -hierarchy -verbose }

write_file -hierarchy -format verilog -out $SYNC_SYN_NETLIST
write_sdc $SYNC_SYN_SDC
rename_design ${DESIGN_NAME} ${DESIGN_NAME}_syn
write_file -hierarchy -format verilog -out $SYNC_SYN_NETLIST_T
rename_design ${DESIGN_NAME}_syn ${DESIGN_NAME}
set sh_command_log_file "${SYNC_SYN_LOG}/command.log"
file copy -force filenames.log ${SYNC_SYN_LOG}/filenames.log
set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: compile_ultra, write_file done $clockstring"

if { !$env(DEBUG) } {
	exit
}
