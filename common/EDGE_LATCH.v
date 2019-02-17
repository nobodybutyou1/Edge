`timescale 1ns/10ps
`celldefine
module LATCH (D, CLK, Q);
input  D ;
input  CLK ;
output Q ;
reg NOTIFIER ;

   udp_tlat (DS0000, D, CLK, 1'B0, 1'B0, NOTIFIER);
   not (P0000, DS0000);
   buf (Q, DS0000);

   specify
     // delay parameters
     specparam
       tpllh$D$Q = 0.2:0.2:0.2,
       tphhl$D$Q = 0.18:0.18:0.18,
       tpllh$CLK$Q = 0.2:0.2:0.2,
       tplhl$CLK$Q = 0.17:0.17:0.17,
       tminpwh$CLK = 0.025:0.11:0.2,
       tsetup_negedge$D$CLK = 0.19:0.19:0.19,
       thold_negedge$D$CLK = 0:0:0,
       tsetup_posedge$D$CLK = 0.19:0.19:0.19,
       thold_posedge$D$CLK = -0.0000000022:-0.0000000022:-0.0000000022;

     // path delays
     if (CLK == 1'b1)
       (CLK *> Q) = (tpllh$CLK$Q, tplhl$CLK$Q);
     (D *> Q) = (tpllh$D$Q, tphhl$D$Q);
     $setup(negedge D, negedge CLK, tsetup_negedge$D$CLK, NOTIFIER);
     $hold (negedge CLK, negedge D, thold_negedge$D$CLK,  NOTIFIER);
     $setup(posedge D, negedge CLK, tsetup_posedge$D$CLK, NOTIFIER);
     $hold (negedge CLK, posedge D, thold_posedge$D$CLK,  NOTIFIER);
     $width(posedge CLK, tminpwh$CLK, 0, NOTIFIER);

   endspecify

endmodule
`endcelldefine
