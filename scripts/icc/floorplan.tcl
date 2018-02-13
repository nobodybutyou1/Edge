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
# Floorplan
##########################################################################################
create_floorplan 								\
	-core_utilization $ICC_CORE_UTILIZATION 	\
	-core_aspect_ratio $ICC_CORE_APECT_RATIO 	\
	-start_first_row 							\
	-flip_first_row 							\
	-left_io2core $lib_io2core(left) 			\
	-bottom_io2core $lib_io2core(bottom) 		\
	-right_io2core $lib_io2core(right) 			\
	-top_io2core $lib_io2core(top)

derive_pg_connection 			\
	-power_net $lib_vdd_label 	\
	-power_pin $lib_vdd_label 	\
	-ground_net $lib_gnd_label 	\
	-ground_pin $lib_gnd_label

# derive_pg_connection 			\
# 	-power_net $lib_vdd_label 	\
# 	-power_pin $lib_vdds_label 	\
# 	-ground_net $lib_gnd_label 	\
# 	-ground_pin $lib_gnds_label

derive_pg_connection 					\
	-tie 								\
	-power_net  $STM_techPowerName 		\
	-ground_net $STM_techGroundName

create_rectangular_rings 									\
	-nets $lib_vdd_label 									\
	-left_offset $lib_vdd_ring_offset(vertical) 			\
	-left_segment_layer $lib_vdd_ring_layer(vertical) 		\
	-left_segment_width $lib_vdd_ring_width(vertical) 		\
	-right_offset $lib_vdd_ring_offset(vertical) 			\
	-right_segment_layer $lib_vdd_ring_layer(vertical) 		\
	-right_segment_width $lib_vdd_ring_width(vertical) 		\
	-bottom_offset $lib_vdd_ring_offset(horizontal) 		\
	-bottom_segment_layer $lib_vdd_ring_layer(horizontal) 	\
	-bottom_segment_width $lib_vdd_ring_width(horizontal) 	\
	-top_offset $lib_vdd_ring_offset(horizontal) 			\
	-top_segment_layer $lib_vdd_ring_layer(horizontal) 		\
	-top_segment_width $lib_vdd_ring_width(horizontal)

create_rectangular_rings 									\
	-nets $lib_gnd_label 									\
	-left_offset $lib_gnd_ring_offset(vertical) 			\
	-left_segment_layer $lib_gnd_ring_layer(vertical) 		\
	-left_segment_width $lib_gnd_ring_width(vertical) 		\
	-right_offset $lib_gnd_ring_offset(vertical) 			\
	-right_segment_layer $lib_gnd_ring_layer(vertical) 		\
	-right_segment_width $lib_gnd_ring_width(vertical) 		\
	-bottom_offset $lib_gnd_ring_offset(horizontal) 		\
	-bottom_segment_layer $lib_gnd_ring_layer(horizontal) 	\
	-bottom_segment_width $lib_gnd_ring_width(horizontal) 	\
	-top_offset $lib_gnd_ring_offset(horizontal) 			\
	-top_segment_layer $lib_gnd_ring_layer(horizontal) 		\
	-top_segment_width $lib_gnd_ring_width(horizontal)

save_mw_cel -as "${DESIGN_NAME}_floorplan"

# Report Usage
echo "\n#############################################" 
echo "\nAfter FLOORPLAN time: " [cputime] sec
echo "After FLOORPLAN usage:  MEM =" [mem] KBytes
echo "#############################################\n" 

