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




# Milkyway Library 
set MW_DESIGN_LIB "MW_${DESIGN_NAME}"

#####################################
# Libraries
#####################################
# Tech Libraries
set design_kit_path "/opt/pdk/stm/.28nm-cmos28fdsoi_24"
# Point to design kit Milkyway library if custom MW library is not needed
set custom_mw_path  "/home/hzha/Milkyway" 
# Logic Libraries
set tech_lib_path  [list ${design_kit_path}/C28SOI_SC_12_CORE_LR@2.0@20130411.0/libs/        \
                         ${design_kit_path}/C28SOI_SC_12_CLK_LR@2.1@20130621.0/libs/ ]

# Search Path (for tcl, xml, libraries, verilog, etc...)
set search_path [concat $search_path $tech_lib_path]

set symbol_library [list C28SOI_SC_12_CORE_LR.sdb \
                         C28SOI_SC_12_CLK_LR.sdb ]

# Set specific library needed for DC within search_path
set target_library [list C28SOI_SC_12_CORE_LR_tt28_1.00V_25C.db \
                         C28SOI_SC_12_CLK_LR_tt28_1.00V_25C.db ]
set link_library [concat * $target_library]

# Set specific cells used as preference for logic and delay lines
set normal_cell "C28SOI_SC_12_CORE_LR/*"
set hold_cell "C28SOI_SC_12_CLK_LR/*"
# used as first and last buffer of DLs
set buffer_cell "C12T28SOI_LR_CNBFX4_P0"  

# Physical Libraries (technology and cell library)
set mw_tech_file "${custom_mw_path}/C28SOI_SC_12_tech.tf"
set mw_ref_lib [list ${custom_mw_path}/C28SOI_SC_12_CORE_LR ${custom_mw_path}/C28SOI_SC_12_CLK_LR ]

# TLU+ Files (Cap/Res info for technology)
set tlup_base_path "${design_kit_path}/SynopsysTechnoKit_cmos028FDSOI_6U1x_2U2x_2T8x_LB@2.1.2@20121128.2/TLUPLUS"
set tlup_max "${tlup_base_path}/FuncRCmax/tluplus"
set tlup_typ "${tlup_base_path}/nominal/tluplus"
set tlup_min "${tlup_base_path}/FuncRCmin/tluplus"
set tech2itf "${tlup_base_path}/mapfile"

#####################################
# Set Technology Constraints
#####################################
set TechnoKit_path "/opt/pdk/stm/.28nm-cmos28fdsoi_24/SynopsysTechnoKit_cmos028FDSOI_6U1x_2U2x_2T8x_LB@2.1.2@20121128.2"

# Don't Use Cells
source ${TechnoKit_path}/COMMON/dont_use_cells.tcl

# Load STM Tech Variables
source ${TechnoKit_path}/ICCOMPILER/techno_variables_common.tcl
source ${TechnoKit_path}/ICCOMPILER/techno_variables_route.tcl
source ${TechnoKit_path}/ICCOMPILER/techno_variables_12T.tcl

# IO2CORE
set lib_io2core(top) $STM_io2core(top)
set lib_io2core(bottom) $STM_io2core(bottom)
set lib_io2core(left) $STM_io2core(left)
set lib_io2core(right) $STM_io2core(right)

# Power Rail Settings
set lib_vdd_label $STM_techPowerPinName
set lib_vdds_label $STM_techSplitPowerPinName
set lib_vdd_ring_layer(vertical) "M4"
set lib_vdd_ring_layer(horizontal) "M4"
set lib_vdd_ring_width(vertical) 2.5
set lib_vdd_ring_width(horizontal) 2.5
set lib_vdd_ring_offset(vertical) 0.5
set lib_vdd_ring_offset(horizontal) 0.5

# Ground Rail Settings
set lib_gnd_label $STM_techGroundPinName
set lib_gnds_label $STM_techSplitGroundPinName
set lib_gnd_ring_layer(vertical) "M3"
set lib_gnd_ring_layer(horizontal) "M3"
set lib_gnd_ring_width(vertical) 2.5
set lib_gnd_ring_width(horizontal) 2.5
set lib_gnd_ring_offset(vertical) 3.5
set lib_gnd_ring_offset(horizontal) 3.5


# Additional constraint due to tile table error from icc
# Error: Failed to read tile table property of reference librarycell C12T28SOIDV_LRBR0P6_NAND3X18_P0.  (APL-080)
set_dont_use "C28SOI_SC_12_CORE_LR/C12T28SOIDV_LRBR0P6_NAND3X18_P0"




