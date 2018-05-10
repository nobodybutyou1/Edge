# Copyright (c) 2017, Matheus Gibiluka, and Matheus Trevisan Moreira
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
    # * Redistributions of source code must retain the above copyright
      # notice, this list of conditions and the following disclaimer.
    # * Redistributions in binary form must reproduce the above copyright
      # notice, this list of conditions and the following disclaimer in the
      # documentation and/or other materials provided with the distribution.
    # * Neither the name of the Pontifical Catholic University of Rio Grande do Sul nor the
      # names of its contributors may be used to endorse or promote products
      # derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Matheus Gibiluka, and Matheus Trevisan Moreira BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##########################################################################################
# Setup Environment
##########################################################################################
if { $CONT_WITH_ERROR } {
    set sh_continue_on_error true
} else {
    set sh_continue_on_error false
}

set_host_options -max_cores $NUM_CORES


##########################################################################################
# Create/Load MW Library
##########################################################################################
# Check if MW Library is already created
if {![file isdirectory $MW_DESIGN_LIB]} {
	# Create MW Library
	create_mw_lib -technology $mw_tech_file 				\
		-mw_reference_library $mw_ref_lib $MW_DESIGN_LIB
}

# Open MW Library
open_mw_lib $MW_DESIGN_LIB

# Load TLU+ Files
set_tlu_plus_files -max_tluplus $tlup_max -min_tluplus $tlup_min -tech2itf_map $tech2itf

# Open/Import design
import_designs $POST_DC_DDC -format ddc -top $DESIGN_NAME
read_sdc $POST_DC_SDC


# Save new cel and open it
save_mw_cel -as "${DESIGN_NAME}"
#if { [llength [get_mw_cels -quiet $POST_DCT_MW_CEL]] } {
#	close_mw_cel $POST_DCT_MW_CEL
#	open_mw_cel $DESIGN_NAME
#}

# Report Usage
echo "\n#############################################" 
echo "After CREATE/LOAD MW time: " [cputime] sec
echo "After CREATE/LOAD MW usage:  MEM =" [mem] KBytes
echo "ICC core utilization: " $ICC_CORE_UTILIZATION
echo "#############################################\n" 


##########################################################################################
# ACDC Environment Settings
##########################################################################################
# Design Settings
##########################################################################################
# Initial Physical Synthesis Settings
##########################################################################################
remove_clock edge_clk_s
remove_clock edge_clk_m

set edge_clk_m_pin [get_object_name [get_pins -of_objects edge_clk_m -filter "direction==out"]]
set edge_clk_s_pin [get_object_name [get_pins -of_objects edge_clk_s -filter "direction==out"]]

set edge_clk_m_latch [add_to_collection [get_cells -of_objects edge_clk_m -filter "name=~*edgeM*"] [get_cells -of_objects edge_clk_m -filter "name=~R*"]]
set edge_clk_m_latch_in [get_object_name [get_pins -of_objects $edge_clk_m_latch -filter "direction==in"]]
set edge_clk_m_latch_out [get_object_name [get_pins -of_objects $edge_clk_m_latch -filter "direction==out"]]

set edge_clk_s_latch [add_to_collection [get_cells -of_objects edge_clk_s -filter "name=~*edgeS*"] [get_cells -of_objects edge_clk_s -filter "name=~R*"]]
set edge_clk_s_latch_in [get_object_name [get_pins -of_objects $edge_clk_s_latch -filter "direction==in"]]
set edge_clk_s_latch_out [get_object_name [get_pins -of_objects $edge_clk_s_latch -filter "direction==out"]]

remove_ideal_network [get_pins -of_objects edge_clk_m -filter "direction==out"]
remove_ideal_network [get_pins -of_objects edge_clk_s -filter "direction==out"]


set_size_only *mybuf1
set_size_only *mybufn

# Prefer Clock Lib cells to fulfull min_delay constraints
#set_prefer $normal_cell
set_prefer -min $hold_cell

# Increase priority of min_delay cosntraints 
set_cost_priority min_delay 
