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







##########################################################################################
# Load ACDC Delay Line Insertion Environment
##########################################################################################

# Optimization and Delay Line Start/End Points Insertion
set_prefer $normal_cell
set_prefer -min $hold_cell

# Increase priority of min_delay cosntraints 
set_cost_priority min_delay 

# Read Relative Timing Constraints
if { [file exists $DESIGN_ACDC_CONST] == 1} {
	AC_load_constraints $DESIGN_ACDC_CONST > $FIXDELAY_LOG/load_constraints.log
	echo "AC Constraints set. You can run 'AC_report_constraints', fix_timing', 'fix_timing_iterative' or 'write_design'."
} else {
	error "AC Constraints not found."	
}

# Helper Functions
set ACDC_FIX_TIMING_ITERATIONS 0
# Function that set min delay for each delayline based on relative timing constraints.
set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
echo "TIMESTAMP: start fix_timing iteration $clockstring"

proc fix_timing {} {
	global ACDC_FIX_TIMING_ITERATIONS
	AC_set_constraints
	
	set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
	echo "TIMESTAMP: set constraints done $clockstring"
	
	# Apply Constraints
	compile -incremental_mapping
	# Prevent further netlist changes other than sizing
	# set_size_only [get_cells * -hier -filter "is_hierarchical == false"]

	set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
	echo "TIMESTAMP: compile done $clockstring"
	echo "ACDC fix_timing complete. Check if timing constraints were met invoking 'AC_report_constraints'."
	incr ACDC_FIX_TIMING_ITERATIONS
}

# fix timing iteratively to make sure the delay of delayline meet the relative timing constraints.
proc fix_timing_iterative {{maxIter 1}} {
	global ACDC_FIX_TIMING_ITERATIONS
	while { [AC_check_constraints] != 1 } {

	        set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
		echo "TIMESTAMP: check constraints done $clockstring"

		fix_timing

		if { $ACDC_FIX_TIMING_ITERATIONS > $maxIter } {
			break
		}
	}
	
	if { [AC_check_constraints] == 1 } {
		echo [ format "ACDC Constraints were met with %s iterations." $ACDC_FIX_TIMING_ITERATIONS ]
	} else {
		error "ACDC reached the iteration limit and did not meet constraints."
	}
        set clockstring [clock format [clock second] -format "%Y/%m/%d %H:%M:%S"]
	echo "TIMESTAMP: check constraints after fix_timing $clockstring"
}


