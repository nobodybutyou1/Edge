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




set WORK_FOLDER "work"

set search_path [concat $search_path $env(EDGE_ROOT)/common $env(EDGE_ROOT)/scripts/add_controller $env(EDGE_ROOT)/scripts/ff2latch $env(EDGE_ROOT)/scripts/retiming $env(EDGE_ROOT)/scripts/sync_syn $env(EDGE_ROOT)/scripts/environment $env(EDGE_ROOT)/scripts/fixdelay $env(EDGE_ROOT)/scripts/icc]

source $env(EDGE_DESIGN_TCL)
source $env(EDGE_TECH_TCL)
source filename.tcl
