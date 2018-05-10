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





set DESIGN_ACDC_CONST "$env(EDGE_ROOT)/common/general.xml"
set DESIGN_ACDC_CONST_ICC "$env(EDGE_ROOT)/common/general_icc.xml"
set TEST_OUT_FOLDER "test"
# DC Output Files
set SYNC_SYN_OUT_FOLDER   "sync_syn"
set SYNC_SYN_NETLIST   "${SYNC_SYN_OUT_FOLDER}/${DESIGN_NAME}.v"
set SYNC_SYN_NETLIST_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_syn.v"
set SYNC_SYN_SDC   "${SYNC_SYN_OUT_FOLDER}/${DESIGN_NAME}.sdc"
set SYNC_SYN_SDF   "${SYNC_SYN_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set SYNC_SYN_LOG "${SYNC_SYN_OUT_FOLDER}/logs"

set FF2LATCH_OUT_FOLDER   "ff2latch"
set FF2LATCH_NETLIST   "${FF2LATCH_OUT_FOLDER}/${DESIGN_NAME}.v"
set FF2LATCH_SDC   "${FF2LATCH_OUT_FOLDER}/${DESIGN_NAME}.sdc"
set FF2LATCH_SDF   "${FF2LATCH_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set FF2LATCH_NETLIST_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_ff2latch.v"
set FF2LATCH_SDF_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_ff2latch.sdf"
set FF2LATCH_LOG "${FF2LATCH_OUT_FOLDER}/logs"

set RETIMING_OUT_FOLDER   "retiming"
set RETIMING_NETLIST   "${RETIMING_OUT_FOLDER}/${DESIGN_NAME}.v"
set RETIMING_SDC   "${RETIMING_OUT_FOLDER}/${DESIGN_NAME}.sdc"
set RETIMING_SDF   "${RETIMING_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set RETIMING_NETLIST_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_retiming.v"
set RETIMING_SDF_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_retiming.sdf"
set RETIMING_LOG "${RETIMING_OUT_FOLDER}/logs"

set POST_DC_OUT_FOLDER "bd_conv"
set POST_DC_NETLIST    "${POST_DC_OUT_FOLDER}/${DESIGN_NAME}.v"
set POST_DC_SDF        "${POST_DC_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set POST_DC_SDC        "${POST_DC_OUT_FOLDER}/${DESIGN_NAME}.sdc"
set POST_DC_PARASITICS "${POST_DC_OUT_FOLDER}/${DESIGN_NAME}.spef"
set POST_DC_DDC        "${POST_DC_OUT_FOLDER}/${DESIGN_NAME}.ddc"
set POST_DC_LOG "${POST_DC_OUT_FOLDER}/logs"

set FIXDELAY_OUT_FOLDER   "fixdelay"
set FIXDELAY_NETLIST   "${FIXDELAY_OUT_FOLDER}/${DESIGN_NAME}.v"
set FIXDELAY_SDC   "${FIXDELAY_OUT_FOLDER}/${DESIGN_NAME}.sdc"
set FIXDELAY_SDF   "${FIXDELAY_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set FIXDELAY_NETLIST_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_dc.v"
set FIXDELAY_SDF_T   "${TEST_OUT_FOLDER}/${DESIGN_NAME}_dc.sdf"
set FIXDELAY_LOG "${FIXDELAY_OUT_FOLDER}/logs"

set FIXDELAY_NETLIST_DEL   "${FIXDELAY_OUT_FOLDER}/${DESIGN_NAME}_DEL.v"
set FIXDELAY_SDC_DEL   "${FIXDELAY_OUT_FOLDER}/${DESIGN_NAME}_DEL.sdc"

# ICC Output Files
set POST_ICC_OUT_FOLDER   "icc"
set POST_ICC_NETLIST    "${POST_ICC_OUT_FOLDER}/${DESIGN_NAME}.v"
set POST_ICC_SDF        "${POST_ICC_OUT_FOLDER}/${DESIGN_NAME}.sdf"
set POST_ICC_PARASITICS "${POST_ICC_OUT_FOLDER}/${DESIGN_NAME}.spef"
set POST_ICC_DDC        "${POST_ICC_OUT_FOLDER}/${DESIGN_NAME}.ddc"
set POST_ICC_MW_CEL     "${DESIGN_NAME}_postICC"
set POST_ICC_LOG 	"${POST_ICC_OUT_FOLDER}/logs"
set POST_ICC_REPORT 	"${POST_ICC_OUT_FOLDER}/reports"
