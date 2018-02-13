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
echo "TIMESTAMP: starting bd_conv $clockstring"

# if run add_controller directly, should have retiming already
if {[list_design] == 0} {
	source $env(EDGE_ROOT)/scripts/environment/common_setting.tcl
	define_design_lib WORK -path $WORK_FOLDER
	analyze -format verilog $RETIMING_NETLIST
	elaborate $DESIGN_NAME
	read_sdc $RETIMING_SDC
	link
}
current_design $DESIGN_NAME
remove_dont_touch_network edge_clk_m
remove_dont_touch_network edge_clk_s

analyze -format verilog controller_notk_1req.v
analyze -format verilog controller_tk_1req.v
analyze -format verilog c_element.v
analyze -format verilog ctrl_path.v
analyze -format verilog dummy_buffer.v
elaborate ctrl_path
set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: analyze,link,elab done $clockstring"

current_design $DESIGN_NAME
set_dont_touch [get_cells *]
set_dont_touch [get_nets *]
create_port -direction "in" {Lreq Rack}
create_port -direction "in" {edge_ctrl_reset}
create_port -direction "out" {Rreq Lack}
remove_port [get_port edge_clk*]

create_cell {CT_PATH} ctrl_path

connect_pin -from Lreq -to CT_PATH/a_req -port_name Lreq
connect_pin -from CT_PATH/a_ack -to Lack -port_name Lack
connect_pin -from CT_PATH/b_req -to Rreq -port_name Rreq
connect_pin -from Rack -to CT_PATH/b_ack -port_name Rack
connect_pin -from edge_ctrl_reset -to CT_PATH/reset -port_name edge_ctrl_reset

connect_net edge_clk_m CT_PATH/clk1
connect_net edge_clk_s CT_PATH/clk2 


set_ideal_network -no_propagate [get_nets edge_clk_*]
set_dont_touch [get_nets edge_clk_*]

insert_buffer CT_PATH/CELE_req/a $buffer_cell -new_cell_name {DL_in_s1_mybuf1 DL_in_s1_mybufn} -no_of_cells 2
insert_buffer CT_PATH/CELE_req/b $buffer_cell -new_cell_name {DL_s2_s1_mybuf1 DL_s2_s1_mybufn} -no_of_cells 2
insert_buffer CT_PATH/CTRL2/a_req $buffer_cell -new_cell_name {DL_s1_s2_mybuf1 DL_s1_s2_mybufn} -no_of_cells 2
insert_buffer CT_PATH/b_req_BUF/dbout $buffer_cell -new_cell_name {DL_s2_out_mybuf1 DL_s2_out_mybufn} -no_of_cells 2

set_dont_touch [get_cells CT_PATH/DL_*]

insert_buffer CT_PATH/CTRL1/CTDBUF/dbin $buffer_cell -new_cell_name {mybuf1 mybufn} -no_of_cells 2
insert_buffer CT_PATH/CTRL2/CTDBUF/dbin $buffer_cell -new_cell_name {mybuf1 mybufn} -no_of_cells 2
set_size_only [get_cells CT_PATH/CTRL*/mybuf*] -all_instance

set PULSE_WIDTH [expr $CLK_PERIOD/4]
set_min_delay -from [get_pins -of_objects CT_PATH/CTRL1/mybuf1 -filter "direction==1"] -to [get_pins -of_objects CT_PATH/CTRL1/mybufn -filter "direction==2"] $PULSE_WIDTH
set_min_delay -from [get_pins -of_objects CT_PATH/CTRL2/mybuf1 -filter "direction==1"] -to [get_pins -of_objects CT_PATH/CTRL2/mybufn -filter "direction==2"] $PULSE_WIDTH
set_max_delay -from [get_pins -of_objects CT_PATH/CTRL1/mybuf1 -filter "direction==1"] -to [get_pins -of_objects CT_PATH/CTRL1/mybufn -filter "direction==2"] [expr $PULSE_WIDTH*1.10]
set_max_delay -from [get_pins -of_objects CT_PATH/CTRL2/mybuf1 -filter "direction==1"] -to [get_pins -of_objects CT_PATH/CTRL2/mybufn -filter "direction==2"] [expr $PULSE_WIDTH*1.10]

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: insert,set marker buffers done $clockstring"

set_cost_priority min_delay 

compile_ultra -no_autoungroup
ungroup -all -flatten

remove_dont_touch [get_cells *]
ungroup -all -flatten
redirect $POST_DC_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out $POST_DC_NETLIST
write_file -hierarchy -format ddc -out $POST_DC_DDC
write_sdc $POST_DC_SDC
set sh_command_log_file "${POST_DC_LOG}/command.log"
file copy -force filenames.log ${POST_DC_LOG}/filenames.log

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: compile_ultra, write_file done $clockstring"

source fix.tcl

set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: fix done $clockstring"

if { !$env(DEBUG) } {
        exit
}

