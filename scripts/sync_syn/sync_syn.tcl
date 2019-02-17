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
create_port -direction "in" {edge_clk_m}
create_net {edge_clk_m}
set edge_clk_s_pins [get_pins -of_objects $CLOCK_NAME]
remove_net $CLOCK_NAME
remove_port $CLOCK_NAME
connect_net edge_clk_m [get_ports edge_clk_m]
connect_net edge_clk_m $edge_clk_s_pins



#set constraints
set HALF_PERIOD [expr $CLK_PERIOD/2]
create_clock -name "edge_clk_m" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD] [get_ports edge_clk_m]
set_dont_touch_network edge_clk_m
set_ideal_network edge_clk_m 

set IN_MAX $CLK_PERIOD
set OUT_MAX $CLK_PERIOD


set_load 0.02672 [all_outputs]

#s################ set scan chains

# SCAN SETUP

set hdlin_enable_rtldrc_info true
set test_dft_drc_ungate_internal_clocks true

# setup the view
create_port -direction "in"  {I_SCAN_IN };
create_port -direction "in"  {I_TEST_MODE} ;
create_port -direction "in"  {I_SCAN_RST} ;
create_port -direction "in"  {I_SCAN_SE} ;
create_port -direction "out" {O_SCAN_OUT} ;

set_auto_disable_drc_nets -scan true
set_ideal_network -no_propagate I_SCAN_SE

# RTL-LEVEL DRC (DESIGN RULE CHECK)
set test_enable_dft_drc true
##100.00
set test_default_period 200.00
set test_default_delay 0.00
set test_default_bidir_delay 0.00
set test_default_strobe 40.00
set test_default_strobe_width 1.00

set_dft_configuration -fix_clock enable
set_dft_configuration -fix_reset  enable
set_dft_configuration -fix_set enable

# Defining Test Signals 


#test clock
set_dft_signal -view existing_dft -type ScanClock -port edge_clk_m -timing [list 55 45]	

#test mode 
set_dft_signal -view existing_dft -type TestMode -active_state 1 -port [get_ports I_TEST_MODE]
set_dft_signal -view spec -type TestMode -port [get_ports I_TEST_MODE]

#scan enable
set_dft_signal -view spec -type ScanEnable -port [get_ports I_SCAN_SE]

#scan in and out
set_dft_signal -type ScanDataIn -port [get_ports I_SCAN_IN]
set_dft_signal -type ScanDataOut -port [get_ports O_SCAN_OUT]

#reset signal
set_dft_signal -view existing_dft -type reset -active_state 1 -port [get_ports I_SCAN_RST]
set_dft_signal -view spec -type TestData -port [get_ports I_SCAN_RST]
set_autofix_configuration -type reset -method mux -control_signal [get_ports I_TEST_MODE] -test_data [get_ports I_SCAN_RST]
set_autofix_configuration -type set -method mux -control_signal [get_ports I_TEST_MODE] -test_data [get_ports I_SCAN_RST]

# Test Attributes
set_scan_configuration -style multiplexed_flip_flop -chain_count 1 -clock_mixing mix_clocks -add_lockup true 

create_test_protocol 


# SCAN SYNTHESIS
compile -scan

set_scan_configuration -chain_count 1 

# scan insertion
preview_dft
insert_dft 

#write_test_protocol -out src/$design_name.spf 

compile -scan -incremental





ungroup -all -flatten
redirect $SYNC_SYN_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out ${SYNC_TB_GEN_NETLIST}
write_sdc $SYNC_TB_GEN_SDC
write_scan_def -output ${SYNC_TB_GEN_SCAN_DEF};
write_test_protocol -o ${SYNC_STIL_DC};

rename_design ${DESIGN_NAME} ${DESIGN_NAME}_syn
write_file -hierarchy -format verilog -out $SYNC_SYN_NETLIST_T
rename_design ${DESIGN_NAME}_syn ${DESIGN_NAME}


set target_library "$target_library EDGE_SCELL.db"
set link_library [concat * $target_library]

set target_library "$target_library EDGE.db"
set link_library [concat * $target_library]


set_register_type -exact -flip_flop EDGE_DFF_R
set_dont_use $scan_cell
set_prefer {EDGE_SCELL/EDGE_SCELL_R EDGE_SCELL/EDGE_SCELL_S}
#set_register_type -exact -flip_flop EDGE_SCELL/EDGE_SCELL_R


set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: link library done $clockstring"

# SCAN SYNTHESIS
compile -scan

set_scan_configuration -chain_count 1 

# scan insertion
preview_dft
insert_dft 

#write_test_protocol -out src/$design_name.spf 

compile -scan -incremental


write_file -hierarchy -format verilog -out $SYNC_SYN_NETLIST
write_sdc $SYNC_SYN_SDC

# Add scandef for bundled data design
# add _myScan at the end of each scan cell and output the scandef

set scanR_cells [get_cells "*" -filter "@ref_name == EDGE_SCELL_R"]
set scanS_cells [get_cells "*" -filter "@ref_name == EDGE_SCELL_S"]
foreach_in_collection cell $scanR_cells { 
	set temp [get_object_name [get_cells $cell]]
	change_names -instance $temp -new_name ${temp}_myScan
}
foreach_in_collection cell $scanS_cells { 
	set temp [get_object_name [get_cells $cell]]
	change_names -instance $temp -new_name ${temp}_myScan
}

write_scan_def -output ${SYNC_BD_SCAN_DEF};

set sh_command_log_file "${SYNC_SYN_LOG}/command.log"
file copy -force filenames.log ${SYNC_SYN_LOG}/filenames.log


set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: compile_ultra, write_file done $clockstring"


if { !$env(DEBUG) } {
	exit
}
