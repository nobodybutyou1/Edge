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





class base_test extends uvm_test;
   `uvm_component_utils(base_test)

   dut_env env;
   uvm_table_printer printer;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = dut_env::type_id::create("env", this);
      printer = new( );
      printer.knobs.depth = 5;
   endfunction:build_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      `uvm_info(get_type_name( ), $sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
   endfunction: end_of_elaboration_phase

   virtual task run_phase(uvm_phase phase);
      phase.phase_done.set_drain_time(this, 1500);
   endtask: run_phase

endclass: base_test

class random_test extends base_test;
   `uvm_component_utils(random_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   virtual task run_phase(uvm_phase phase);
      random_sequence seq;

      super.run_phase(phase);
      phase.raise_objection(this);
      seq = random_sequence::type_id::create("seq");
      seq.start(env.penv_in.agent.sequencer);
      phase.drop_objection(this);      
   endtask: run_phase
endclass: random_test

class many_random_test extends base_test;
	`uvm_component_utils(many_random_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase
	
	virtual task run_phase(uvm_phase phase);
		many_random_sequence seq;
		
		super.run_phase(phase);
		phase.raise_objection(this);
		seq = many_random_sequence::type_id::create("seq");
		assert(seq.randomize( ));
		seq.start(env.penv_in.agent.sequencer);
		phase.drop_objection(this);
	endtask: run_phase
endclass: many_random_test
