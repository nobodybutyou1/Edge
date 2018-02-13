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





class edge_monitor extends uvm_monitor;
   virtual edge_if vif;
   string monitor_intf;
   int num_pkts;

   uvm_analysis_port #(data_packet) item_collected_port;
   data_packet data_collected;
   data_packet data_clone;

   `uvm_component_utils(edge_monitor)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(string)::get(this, "", "monitor_intf", monitor_intf))
         `uvm_fatal("NOSTRING", {"Need interface name for: ", get_full_name( ), ".monitor_intf"})

      `uvm_info(get_type_name( ), $sformatf("INTERFACE USED = %0s", monitor_intf), UVM_LOW)
      if(!uvm_config_db#(virtual edge_if)::get(this, "", monitor_intf, vif))
         `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name( ), ".vif"})
      
      item_collected_port = new("item_collected_port", this);      
      data_collected = data_packet::type_id::create("data_collected");
      data_clone = data_packet::type_id::create("data_clone");

      `uvm_info(get_full_name( ), "Build stage complete.", UVM_LOW)
   endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
      collect_data( );
   endtask: run_phase

   virtual task collect_data( );
      forever begin
         @(negedge vif.clk) 
         data_collected.data_r = vif.data_r;
         data_collected.intr_in = vif.intr_in;
         data_collected.mem_pause = vif.mem_pause;
         //@(vif.Rack);
         data_collected.address_next = vif.address_next;
         data_collected.byte_we_next = vif.byte_we_next;
         data_collected.address = vif.address;
         data_collected.byte_we = vif.byte_we;
         data_collected.data_w = vif.data_w;
         $cast(data_clone, data_collected.clone( ));
         item_collected_port.write(data_clone);
         num_pkts++;
      end 
   endtask: collect_data

   virtual function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name( ), $sformatf("REPORT: COLLECTED PACKETS = %0d", num_pkts), UVM_LOW)
   endfunction: report_phase

  
endclass: edge_monitor
