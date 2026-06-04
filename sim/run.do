vlog -coveropt 3 +acc +cover ../TEST/apb_pkg.sv ../TOP/apb_top.sv +incdir+../env +incdir+../test +incdir+../master_agent +incdir+../slave_agent
vsim -vopt apb_top
run 0ns
log -r /uvm_root/*
do wave.do
run -all