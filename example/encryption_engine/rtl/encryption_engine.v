//////////////////////////////////
// Top level of encrytion engine//
// By Gourav and Yang           //
//////////////////////////////////

module encryption_engine ( input [63:0] input_final, 
                           input [167:0] key,
						   input [5:0] roundSel,
                           input [1:0] sel,
						   input clk, 
						   input reset,
						   input decrypt_i,
						   input key_load,
						   input data_load,
						   input i_op,
						   input i_post_rdy,
						   output ready_done,
						   output [63:0] output_final,					   
						   output  ready_o);	

// Interface with S2A: 64+168+6+2+5=245
// Interface with A2S: 1+64+1 = 66
						   

//Keys for 3 cores
reg [167:0] key_reg;
 wire [55:0] key1;
 wire [55:0] key2;
 wire [55:0] key3;
 wire [127:0] key4;
 wire [15:0] key5;
 // assign key values
assign key1 = key_reg[55:0];
assign key2 = key_reg[111:56];
assign key3 = key_reg[167:112]; 
assign key4 = key_reg[127:0];
assign key5 = key_reg[15:0];
//other regs to cores
	reg [5:0] roundSel_reg;
	reg decrypt_i_reg;
	reg key_load_reg;
	reg data_load_reg;
	reg i_op_reg;
	reg i_post_rdy_reg;				   
					

wire [63:0] output_i, output_j, output_k;
reg [63:0] input_i, input_j, input_k;
assign output_final = (sel == 2'd0)? output_i : (sel == 2'd1) ? output_j : output_k; 
always @(posedge clk, posedge reset) begin
	if (reset) begin
		input_i <= 0;
		input_j	<= 0;
		input_k <= 0;
		key_reg <=0;
		
		roundSel_reg <=0;
		decrypt_i_reg <=0;
		key_load_reg <=0;
		data_load_reg <=0;
		i_op_reg <=0;
		i_post_rdy_reg <=0;	
	end
	else begin
		key_reg <= key;
		roundSel_reg <=roundSel;
		decrypt_i_reg <=decrypt_i;
		key_load_reg <=key_load;
		data_load_reg <=data_load;
		i_op_reg <=i_op;
		i_post_rdy_reg <=i_post_rdy;	
		if (sel == 2'd0)
			{input_i, input_j, input_k} <= {input_final, 64'bx, 64'bx};
		else if (sel == 2'd1)
			{input_i, input_j, input_k} <= { 64'bx,input_final, 64'bx};
		else if (sel == 2'd2)
			{input_i, input_j, input_k} <= { 64'bx, 64'bx,input_final};
		else
			{input_i, input_j, input_k} <= 192'bx;
	end
end




//Three cores

des3 des_o(output_i, input_i, key1, key2, key3, decrypt_i, roundSel, clk);
present_encryptor_top present_o(output_j, {input_j, key5}, data_load, key_load, clk);
HIGHT_CORE_TOP hight_o(~reset, clk, key_load, key4, i_post_rdy, i_op, data_load, input_k, ready_done, output_k, ready_o);
endmodule


