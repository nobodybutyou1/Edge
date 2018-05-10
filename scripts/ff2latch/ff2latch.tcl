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
echo "TIMESTAMP: starting ff2latch $clockstring"

if {[list_design] == 0} {
	source $env(EDGE_ROOT)/scripts/environment/common_setting.tcl
	define_design_lib WORK -path $WORK_FOLDER
	set target_library "$target_library EDGE.db"
	set link_library [concat * $target_library]
	read_file -format verilog $SYNC_SYN_NETLIST
	read_sdc $SYNC_SYN_SDC
	set_dont_touch_network edge_clk_s
	link
}

current_design $DESIGN_NAME

set target_library [lsearch -all -inline -not -exact $target_library EDGE.db]
set link_library [concat * $target_library]

analyze -format verilog EDGE.v
elaborate EDGE_LATCH
compile_ultra -no_autoungroup
elaborate EDGE_DFF_R
current_design ${DESIGN_NAME}
set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: analyze,link,elab done $clockstring"

create_port -direction "in" {edge_clk_m}
create_net {edge_clk_m}
set reg_cells [get_cells "*" -filter "@ref_name == EDGE_DFF_R"]
set edge_clk_m_pins [get_pins -of_objects $reg_cells -filter "name =~ *CKbar"]
connect_net edge_clk_m [get_ports edge_clk_m]
connect_net edge_clk_m $edge_clk_m_pins

set HALF_PERIOD [expr $CLK_PERIOD/2]
create_clock -name "edge_clk_m" -period $CLK_PERIOD -waveform [list $HALF_PERIOD $CLK_PERIOD] [get_ports edge_clk_m]
set_dont_touch_network edge_clk_m
set_ideal_network edge_clk_m 

#set_max_time_borrow 0 [get_clocks {edge_clk_m edge_clk_s}]

remove_input_delay [remove_from_collection [all_inputs] [get_ports "edge_clk_s"]]
#set_input_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_m] -level_sensitive [remove_from_collection [all_inputs] [get_ports "edge_clk_m edge_clk_s"]]
remove_output_delay [all_outputs]
#set_output_delay [expr 0.1*$CLK_PERIOD] -clock [get_clocks edge_clk_s] -level_sensitive [all_outputs]

compile_ultra -no_autoungroup 
ungroup -all -flatten
redirect $FF2LATCH_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out $FF2LATCH_NETLIST
write_sdc $FF2LATCH_SDC
write_sdf $FF2LATCH_SDF
rename_design ${DESIGN_NAME} ${DESIGN_NAME}_ff2latch
write_file -hierarchy -format verilog -out $FF2LATCH_NETLIST_T
write_sdf $FF2LATCH_SDF_T
rename_design ${DESIGN_NAME}_ff2latch ${DESIGN_NAME}
set sh_command_log_file "${FF2LATCH_LOG}/command.log"
file copy -force filenames.log ${FF2LATCH_LOG}/filenames.log

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: compile_ultra, write_file done $clockstring"

if { !$env(DEBUG) } {
	exit
}
