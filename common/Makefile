
# Create a list of files for Irun
IRUN_FILES = $(EDGE_ROOT)/common/EDGE_sim.v ./test/mlite_cpu_syn.v ./test/mlite_cpu_dc.v


irun :
	@irun -incdir ./tb -incdir ./test -sv -access rw -uvmhome CDNS-1.1d +UVM_TESTNAME=many_random_test $(IRUN_FILES) ./tb/edge_if.sv ./tb/top.sv -timescale 1ns/1ps

irun-gui :
	@irun -incdir ./tb -incdir ./test -sv -access rw -uvmhome CDNS-1.1d -gui +UVM_TESTNAME=many_random_test $(IRUN_FILES) ./tb/edge_if.sv ./tb/top.sv -timescale 1ns/1ps

