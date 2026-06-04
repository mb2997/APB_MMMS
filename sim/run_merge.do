vlib work
vlog ../TEST/apb_pkg.sv ../TOP/apb_top.sv +incdir+../ENV +incdir+../TEST
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc1cov.ucdb; run -all" +UVM_TESTNAME=apb_rw_b2b_tc1
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc2cov.ucdb; run -all" +UVM_TESTNAME=apb_rw_tc2
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc3cov.ucdb; run -all" +UVM_TESTNAME=apb_msb_lsb_tc3
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc4cov.ucdb; run -all" +UVM_TESTNAME=apb_lsb_msb_tc4
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc5cov.ucdb; run -all" +UVM_TESTNAME=apb_high_raddr_tc5
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc6cov.ucdb; run -all" +UVM_TESTNAME=apb_low_raddr_tc6
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc7cov.ucdb; run -all" +UVM_TESTNAME=apb_low_rdata_tc7
vsim -coverage -novopt apb_top -c -do "coverage save -onexit tc8cov.ucdb; run -all" +UVM_TESTNAME=apb_high_rdata_tc8

vcover merge mergecov.ucdb tc1cov.ucdb tc2cov.ucdb tc3cov.ucdb tc4cov.ucdb tc5cov.ucdb tc6cov.ucdb tc7cov.ucdb tc8cov.ucdb
vcover report -details -html mergecov.ucdb 

run 0ns
log -r /uvm_root/*
do wave.do
run -all