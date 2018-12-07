module `fifo
  #( parameter       FD = 4     ,  // fifo depth
     parameter       DW = `DW    ,  // data width
     parameter       SD = 2     ,  // brute-force synchronizer depth
     parameter       W  = `W   ,  // Writing protocol "S": Synchronous, "A": Asynchronous
     parameter       R  = `R   )  // Reading protocol "S": Synchronous, "A": Asynchronous
   ( input               rst    ,  // global reset
     // databus
     input      [DW-1:0] dIn    ,  // data in
     output reg [DW-1:0] dOut   ,  // data out
     // write interface
     input               wClk   ,  // SYNC      : write clock (connect to 1'b0 for ASYNC)
     input               wReq   ,  // SYNC/ASYNC: write request
     output reg          wAck   ,  // ASYNC     : write acknowledge
     output              spaceAv,  // SYNC      : space available / ready to be written
     // read interface
     input               rClk   ,  // SYNC      : read clock (connect to 1'b0 for ASYNC)
     input               rReq   ,  // SYNC/ASYNC: read request
     output reg          rAck   ,  // ASYNC     : read acknowledge
     output wire         dValid ); // SYNC      : data valid  / ready to read

  integer       i , j;
  genvar        gi,gj;
  reg  [DW-1:0] data_latch [0:FD-1];
  reg  [FD-1:0] wVac;
  reg  [FD-1:0] rVac;
  wire [FD-1:0] wVac_next = {wVac[FD-2:0],!wVac[FD-1]};
  wire [FD-1:0] rVac_next = {rVac[FD-2:0],!rVac[FD-1]};
  wire [FD-1:0] wStg = wVac_next ^ wVac;
  wire [FD-1:0] rStg = rVac_next ^ rVac;
  reg  [SD-1:0] fSync [FD-1:0];
  reg  [SD-1:0] eSync [FD-1:0];
  reg  [FD-1:0] e; always @* for (i=0;i<FD;i=i+1) e[i] = ((W=="S") ? eSync[i][SD-1] : rVac[i]) ~^ wVac[i];
  reg  [FD-1:0] f; always @* for (i=0;i<FD;i=i+1) f[i] = ((R=="S") ? fSync[i][SD-1] : wVac[i]) ^ rVac[i];
  wire [FD-1:0] w = e & ((W=="S") ? {FD{wReq}} : (wStg & {(FD/2){!wReq,wReq}}) );
  wire [FD-1:0] r = f & ((R=="S") ? {FD{rReq}} : (rStg & {(FD/2){!rReq,rReq}}) );
  wire wAck_flip = (W=="A") ? ~|w : 1'b0;
  wire rAck_flip = (R=="A") ?  |r : 1'b0;  
  
  // and/or tree for output selection
  reg [DW-1:0] dOut_prev;
  always @* begin
    dOut_prev = {DW{1'b0}};
    for (i=0;i<FD;i=i+1)
      dOut_prev = dOut_prev | (data_latch[i] & {DW{rStg[i]}});
  end

  assign spaceAv = (W=="S") ?  |e : 1'b0;
  assign dValid  = (R=="S") ?  |f : 1'b0;

  generate
    // generate for all stages
    for (gi=0;gi<FD;gi=gi+1) begin:stage
      if (W=="S") begin:syncWriteStage
        // sync write vacancy ring
        always@(posedge wClk, posedge rst) if (rst) wVac[gi]  <= 1'b0; else if (w[gi]) wVac[gi] <= wVac_next[gi];
        // write synchronizer
        always@(posedge wClk, posedge rst) if (rst) eSync[gi] <= {SD{1'b0}}; else eSync[gi] <= {eSync[gi][SD-2:0],rVac[gi]};
      end
      if (W=="A") begin:asyncWriteStage
        // async write vacancy ring
        always@(rst, w[gi], wVac_next[gi]) if (rst) wVac[gi]  <= 1'b0; else if (w[gi]) wVac[gi] <= wVac_next[gi];
      end
      if (R=="S") begin:syncReadStage
        // sync read vacancy ring
        always@(posedge rClk, posedge rst) if (rst) rVac[gi]  <= 1'b0; else if (r[gi]) rVac[gi] <= rVac_next[gi];
        // read synchronizer
        always@(posedge rClk, posedge rst) if (rst) fSync[gi] <= {SD{1'b0}}; else fSync[gi] <= {fSync[gi][SD-2:0],wVac[gi]};
      end
      if (R=="A") begin:asyncReadStage
        // async write vacancy ring
        always@(rst, r[gi], rVac_next[gi]) if (rst) rVac[gi]  <= 1'b0; else if (r[gi]) rVac[gi] <= rVac_next[gi];
      end
      // latch input data
      always@(e[gi], dIn) if (e[gi]) data_latch[gi] <= dIn;
    end

    // generate once
    if (R=="A") begin:asyncRead
      // dOut flop
      always@(posedge rAck_flip) dOut <= dOut_prev;
      // flip rAck (2-phase) on rising edge of rAck_flip
      always@(posedge rAck_flip, posedge rst) if (rst) rAck <= 1'b0; else rAck <= !rAck;
    end
    if (R=="S") begin:syncRead
      // dOut flop
      always@(posedge rClk) if (rReq && dValid) dOut <= dOut_prev;
      // rAck is unused
      always @* rAck = 1'b0;
    end
    if (W=="A") begin:asyncWrite
      // flip wAck (2-phase) on rising edge of wAck_flip
      always@(posedge wAck_flip, posedge rst) if (rst) wAck <= 1'b0; else wAck <= !wAck;  
    end
    if (W=="S") begin:syncWrite
      // wAck is unused
      always @* wAck = 1'b0;
    end
  endgenerate

endmodule
