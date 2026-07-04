import os
import sys

TB="../top/apb_top.sv"
TBModule="apb_top"
PKG="../test/apb_pkg.sv"
DEFS="../top/apb_defs.sv"

##Testcases List
TC1="apb_single_slave_rand_rw_test"
TC2="apb_single_slave_min_max_mid_addr_test"
TC3="apb_multi_slave_rand_rw_test"
TC4="apb_multi_slave_min_max_mid_addr_test"
TC5="apb_multi_slave_raw_test"
TC6="apb_multi_slave_b2b_rw_test"
TC7="apb_min_pready_test"
TC8="apb_max_pready_test"
TC9="apb_multi_slave_pwdata_corner_rw_test"

test_list = [TC1, TC2, TC3, TC4, TC5, TC6, TC7, TC8, TC9]

repeat_test_counts = int(input("\nHow many times you want to run each test in regression? "))
delete_prev_logs = int(input("\nDo you want to delete previous coverage files?\n1 - YES\n2 - NO\n"))

if delete_prev_logs == 1:
    os.system('del /S /Q results\\*.ucdb')
    os.system('del *.ucdb')

os.system('vlib work')
os.system('vlog -coveropt 3 +acc +cover ' + PKG + ' ' + TB + ' +incdir+../ENV +incdir+../TEST')

for testcase in test_list:

    os.system('mkdir results\\' + testcase)

    for i in range(repeat_test_counts):

        os.system(
            'vsim -coverage -vopt ' + TBModule +
            ' -sv_seed random -c -do "coverage save -onexit results/' +
            testcase + '/' + testcase + '_' + str(i) +
            '.ucdb; run -all; exit" +UVM_TESTNAME=' + testcase
        )

        os.system(
            'vcover merge mergecov.ucdb mergecov.ucdb results/' +
            testcase + '/' + testcase + '_' + str(i) + '.ucdb'
        )

os.system('vcover report -details -html mergecov.ucdb')