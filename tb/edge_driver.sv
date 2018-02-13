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





class edge_driver extends uvm_driver #(data_packet);
   virtual edge_if vif;

   `uvm_component_utils(edge_driver)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual edge_if)::get(this, "", "in_intf", vif))
         `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name( ), ".vif"})
      `uvm_info(get_full_name( ), "Build stage complete.", UVM_LOW)
   endfunction

   virtual task run_phase(uvm_phase phase);
      fork
         reset( );
         get_and_drive( );
      join
   endtask: run_phase

   virtual task reset( );      
      forever begin
         @(posedge vif.rst_edge);
         `uvm_info(get_type_name( ), "Resetting signals ... ", UVM_LOW)
         #5;
	 vif.intr_in = 1'b0;
         vif.mem_pause = 1'b0;	 
         vif.data_r = 32'b0;

      end
   endtask: reset

   virtual task get_and_drive( );
      forever begin
         @(negedge vif.rst_edge);
         while(vif.rst_edge == 1'b0) begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done( );
         end
      end 
   endtask: get_and_drive

   virtual task drive_packet(data_packet pkt);
      @(negedge vif.clk)
	  #1;
      vif.data_r=pkt.data_r;
      vif.intr_in=pkt.intr_in;
      vif.mem_pause = pkt.mem_pause;
   endtask

endclass:edge_driver
