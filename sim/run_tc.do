set TESTNAME "$1"
echo TESTNAME
vlog ../TEST/apb_pkg.sv ../TOP/apb_top.sv +incdir+../ENV +incdir+../TEST
vsim -novopt apb_top +UVM_TESTNAME=$TESTNAME
run 0ns
log -r /uvm_root/*
do wave.do
run -all