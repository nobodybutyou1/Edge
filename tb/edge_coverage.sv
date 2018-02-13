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





class edge_coverage extends uvm_subscriber #(data_packet);

   data_packet pkt;
   int count;

   `uvm_component_utils(edge_coverage)

   covergroup cg;
      option.per_instance = 1;
      cov_cf:    coverpoint pkt.cf;
      cov_en:    coverpoint pkt.enable;
      cov_ino:   coverpoint pkt.data_in0;
      cov_in1:   coverpoint pkt.data_in1;
      cov_out0:  coverpoint pkt.data_out0;
      cov_out1:  coverpoint pkt.data_out1;
      cov_del:   coverpoint pkt.delay;
   endgroup: cg

   function new(string name, uvm_component parent);
      super.new(name, parent);
      cg = new( );
   endfunction: new

   function void write(data_packet t);
      pkt = t;
      count++;
      cg.sample( );
   endfunction: write

   virtual function void extract_phase(uvm_phase phase);
      `uvm_info(get_type_name( ), $sformatf("Number of coverage packets collected = %0d", count), UVM_LOW)
      `uvm_info(get_type_name( ), $sformatf("Current coverage  = %f", cg.get_coverage( )), UVM_LOW)
   endfunction: extract_phase
endclass: edge_coverage
