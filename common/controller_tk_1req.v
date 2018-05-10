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


module dff_clk_tk (reset, clk, dff_out);
input reset, clk;
output dff_out;
reg dff_con;
wire dff_out;
assign dff_out = dff_con;
always@(posedge clk, posedge reset)
begin
	if(reset)
		dff_con <= 1;
	else
	begin
		dff_con <= ~dff_con;
	end
end

endmodule

module controller_tk_1req (reset, a_req, a_ack, b_req, b_ack, dff_clk);
input reset, a_req, b_ack;
output a_ack, b_req, dff_clk; 
wire a_ack_buf;
//reg dff_con;
wire dff_con;
wire dff_clk_buf;
wire dff_clk_con;
wire connection;
wire break1, break2;
dummy_buffer CTDBUF (dff_con,a_ack_buf);
dummy_buffer BREAK1 (a_ack_buf,break1);
dummy_buffer BREAK2 (break1,break2);

assign dff_clk_buf = a_req & break2 & b_ack | (~a_req & ~break2 & ~b_ack);
assign dff_clk = dff_clk_buf;
assign a_ack =~a_ack_buf;

assign b_req = ~reset & dff_con;
assign dff_clk_con = dff_clk_buf ;
//assign a_ack_buf = dff_con;
//delayline CTDL (dff_con,a_ack_buf);

//always@(posedge dff_clk_con, posedge reset)
//begin
//	if(reset)
//		dff_con <= 1;
//	else
//	begin
//		dff_con <= ~dff_con;
//	end
//end
dff_clk_tk dff_tk(.reset(reset), .clk(dff_clk_con), .dff_out(dff_con));

//r2hd_ln30_invfc myinv1(.nz(connection[0]), .a(dff_con));
//r2hd_ln30_invfc myinvn(.nz(b_req), .a(connection[22]));	
endmodule
