import os
import sys

TB="../TOP/apb_top.sv"
TBModule="apb_top"
PKG="../TEST/apb_pkg.sv"

##Testcases List
TC1="apb_low_addr_range_test"
TC2="apb_high_addr_range_test"
TC3="apb_mid_reset_test"
TC4="apb_pready_wait_timeout_test"
TC5="apb_high_data_range_test"
TC6="apb_low_data_range_test"

repeat_test_counts = int(input("\nHowmany times you want to run each test in regression?"))
delete_prev_logs = int(input("\nDo you want to delete previous coverage files?\n 1 - YES :::: 2 - NO"))

if (delete_prev_logs == 1) :
    os.system('del *.ucdb')

os.system('vlib work')
os.system('vlog -coveropt 3 +acc +cover '+PKG+' '+TB+' +incdir+../ENV +incdir+../TEST')

for i in range(0,repeat_test_counts) :
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC1+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC1)
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC2+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC2)
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC3+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC3)
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC4+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC4)
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC5+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC5)
    os.system('vsim -coverage -novopt '+TBModule+' -sv_seed random -c -do "coverage save -onexit '+TC6+'_'+str(i)+'.ucdb; run -all; exit" +UVM_TESTNAME='+TC6)
    os.system('vcover merge mergecov_'+str(i)+'.ucdb '+TC1+'_'+str(i)+'.ucdb '+TC2+'_'+str(i)+'.ucdb '+TC3+'_'+str(i)+'.ucdb '+TC4+'_'+str(i)+'.ucdb '+TC5+'_'+str(i)+'.ucdb '+TC6+'_'+str(i)+'.ucdb')
    
    ##add 1st iteration merge coverage to mergecov.ucdb (if part), then merge each iteration coverage with it (else part)
    if(i == 0) :
        os.system('vcover merge mergecov.ucdb mergecov_0.ucdb')
    else :
        os.system('vcover merge mergecov.ucdb mergecov.ucdb mergecov_'+str(i)+'.ucdb')

os.system('vcover report -details -html mergecov.ucdb')


    



