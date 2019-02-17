Set Environmental Varibles:
setenv EDGE_ROOT /The/path/to/Edge (where you save the software/EDGE) 
set path=($path $EDGE_ROOT/bin) 

Modify technology settings and design specific parameters in tech.tcl and design.tcl respectively. 

Commands to run the code 
	edge -t task_name [-e] [-d design.tcl] [-k tech.tcl] -[l filelist.tcl] [-f] [-b]

ARGUMENTS
	-t task_name 	
		Specify which task EDGE 1.0.2 runs, possible tasks are: sync_syn, ff2latch, retiming, bd_conv, dc, icc.
	-e 	
		It's optional. If you specify this, the flow will run for the example plasma design.
	-d /path/to/customer's/design.tcl 
		It's optional. It specifies where the design.tcl locates. If you don't specify it, edge will use the design.tcl in folder Edge1.0.2->example->plasma->design.tcl. It is ignored if "-l" is specified.
	-k /path/to/customer's/tech.tcl 
		It's optional. Specifies where the tech.tcl locates. If you don't specify it, edge will use the tech.tcl in folder Edge1.0.2->example->plasma->tech.tcl.
	-f	
		It's optional. If you specify this, the flow will overwrite previous results.
	-l /path/to/customer's/filelist.tcl
		It's optional. Specifies where the filelist.tcl locates. If you don't specify it, edge will use the tech.tcl in folder Edge1.0.2->example->plasma->filelist.tcl. This file is for the design synthesis. 
	-b
		It's optional. It is used to debug. If you specify this, the flow will not exit dc_shell automatically. 

Note: This version includes controller constraints. Reset bug during retiming is fixed. PnR in this version works.
Note: Programmable delay line is also supported. Please see two sample delaylines under example->plasma->tcl folder
