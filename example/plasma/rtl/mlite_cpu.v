module mlite_cpu(clk, reset_in, din, dout); 
input clk, reset_in;
input [15:0]din;
output [15:0]dout;
reg [15:0]ff;
// dout[15:8] : sync reset [7:0]: async reset
assign dout[15:8] = ff[15:8];
assign dout[7:0] = ff[7:0];

always@(posedge clk)
begin
	if(reset_in == 1)
	begin
		ff[15:8] = 0;
	end
	else
	begin
		ff[15:8] = din[15:8]+ff[7:0];
	end
end
always@(posedge clk or posedge reset_in)
begin
	if(reset_in == 1)
	begin
		ff[7:0] = 0;
	end
	else
	begin
		ff[7:0] = din[7:0]+ff[15:8];
	end
end

	
endmodule
