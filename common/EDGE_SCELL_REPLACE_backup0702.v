`timescale 1ns/10ps
///////////////////////////
// DLATCH
///////////////////////////
module DLATCH (in, en, out);
input in, en; 
output  out;
reg out;
//-------------Code Starts Here---------
always @ ( en or in)
if (en) begin
	out <= in;
end
endmodule 

///////////////////////////
// EDGE_SCELL_S_sub
///////////////////////////
module EDGE_SCELL_S_sub (D,TI,TE,CP,SN,TQ,QN);
input D, TI, TE, CP, SN;
output TQ,QN;
wire d1;
reg q1;
reg TQ;
//-------------Code Starts Here---------
assign d1 = TE? TI:D;
assign QN=~q1;	
always @(posedge CP)
begin
	if(SN == 0)
		q1 <= 1;
	else
		q1 <= d1;
end
always @(CP,q1)
begin
	if (CP == 0)
		TQ = q1;
end
endmodule

///////////////////////////
// EDGE_SCELL_R_sub
///////////////////////////
module EDGE_SCELL_R_sub (D,TI,TE,CP,RN,TQ,QN);
input D, TI, TE, CP, RN;
output TQ,QN;
wire d1;
reg q1;
reg TQ;
//-------------Code Starts Here---------
assign d1 = TE? TI:D;
assign QN=~q1;	
always @(posedge CP)
begin
	if(RN == 0)
		q1 <= 0;
	else
		q1 <= d1;
end
always @(CP,q1)
begin
	if (CP == 0)
		TQ = q1;
end

endmodule

module EDGE_SCELL_S (D,TI,TE,CP,SN,TQ,QN,en);
input D, TI, TE, CP, SN, en;
output TQ,QN;
wire qnBuf;
EDGE_SCELL_S_sub myS_sub(.D(D),.TI(TI),.TE(TE),.CP(CP),.SN(SN),.TQ(TQ),.QN(qnBuf));
DLATCH myS_D(.in(qnBuf), .en(en), .out(QN));
endmodule

module EDGE_SCELL_R (D,TI,TE,CP,RN,TQ,QN,en);
input D, TI, TE, CP, RN, en;
output TQ,QN;
wire qnBuf;
EDGE_SCELL_R_sub myR_sub(.D(D),.TI(TI),.TE(TE),.CP(CP),.RN(RN),.TQ(TQ),.QN(qnBuf));
DLATCH myR_D(.in(qnBuf), .en(en), .out(QN));


endmodule