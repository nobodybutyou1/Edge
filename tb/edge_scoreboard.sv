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





class edge_scoreboard extends uvm_scoreboard;
   uvm_tlm_analysis_fifo #(data_packet) input_packets_collected;
   uvm_tlm_analysis_fifo #(data_packet) output_packets_collected1;
   uvm_tlm_analysis_fifo #(data_packet) output_packets_collected2;
   
   data_packet input_packet;
   data_packet output_packet1;
   data_packet output_packet2;
//   mlite_cpu dut_ref();

   `uvm_component_utils(edge_scoreboard)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      input_packets_collected = new("input_packets_collected", this);
      output_packets_collected1 = new("output_packets_collected1", this);
	  output_packets_collected2 = new("output_packets_collected2", this);
      input_packet = data_packet::type_id::create("input_packet");
      output_packet1 = data_packet::type_id::create("output_packet1");
	  output_packet2 = data_packet::type_id::create("output_packet2");
      `uvm_info(get_full_name( ), "Build stage complete.", UVM_LOW)
   endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
       watcher( );
   endtask: run_phase

   virtual task watcher( );
      forever begin
         input_packets_collected.get(input_packet);
         output_packets_collected1.get(output_packet1);
		 output_packets_collected2.get(output_packet2);
         compare_data( );
      end
   endtask: watcher

   virtual task compare_data( );
      bit [15:0] exp_data0;
      bit [15:0] exp_data1;

	
	  if(|(output_packet1.address^output_packet2.address)==1'b1)
		`uvm_error(get_type_name( ), $sformatf("The value of address of Asynchronous design %0h does not match expected synchronous output data %0h", output_packet1.address, output_packet2.address))
	  if(|(output_packet1.address_next^output_packet2.address_next)==1'b1)
		`uvm_error(get_type_name( ), $sformatf("The value of address_next of Asynchronous design %0h does not match expected synchronous output data %0h", output_packet1.address_next, output_packet2.address_next))
	  if(|(output_packet1.byte_we_next^output_packet2.byte_we_next)==1'b1)
		`uvm_error(get_type_name( ), $sformatf("The value of byte_we_next of Asynchronous design %0h does not match expected synchronous output data %0h", output_packet1.byte_we_next, output_packet2.byte_we_next))
	  if(|(output_packet1.byte_we^output_packet2.byte_we)==1'b1)
		`uvm_error(get_type_name( ), $sformatf("The value of byte_we of Asynchronous design %0h does not match expected synchronous output data %0h", output_packet1.byte_we, output_packet2.byte_we))
	  if(|(output_packet1.data_w^output_packet2.data_w)==1'b1)
		`uvm_error(get_type_name( ), $sformatf("The value of data_w of Asynchronous design %0h does not match expected synchronous output data %0h", output_packet1.data_w, output_packet2.data_w))
	
	
   endtask:compare_data

endclass: edge_scoreboard
