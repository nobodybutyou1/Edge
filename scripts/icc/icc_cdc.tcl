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

source $env(EDGE_ROOT)/scripts/environment/common_setting.tcl

source functions.tcl
source ACSetup.tcl

# Create functions placeholder
proc fix_timing {} {
	echo "You must run 'source (DCT/IC)Flow.tcl' before trying to fix timing."
}

# add IO constraints
set HALF_PERIOD [expr $CLK_PERIOD/2]
create_clock -name "clk_put" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD]
create_clock -name "clk_get" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD]
set_input_delay [expr 0.1*$CLK_PERIOD] -clock "clk_put" -clock_fall [all_inputs]
set_input_transition [expr 0.1*$CLK_PERIOD] [all_inputs]
set_load 0.02672 [all_outputs] 
set_output_delay [expr 0.1*$CLK_PERIOD] -clock "clk_get" [all_outputs]


source ICFlow_cdc.tcl

fix_timing_iterative
write_design
write_reports
set sh_command_log_file "${POST_ICC_LOG}/command.log"
#file copy -force filenames.log ${POST_ICC_LOG}/filenames.log
#source report_cell.tcl > reports/cell.rpt
if { !$env(DEBUG) } {
#   exit
}

