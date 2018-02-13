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





# Functions that handle a path's timing report
proc custom_report_timing_collection {collection {verb 0}} { 
	foreach_in_collection path $collection {
		echo "----------------------------------------------"
		echo [format "    From: %s" [get_attribute [get_attribute $path startpoint] full_name]]
		echo [format "      To: %s" [get_attribute [get_attribute $path endpoint] full_name]]
		echo [format " Arrival: %s" [get_attribute $path arrival]]

	
		# Check Points
		if {$verb != 0} {
			foreach_in_collection point [get_attribute $path points] {
				echo "      -----------------"
				echo [format "      %s:" [get_attribute $point full_name]]
				echo [format "             Pin: %s" [get_attribute [get_attribute $point object] full_name]]
				echo [format "         Arrival: %s" [get_attribute $point arrival]]
			}
		}
		echo ""
	}
}

proc custom_report_timing {from {to "*"} {verb 0} {type max} {nworst 1}} { 
	custom_report_timing_collection [get_timing_paths -include_hierarchical_pins \
					 	-nworst $nworst -from $from -to $to -delay_type $type] $verb
}

# Functions to get the max delay from a collection of paths
# Get worst delay from (to) (type) (verbose)
proc custom_get_delay {{from *} {to *} {exclude ""} {type max} {debug 0}} { 
	if { $debug == 1} { echo [format "DEBUG custom_get_delay: from: %s  // to %s " $from $to  ] }

	# Get one path
	if {[expr {$exclude} eq  {"EdgeExcludeNone"}]} {
		set exclude ""
	}
	if {$exclude eq ""} {
		set path [get_timing_paths -nworst 1 -from $from -to $to -delay_type $type -include_hierarchical_pins]
        } else {
		set path [get_timing_paths -nworst 1 -to $to -delay_type $type -exclude $exclude -include_hierarchical_pins]
	}
	# Path information
	set startpoint_delay 0
	set startpoint [get_attribute [get_attribute $path startpoint] full_name]
	set endpoint_delay [get_attribute $path arrival]
	set endpoint [get_attribute [get_attribute $path endpoint] full_name]

	# Check if delay was found
	if { [llength $endpoint_delay] == 0 } {
		error [format "custom_get_delay: could not find timing for path: %s --> %s" $from $to] 
	}

	if { $debug == 1} { echo [format "DEBUG custom_get_delay: startpoint: %s  // endpoint %s " $startpoint $endpoint  ] }

	# Check check if startpoint is actually what was asked for
	set check_startpin 0
	if { $from != "*" || $exclude != "" } {
		set startpins [get_pins -quiet $from]
		# If there is no pin matching $from, look for ports
		if { [sizeof_collection $startpins] == 0 } {
			set startpins [get_ports -quiet $from]
			# If, still, there is no port matching that name
			if { [sizeof_collection $startpins] == 0 } {
			error [format "custom_get_delay: could not find collection of startpins: $s " $from ]
			}
		}
		set check_startpin 1
		
		# Check if any of the pins is the startpoint of the path
		foreach_in_collection pin $startpins {
			if { [get_attribute $pin full_name] == $startpoint } {
				set check_startpin 0
			}
		}
	}

	# Check check if endpin is actually what was asked for
	set check_endpin 0
	if { $to != "*" } {
		set endpins [get_pins -quiet $to]
		# If there is no pin matching $from, look for ports
		if { [sizeof_collection $endpins] == 0 } {
			set endpins [get_ports -quiet $to]
			# If, still, there is no port matching that name
			if { [sizeof_collection $endpins] == 0 } {
			error [format "custom_get_delay: could not find collection of endpins: $s " $from ]
			}
		}
		set check_endpin 1

		# Check if any of the pins is the end of the path
		foreach_in_collection pin $endpins {
			if { [get_attribute $pin full_name] == $endpoint } {
				set check_endpin 0
			}
		}
	}

	if { $debug == 1} { echo [format "DEBUG custom_get_delay: check_startpin: %s  // check_endpin %s " $check_startpin $check_endpin  ] }

	# If the desired start/endpints are not the ones on the path, loop through points and get the correct delays
	if { ($check_startpin == 1) || ($check_endpin == 1) } {
		set found_startpin 0
		set found_endpin 0


		foreach_in_collection p $path {
			# Go through all points until both startpin and endpin are found
			foreach_in_collection point [get_attribute $p points] {
				set point_name [get_attribute [get_attribute $point object] full_name]
				if { $debug == 1} { echo [format "DEBUG custom_get_delay: verifying point: %s " $point_name ] }

				if { ($check_startpin == 1) && ($found_startpin == 0) } {
					# Check if any of the startpins is the current point_name
					foreach_in_collection pin $startpins {
						if { [get_attribute $pin full_name] == $point_name } {
							set startpoint_delay [get_attribute $point arrival]
							set startpoint $point_name
							set found_startpin 1

							if { $debug == 1} { echo "DEBUG custom_get_delay: found startpoint." }
						}
					}
				}

				if { ($check_endpin == 1) && ($found_endpin == 0) } {
					# Check if any of the endpins is the current point_name
					foreach_in_collection pin $endpins {
						if { [get_attribute $pin full_name] == $point_name } {
							set endpoint_delay [get_attribute $point arrival]
							set endpoint $point_name
							set found_endpin 1

							if { $debug == 1} { echo "DEBUG custom_get_delay: found endpoint." }
						}
					}
				}

				# If found everyting needed, break
				if { (($check_endpin == 1) && ($found_endpin == 1)) || ($check_endpin == 0) } {
					if { (($check_startpin == 1) && ($found_startpin == 1)) || ($check_startpin == 0) } {
						break
					}
				}
			}	
		}
		
		if { $debug == 1} { echo "DEBUG custom_get_delay: finished starpoint/endpoint check." }

		# Error checking
		if { ($check_endpin == 1) && ($found_endpin == 0) } {
			error "custom_get_delay: didnt find endpin."
		}

		if { ($check_startpin == 1) && ($found_startpin == 0) } {
			error "custom_get_delay: didnt find startpin."
		}
	}
	
	# Check if endpoint is a register D pin, if so, add 50ps for setup time
	set workaround_setup 0

	if { [regexp {_reg[\[\]0-9]+/D} $endpoint] } {
		set workaround_setup 0.050
	}


	if {$debug != 0} {
		echo "custom_get_delay report:"
		echo [format "    From: %s" $startpoint]
		echo [format "      To: %s" $endpoint]
		echo [format " Arrival: %s" [expr $endpoint_delay - $startpoint_delay + $workaround_setup ]]
	}
	return [expr $endpoint_delay - $startpoint_delay + $workaround_setup]
}

# Function to get the MAX value of a list
proc custom_max {args} {
	set init 0	
	foreach arg $args {
		if {$init == 0} {
			set init 1
			set max $arg
		} else {
			if {$arg > $max} {
				set max $arg
			}
		}
	}
	return $max
}


# Function to get the MIN value of a list
proc custom_min {args} {
	set init 0	
	foreach arg $args {
		if {$init == 0} {
			set init 1
			set min $arg
		} else {
			if {$arg < $min} {
				set min $arg
			}
		}
	}
	return $min
}


# # Function to check which pins or ports exist (Original version)
# proc custom_report_existent {list} {
	# foreach p $list {
		# if {[sizeof_collection [get_pin -quiet $p]] != 0} {
			# echo $p
		# } else {
			# if {[sizeof_collection [get_port -quiet $p]] != 0} {
				# echo $p
			# }
		# }
	# }
# }


# Function to check which pins or ports exist (Modified to support [all_inputs] and {...} in xml file)
proc custom_report_existent {list} {
	foreach p $list {
		set k [all_inputs]
		if { [regexp {_sel[0-9]+} $p] == 1 } {
			if { [ compare_collections $p $k ] == 0 } {
				echo [format "\[all_inputs\]"]
			}
		} else {
			if {[sizeof_collection [get_pin -quiet $p]] != 0} {
				if {[llength $p] == 1} {
					echo $p
				} else {
					echo [format "{%s}" $p] 
				}
			} else {
				if {[sizeof_collection [get_port -quiet $p]] != 0} {
					if {[llength $p] == 1} {
						echo $p
					} else {
						echo [format "{%s}" $p] 
					}
				}
			}
		}
	}
}

# Set min delay
proc custom_set_min_delay {from to exclude delay {debug 0}} {
	set startpin $from
	set endpin $to
	set delay_value $delay

	if { $delay_value <= 0} {return 1}

	if { $debug == 1 } { echo [ format "custom_set_min_delay debug. (from = %s, to = %s)" $from $to ] }

	# Try to compensate interconnect and other delays
	set min_delay_margin 1.20
	set setup_time 0.0

	# Try to reduce delay margins by setting maximum delay constraints
	set max_delay_margin 1.40
	set delay_value [expr $delay_value * $min_delay_margin + $setup_time]
	set max_delay_value [expr $delay_value * $max_delay_margin]

	# Makes sure that all delay values are positive
	if { $delay_value <= 0 } {
		set delay_value 0
		set max_delay_value [expr $max_delay_margin - 1]
	}
	
	if { [set_min_delay -from $startpin -to $endpin $delay_value] == 0 } {
		error "custom_set_min_delay: set_min_delay returned 0 (-from -to)"
	}
	
	if { [set_max_delay -from $startpin -to $endpin $max_delay_value] == 0 } {
		error "custom_set_min_delay: set_max_delay returned 0 (-from -to)"
	}

	return 1
}


