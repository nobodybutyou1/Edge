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

source pre_icc.tcl
source floorplan.tcl
source placement.tcl
##########################################################################################
# generated blanced buffer tree
##########################################################################################
source buffer_tree.tcl

source routing.tcl

##########################################################################################
# Load ACDC Delay Line Insertion Environment
##########################################################################################
# Read Relative Timing Constraints
if { [file exists $DESIGN_ACDC_CONST] == 1} {
	AC_load_constraints $DESIGN_ACDC_CONST_ICC > $POST_ICC_LOG/load_constraints.log
	echo "AC Constraints set. You can run 'AC_report_constraints', fix_timing', 'fix_timing_iterative' or 'write_design'."
} else {
	error "AC Constraints not found."	
}

# Helper Functions
set ACDC_FIX_TIMING_ITERATIONS 0
proc fix_timing {} {
	global ACDC_FIX_TIMING_ITERATIONS
	AC_set_constraints
	# Apply Constraints
	#set_scenario_options -leakage_power true -dynamic_power true -setup true
        #set_total_power_strategy -effort medium
	place_opt -effort high -skip_initial_placement
 	route_opt -effort high
 	route_search_repair -rerun_drc 

	# Prevent further netlist changes other than sizing
	#set_size_only [get_cells * -hier -filter "is_hierarchical == false"]

	echo "ACDC fix_timing complete. Check if timing constraints were met invoking 'AC_report_constraints'."
	incr ACDC_FIX_TIMING_ITERATIONS
}

proc fix_timing_iterative {{maxIter 10}} {
	global ACDC_FIX_TIMING_ITERATIONS
	while { [AC_check_constraints] != 1 } {
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
}


##########################################################################################
# Storing and Reporting Design
##########################################################################################
proc write_design {} {
	global MW_DESIGN_LIB
	global POST_ICC_NETLIST
	global POST_ICC_SDF
	global POST_ICC_PARASITICS
	global POST_ICC_DDC
	global POST_ICC_MW_CEL


	# Store Netlist
	if { [ write_verilog $POST_ICC_NETLIST ] != 1} {
		error "Failed writing netlist."	
	} else {
		echo "Netlist written."
	}

	# Store SDF
	if { [ write_sdf $POST_ICC_SDF ] != 1 } {
		error "Failed writing SDF file."
	} else {
		echo "SDF file written."
	}

	# Store Parasitics
	if { [ write_parasitics -output $POST_ICC_PARASITICS ] != 1 } {
		error "Failed writing parasitics file."
	} else {
		echo "Parasitics file written."
	}

	# Create Block Abstraction
	create_block_abstraction

	# Write DDC
	if { [ write -format ddc -hierarchy -output $POST_ICC_DDC ] != 1 } {
		error "Failed writing DDC file."
	} else {
		echo "DDC file written."
	}

	save_mw_cel -as "${POST_ICC_MW_CEL}"

	# Create FRAM view
	if { [ create_macro_fram -library_name $MW_DESIGN_LIB -cell_name $POST_ICC_MW_CEL ] != 1 } {
		error "Failed creating FRAM view"
	} else {
		echo "FRAM view created."
	}
}

proc write_reports {} {
	global POST_ICC_REPORT
	# Check design
	# check_design -nosplit
	check_design -nosplit > $POST_ICC_REPORT/check_design.icc.rpt
	
	# Area
	#report_area -nosplit
	report_area -nosplit > $POST_ICC_REPORT/area.icc.rpt
	
	# Constraints
	#report_constraints -nosplit
	report_constraints -nosplit > $POST_ICC_REPORT/constraints.icc.rpt

	# ACDC Constraints
	#AC_report_constraints
	AC_report_constraints > $POST_ICC_REPORT/AC_constraints.icc.rpt
}

