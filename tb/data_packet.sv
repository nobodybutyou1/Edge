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





class data_packet extends uvm_sequence_item;
   rand logic [31:0] data_r;
   logic intr_in = 0;
   logic mem_pause = 0;

   rand logic [31:2] address_next;
   rand logic [3:0] byte_we_next;
   rand logic [31:2] address;
   rand logic [3:0] byte_we;
   rand logic [31:0] data_w;
   rand int delay;

   constraint timing {delay inside {[0:5]};}

   `uvm_object_utils_begin(data_packet)
      `uvm_field_int(data_r, UVM_DEFAULT)
      `uvm_field_int(intr_in, UVM_DEFAULT)
      `uvm_field_int(mem_pause, UVM_DEFAULT)
      `uvm_field_int(address_next, UVM_DEFAULT)
      `uvm_field_int(byte_we_next, UVM_DEFAULT)
      `uvm_field_int(address, UVM_DEFAULT)
      `uvm_field_int(byte_we, UVM_DEFAULT)
      `uvm_field_int(data_w, UVM_DEFAULT)
      `uvm_field_int(delay, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name = "data_packet");
      super.new(name);
   endfunction: new

   virtual task displayAll( );
      `uvm_info("DP", $sformatf("data_r = %0h intr_in = %0h mem_pause = %0h address_next = %0h byte_we_next = %0h address = %0h byte_we = %0h data_w = %0h", data_r, intr_in, mem_pause, address_next, byte_we_next, address, byte_we, data_w), UVM_LOW)
   endtask: displayAll

endclass: data_packet
