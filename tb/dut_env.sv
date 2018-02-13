// Copyright (c) 2017, Yang Zhang, Haipeng Zha, and Huimei Cheng
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
    // * Redistributions of source code must retain the above copyright
      // notice, this list of conditions and the following disclaimer.
    // * Redistributions in binary form must reproduce the above copyright
      // notice, this list of conditions and the following disclaimer in the
      // documentation and/or other materials provided with the distribution.
    // * Neither the name of the University of Southern California nor the
      // names of its contributors may be used to endorse or promote products
      // derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL YANG ZHANG, HAIPENG ZHA, AND HUIMEI CHENG BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.





class dut_env extends uvm_env;

   edge_env        penv_in;
   edge_env        penv_out1;
   edge_env        penv_out2;
   edge_scoreboard sb;
   //edge_coverage   edge_cov;


   `uvm_component_utils(dut_env)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
         
        uvm_config_db#(int)::set(this, "penv_in.agent.sequencer", "max_count", 22);

      uvm_config_db#(int)::set(this, "penv_in.agent", "is_active", 1'b1);
      uvm_config_db#(int)::set(this, "penv_out1.agent", "is_active", 1'b0);
	  uvm_config_db#(int)::set(this, "penv_out2.agent", "is_active", 1'b0);

      uvm_config_db#(string)::set(this, "penv_in.agent.monitor", "monitor_intf", "in_intf");
      uvm_config_db#(string)::set(this, "penv_out1.agent.monitor", "monitor_intf", "out_intf1");
	  uvm_config_db#(string)::set(this, "penv_out2.agent.monitor", "monitor_intf", "out_intf2");

      penv_in = edge_env::type_id::create("penv_in", this);
      penv_out1 = edge_env::type_id::create("penv_out1", this);
	  penv_out2 = edge_env::type_id::create("penv_out2", this);

      sb = edge_scoreboard::type_id::create("sb", this);
      //edge_cov = edge_coverage::type_id::create("edge_cov", this);


      `uvm_info(get_full_name( ), "Build stage complete.", UVM_LOW)
   endfunction: build_phase 

   function void connect_phase(uvm_phase phase);
      penv_in.agent.monitor.item_collected_port.connect(sb.input_packets_collected.analysis_export);
      penv_out1.agent.monitor.item_collected_port.connect(sb.output_packets_collected1.analysis_export);
	  penv_out2.agent.monitor.item_collected_port.connect(sb.output_packets_collected2.analysis_export);


      `uvm_info(get_full_name( ), "Connect phase complete.", UVM_LOW)
   endfunction: connect_phase
   
endclass: dut_env
