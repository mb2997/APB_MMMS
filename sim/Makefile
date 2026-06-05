#Makefile
TB=../top/apb_top.sv
TBModule=apb_top
PKG=../test/apb_pkg.sv
DEFS=../top/apb_defs.sv

help:
	@echo =================================================================================
	@echo " lib   		=>  Make work directory"                            			
	@echo " cmp   		=>  Compile the whole code"
	@echo " sim    		=>  Simulate and run the code"
	@echo " all    		=>  Run above all targets sequencially"
	@echo " tc1    		=>  Run TESTCASE-1 for back-to-back Read-Write"
	@echo " tc2    		=>  Run TESTCASE-2 for multiple Read-Write"
	@echo " tc3    		=>  Run TESTCASE-3 for MSB-to-LSB Data Transaction"
	@echo " tc3    		=>  Run TESTCASE-4 for LSB-to-MSB Data Transaction"
	@echo =================================================================================

clean:
	del /Q transcript work
lib :
	vlib work
	
cmp :
	vlog -coveropt 3 +acc +cover $(DEFS) $(PKG) $(TB) +incdir+../env +incdir+../test +incdir+../master_agent +incdir+../slave_agent

sim :
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_VERBOSITY=UVM_NONE

all : clean lib cmp sim

run-tc1 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_low_addr_range_test

run-tc2 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_high_addr_range_test

run-tc3 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_mid_reset_test

run-tc4 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_pready_wait_timeout_test

run-tc5 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_high_data_range_test

run-tc6 : 
	vsim -vopt $(TBModule) -c -do "run -all; exit" +UVM_TESTNAME=apb_low_data_range_test

tc1 : lib cmp run-tc1

tc2 : lib cmp run-tc2

tc3 : lib cmp run-tc3

tc4 : lib cmp run-tc4

tc5 : lib cmp run-tc5

tc6 : lib cmp run-tc6