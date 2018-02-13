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





module ctrl_path (a_req,a_ack,b_req,b_ack,reset,clk1,clk2);

input a_req,b_ack,reset;
output a_ack,b_req,clk1,clk2;
wire a_ack,b_req,clk1,clk2;
wire s1_a_req, s1_a_ack, s1_b_req, s1_b_ack;
wire s2_a_req, s2_a_ack, s2_b_req, s2_b_ack;
wire CELE_req_a,CELE_req_b;

assign a_ack=s1_a_ack;

assign CELE_req_a=a_req;
assign CELE_req_b=s2_b_req;
assign s2_a_req=s1_b_req;
assign s1_b_ack=s2_a_ack;
dummy_buffer b_req_BUF (s2_b_req,b_req);

controller_notk_1req CTRL1 (reset, s1_a_req, s1_a_ack, s1_b_req, s1_b_ack, clk1);
controller_tk_1req   CTRL2 (reset, s2_a_req, s2_a_ack, s2_b_req, s2_b_ack, clk2);
//delayline DL_in_s1 (a_req,CELE_req_b);
//delayline DL_s1_s2 (s1_b_req,s2_a_req);
//delayline DL_s2_s1 (s2_b_req,CELE_req_a);
//delayline DL_s2_out (s2_b_req,b_req);
c_element CELE_req (CELE_req_a,CELE_req_b,s1_a_req);
c_element CELE_ack (s1_a_ack,b_ack,s2_b_ack);
endmodule

