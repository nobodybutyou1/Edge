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


set dataIn [get_object_name [remove_from_collection [all_inputs] [get_ports "Lreq Rack edge_reset edge_ctrl_reset"]]]
set dataOut [get_object_name [remove_from_collection [all_outputs] [get_ports "Lack Rreq"]]]
set inputW [llength $dataIn]
set outputW [llength $dataOut]

set HALF_PERIOD [expr $CLK_PERIOD/2]
analyze -format verilog -define fifo=s2a,DW=$inputW,W="S",R="A" fifo.v
elaborate s2a
create_clock -name "clk_put" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD] [get_ports wClk]
compile
#ungroup -all -flatten
#redirect $CDC_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out $CDC_OUT_FOLDER/s2a.v
write_file -hierarchy -format ddc -out $CDC_OUT_FOLDER/s2a.ddc
write_sdc $CDC_OUT_FOLDER/s2a.sdc

analyze -format verilog -define fifo=a2s,DW=$outputW,W="A",R="S" fifo.v
elaborate a2s
create_clock -name "clk_get" -period $CLK_PERIOD -waveform [list 0 $HALF_PERIOD] [get_ports rClk]
compile
#ungroup -all -flatten
#redirect $CDC_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out $CDC_OUT_FOLDER/a2s.v
write_file -hierarchy -format ddc -out $CDC_OUT_FOLDER/a2s.ddc
write_sdc $CDC_OUT_FOLDER/a2s.sdc

set fo [open "./cdcDUTtemp.v" "w"] 
puts $fo "module cdcDUT (din, dout);"
puts $fo "input \[[expr $inputW-1]:0\] din;"			
puts $fo "output \[[expr $outputW-1]:0\] dout;"					
puts $fo "endmodule"				
close $fo
analyze -format verilog cdcDUTtemp.v
elaborate cdcDUT
link
compile

current_design cdcDUT
create_cell s2a s2a
create_cell a2s a2s
create_cell edge ${DESIGN_NAME}
uniquify
create_port -direction in {reset edge_ctrl_reset cdc_reset}
create_port -direction in {clk_put put clk_get get}
create_port -direction out {spaceav datav}



create_net {reset}
connect_net reset [get_ports reset]
connect_net reset [get_pins */edge_reset]

create_net {cdc_reset}
connect_net cdc_reset [get_ports cdc_reset]
connect_net cdc_reset [get_pins */rst]


create_net {edge_ctrl_reset}
connect_net edge_ctrl_reset [get_ports edge_ctrl_reset]
connect_net edge_ctrl_reset [get_pins */edge_ctrl_reset]
create_net {clk_put}
connect_net clk_put [get_ports clk_put]
connect_net clk_put [get_pins s2a/wClk]
create_net {clk_get}
connect_net clk_get [get_ports clk_get]
connect_net clk_get [get_pins a2s/rClk]
create_net {spaceav}
connect_net spaceav [get_ports spaceav]
connect_net spaceav [get_pins s2a/spaceAv]
create_net {datav}
connect_net datav [get_ports datav]
connect_net datav [get_pins a2s/dValid]
create_net {put}
connect_net put [get_ports put]
connect_net put [get_pins s2a/wReq]
create_net {get}
connect_net get [get_ports get]
connect_net get [get_pins a2s/rReq]

# connect req and ack

create_net Lack
connect_net Lack [get_pins s2a/rAck]
connect_net Lack [get_pins edge/Lack]
create_net Rreq
connect_net Rreq [get_pins a2s/wReq]
connect_net Rreq [get_pins edge/Rreq]
create_net Rack
connect_net Rack [get_pins a2s/wAck]
connect_net Rack [get_pins edge/Rack]

create_cell orGate $or_cell
set inOrGate [get_object_name [get_pins -of_objects [get_cells orGate] -filter "direction == 1"]]
set outOrGate [get_object_name [get_pins -of_objects [get_cells orGate] -filter "direction == 2"]]
if {[expr [llength $inOrGate] ne 2] || [expr [llength outOrGate] ne 1]} { error "The defined or gate is of wrong type"}

# continue here Lreq   s2a/Rreq port: edge_ctrl_Lreq edge/Lreq
create_port -direction in edge_ctrl_Lreq
connect_pin -from edge_ctrl_Lreq -to [lindex $inOrGate 0] -port_name edge_ctrl_Lreq
connect_pin -from s2a/rReq -to [lindex $inOrGate 1]
create_net Lreq
connect_net Lreq [get_pins [lindex $outOrGate 0]]
connect_net Lreq [get_pins edge/Lreq]


set i 0
foreach tmp $dataIn {
	create_net din$i
	connect_net din$i [get_port din[$i]]
	connect_net din$i [get_pins s2a/dIn[$i]]
	create_net s2aEdge$i
	connect_net s2aEdge$i [get_pins s2a/dOut[$i]]
	connect_net s2aEdge$i [get_pins edge/$tmp]
	incr i
}

set i 0
foreach tmp $dataOut {
	create_net dout$i
	connect_net dout$i [get_port dout[$i]]
	connect_net dout$i [get_pins a2s/dOut[$i]]
	create_net edgeA2s$i
	connect_net edgeA2s$i [get_pins edge/$tmp]
	connect_net edgeA2s$i [get_pins a2s/dIn[$i]]
	incr i
}

redirect $POST_DC_LOG/change_names { change_names -rules verilog -hierarchy -verbose }
write_file -hierarchy -format verilog -out $CDC_OUT_FOLDER/cdcDUT.v
# note that this is non-hieararchy, prepared for icc.
write_file -format verilog -out $CDC_OUT_FOLDER/top_icc.v
write_file -format ddc -out $CDC_OUT_FOLDER/top_icc.ddc
write_sdc $CDC_OUT_FOLDER/cdcDUT.sdc

