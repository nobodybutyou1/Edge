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




# Source other scripts
set edge_clk_m_pin [get_object_name [get_pins -of_objects edge_clk_m -filter "direction==2"]]
set edge_clk_s_pin [get_object_name [get_pins -of_objects edge_clk_s -filter "direction==2"]]


set edge_clk_m_latch [add_to_collection [get_cells -of_objects edge_clk_m -filter "name=~*edgeM*"] [get_cells -of_objects edge_clk_m -filter "name=~R*"]]
set edge_clk_m_latch_in [get_object_name [get_pins -of_objects $edge_clk_m_latch -filter "direction==1"]]
set edge_clk_m_latch_out [get_object_name [get_pins -of_objects $edge_clk_m_latch -filter "direction==2"]]

set edge_clk_s_latch [add_to_collection [get_cells -of_objects edge_clk_s -filter "name=~*edgeS*"] [get_cells -of_objects edge_clk_s -filter "name=~R*"]]
set edge_clk_s_latch_in [get_object_name [get_pins -of_objects $edge_clk_s_latch -filter "direction==1"]]
set edge_clk_s_latch_out [get_object_name [get_pins -of_objects $edge_clk_s_latch -filter "direction==2"]]

source functions.tcl
source ACSetup.tcl

# Create functions placeholder
proc fix_timing {} {
	echo "You must run 'source (DCT/IC)Flow.tcl' before trying to fix timing."
}

source dc_fix_delayline.tcl
fix_timing_iterative

write_file -hierarchy -format verilog -out $FIXDELAY_NETLIST
write_sdc $FIXDELAY_SDC
write_sdf $FIXDELAY_SDF
rename_design ${DESIGN_NAME} ${DESIGN_NAME}_dc
write_file -hierarchy -format verilog -out $FIXDELAY_NETLIST_T
write_sdf $FIXDELAY_SDF_T
rename_design ${DESIGN_NAME}_dc ${DESIGN_NAME}
set sh_command_log_file "${FIXDELAY_LOG}/command.log"
file copy -force filenames.log ${FIXDELAY_LOG}/filenames.log
