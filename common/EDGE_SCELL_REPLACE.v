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
wire CPbar, mO, muxO, sI, sO;
wire TQ,QN,Q;
//-------------Code Starts Here---------
assign CPbar = ~CP;
assign muxO = TE? mO:D;
assign sI = muxO || (~SN);
assign Q = sO || (~SN);
assign TQ=Q;
assign QN=~Q;

DLATCH scanM (.in(TI), .en(CPbar), .out(mO));
DLATCH scanS (.in(sI), .en(CP), .out(sO));
endmodule

///////////////////////////
// EDGE_SCELL_R_sub
///////////////////////////
module EDGE_SCELL_R_sub (D,TI,TE,CP,RN,TQ,QN);
input D, TI, TE, CP, RN;
output TQ,QN;
wire CPbar, mO, muxO, sI, sO;
wire TQ,QN,Q;
//-------------Code Starts Here---------
assign CPbar = ~CP;
assign muxO = TE? mO:D;
assign sI = muxO && (RN);
assign Q = sO && (RN);
assign TQ=Q;
assign QN=~Q;

DLATCH scanM (.in(TI), .en(CPbar), .out(mO));
DLATCH scanS (.in(sI), .en(CP), .out(sO));
endmodule

module EDGE_SCELL_S (D,TI,TE,CP,SN,TQ,QN,en);
input D, TI, TE, CP, SN, en;
output TQ,QN;
wire qnBuf;
EDGE_SCELL_S_sub myScan(.D(D),.TI(TI),.TE(TE),.CP(CP),.SN(SN),.TQ(TQ),.QN(qnBuf));
DLATCH myS_D(.in(qnBuf), .en(en), .out(QN));
endmodule

module EDGE_SCELL_R (D,TI,TE,CP,RN,TQ,QN,en);
input D, TI, TE, CP, RN, en;
output TQ,QN;
wire qnBuf;
EDGE_SCELL_R_sub myScan(.D(D),.TI(TI),.TE(TE),.CP(CP),.RN(RN),.TQ(TQ),.QN(qnBuf));
DLATCH myR_D(.in(qnBuf), .en(en), .out(QN));


endmodule