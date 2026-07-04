# =============================================================================
# Makefile — APB UVM Testbench
# =============================================================================

TB       = ../top/apb_top.sv
TBModule = apb_top
PKG      = ../test/apb_pkg.sv
DEFS     = ../top/apb_defs.sv

# COUNT — number of iterations per testcase during regression
# Pass on command line: make regression COUNT=10
# Leave at 0 to trigger the interactive prompt [ask the user to type a number]
COUNT ?= 0

# All testcases — adding a new test means adding one line here only
TESTS = apb_single_slave_rand_rw_test \
        apb_single_slave_min_max_mid_addr_test \
		apb_multi_slave_rand_rw_test \
        apb_multi_slave_min_max_mid_addr_test \
        apb_multi_slave_raw_test \
        apb_multi_slave_b2b_rw_test \
        apb_min_pready_test \
        apb_max_pready_test

# =============================================================================
# Help
# =============================================================================
help:
	@echo ===========================================================================
	@echo "  lib                =>  Create work library"
	@echo "  cmp                =>  Compile all sources"
	@echo "  sim                =>  Simulate default testbench, dumps .ucdb"
	@echo "  all                =>  clean + lib + cmp + sim"
	@echo "  tc1 .. tc8         =>  Run individual testcase once, dumps .ucdb"
	@echo "  regression         =>  Run ALL testcases N times (prompts for N)"
	@echo "                         or: make regression COUNT=5"
	@echo "  regression-tc1..8  =>  Run one testcase N times (prompts for N)"
	@echo "                         or: make regression-tc1 COUNT=5"
	@echo "  merge-coverage     =>  Merge all .ucdb files into results\merged.ucdb"
	@echo "  cov-report         =>  Generate text report from results\merged.ucdb"
	@echo "  cov-regression     =>  regression + merge + report in one command"
	@echo "                         or: make cov-regression COUNT=5"
	@echo ===========================================================================

# =============================================================================
# Core targets
# =============================================================================
clean:
	del transcript
	if exist results rmdir /s /q results

lib:
	vlib work

cmp:
	vlog -coveropt 3 +acc +cover $(DEFS) $(PKG) $(TB) +incdir+../env +incdir+../test +incdir+../master_agent +incdir+../slave_agent

# Default sim — no specific testname, still dumps [saves] a .ucdb
sim:
	@if not exist results mkdir results
	@if not exist results\default mkdir results\default
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/default/default.ucdb; run -all; exit"

all: clean lib cmp sim

# =============================================================================
# Individual testcase run targets — each dumps its own .ucdb
# -sv_seed random  => different seed every run for better randomisation
# -coverage        => enables functional + code coverage collection
# -coverstore      => folder where QuestaSim stores the coverage database
# coverage save -onexit => flushes [writes] the .ucdb even on abrupt exit
# =============================================================================
run-tc1:
	@if not exist results mkdir results
	@if not exist results\tc1 mkdir results\tc1
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc1/tc1.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_single_slave_rand_rw_test

run-tc2:
	@if not exist results mkdir results
	@if not exist results\tc2 mkdir results\tc2
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc2/tc2.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_multi_slave_test

run-tc3:
	@if not exist results mkdir results
	@if not exist results\tc3 mkdir results\tc3
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc3/tc3.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_single_slave_min_max_mid_addr_test

run-tc4:
	@if not exist results mkdir results
	@if not exist results\tc4 mkdir results\tc4
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc4/tc4.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_multi_slave_min_max_mid_addr_test

run-tc5:
	@if not exist results mkdir results
	@if not exist results\tc5 mkdir results\tc5
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc5/tc5.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_multi_slave_raw_test

run-tc6:
	@if not exist results mkdir results
	@if not exist results\tc6 mkdir results\tc6
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc6/tc6.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_multi_slave_b2b_rw_test

run-tc7:
	@if not exist results mkdir results
	@if not exist results\tc7 mkdir results\tc7
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc7/tc7.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_min_pready_test

run-tc8:
	@if not exist results mkdir results
	@if not exist results\tc8 mkdir results\tc8
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc8/tc8.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_max_pready_test

run-tc9:
	@if not exist results mkdir results
	@if not exist results\tc9 mkdir results\tc9
	vsim -vopt $(TBModule) -c \
	    -sv_seed random \
	    -coverage \
	    -do "coverage save -onexit results/tc9/tc9.ucdb; run -all; exit" \
	    +UVM_TESTNAME=apb_multi_slave_pwdata_corner_rw_test

tc1: clean lib cmp run-tc1
tc2: clean lib cmp run-tc2
tc3: clean lib cmp run-tc3
tc4: clean lib cmp run-tc4
tc5: clean lib cmp run-tc5
tc6: clean lib cmp run-tc6
tc7: clean lib cmp run-tc7
tc8: clean lib cmp run-tc8
tc9: clean lib cmp run-tc9

# =============================================================================
# Internal single-run workhorse [the target that does the actual heavy lifting]
# Called by both regression and single-test regression loops.
# TEST and N must be passed: $(MAKE) _single-run TEST=apb_foo_test N=3
# Seed = iteration number so a failing run is exactly reproducible [can be
# re-run identically] by calling _single-run with the same N value.
# =============================================================================
_single-run:
	@echo --- $(TEST) : iteration $(N) ---
	@if not exist results\$(TEST)_run$(N) mkdir results\$(TEST)_run$(N)
	vsim -vopt $(TBModule) -c \
	    -sv_seed $(N) \
	    -coverage \
	    -do "coverage save -onexit results/$(TEST)_run$(N)/$(TEST)_run$(N).ucdb; run -all; exit" \
	    +UVM_TESTNAME=$(TEST) \
	    | tee results\$(TEST)_run$(N)\sim.log

# =============================================================================
# REGRESSION — runs ALL testcases COUNT times each
#
# Usage:
#   make regression            <- prompts [asks interactively] for count
#   make regression COUNT=5    <- runs all 8 testcases 5 times = 40 total runs
# =============================================================================
regression: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations per testcase: " && \
	$(MAKE) _run-regression COUNT=!USER_COUNT!
else
	@$(MAKE) _run-regression COUNT=$(COUNT)
endif

_run-regression:
	@echo ===========================================================================
	@echo   Starting regression : $(COUNT) iteration(s) x 8 testcases
	@echo ===========================================================================
	@if not exist results mkdir results
	$(foreach TEST,$(TESTS), \
	    $(foreach N,$(shell powershell -command "1..$(COUNT)"), \
	        $(MAKE) _single-run TEST=$(TEST) N=$(N) ; \
	    ) \
	)
	@echo ===========================================================================
	@echo   Regression complete. Logs at results\<testname>_run<N>\sim.log
	@echo ===========================================================================

# =============================================================================
# SINGLE-TEST REGRESSION — runs one specific testcase COUNT times
#
# Usage:
#   make regression-tc1            <- prompts for count
#   make regression-tc1 COUNT=10   <- runs tc1 ten times
# =============================================================================
regression-tc1: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_single_slave_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_single_slave_test COUNT=$(COUNT)
endif

regression-tc2: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_multi_slave_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_multi_slave_test COUNT=$(COUNT)
endif

regression-tc3: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_single_slave_min_max_mid_addr_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_single_slave_min_max_mid_addr_test COUNT=$(COUNT)
endif

regression-tc4: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_multi_slave_min_max_mid_addr_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_multi_slave_min_max_mid_addr_test COUNT=$(COUNT)
endif

regression-tc5: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_multi_slave_raw_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_multi_slave_raw_test COUNT=$(COUNT)
endif

regression-tc6: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_multi_slave_b2b_rw_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_multi_slave_b2b_rw_test COUNT=$(COUNT)
endif

regression-tc7: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_min_pready_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_min_pready_test COUNT=$(COUNT)
endif

regression-tc8: clean lib cmp
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations: " && \
	$(MAKE) _run-single-test-regression TEST=apb_max_pready_test COUNT=!USER_COUNT!
else
	@$(MAKE) _run-single-test-regression TEST=apb_max_pready_test COUNT=$(COUNT)
endif

_run-single-test-regression:
	@echo ===========================================================================
	@echo   Running $(TEST) for $(COUNT) iteration(s)
	@echo ===========================================================================
	$(foreach N,$(shell powershell -command "1..$(COUNT)"), \
	    $(MAKE) _single-run TEST=$(TEST) N=$(N) ; \
	)
	@echo Done. Logs at results\$(TEST)_run*\sim.log

# =============================================================================
# COVERAGE MERGE — combines [brings together] all individual .ucdb files
# into one unified database after regression is complete
# =============================================================================
merge-coverage:
	@echo ===========================================================================
	@echo   Merging all .ucdb files into results\merged.ucdb ...
	@echo ===========================================================================
	vcover merge results\merged.ucdb results\*\*.ucdb
	@echo Merged database saved to results\merged.ucdb

# =============================================================================
# COVERAGE REPORT — generates a human-readable [easy to read] text report
# from the merged .ucdb database
# =============================================================================
cov-report: merge-coverage
	@echo ===========================================================================
	@echo   Generating coverage report ...
	@echo ===========================================================================
	vcover report -details -output results\coverage_report.txt results\merged.ucdb
	@echo Coverage report written to results\coverage_report.txt

# =============================================================================
# COVERAGE REGRESSION — one command that does everything:
#   clean -> lib -> cmp -> regression -> merge -> report
#
# Usage:
#   make cov-regression            <- prompts for iteration count
#   make cov-regression COUNT=5    <- runs without prompting
# =============================================================================
cov-regression:
ifeq ($(COUNT),0)
	@set /p USER_COUNT="Enter number of iterations per testcase: " && \
	$(MAKE) _run-cov-regression COUNT=!USER_COUNT!
else
	@$(MAKE) _run-cov-regression COUNT=$(COUNT)
endif

_run-cov-regression: clean lib cmp
	@echo ===========================================================================
	@echo   COVERAGE REGRESSION STARTED : $(COUNT) iteration(s) x 8 testcases
	@echo ===========================================================================
	@$(MAKE) _run-regression COUNT=$(COUNT)
	@echo ===========================================================================
	@echo   All simulation runs done. Merging coverage databases ...
	@echo ===========================================================================
	@$(MAKE) merge-coverage
	@echo ===========================================================================
	@echo   Generating coverage report ...
	@echo ===========================================================================
	@$(MAKE) cov-report
	@echo ===========================================================================
	@echo   COVERAGE REGRESSION COMPLETE
	@echo   Merged DB      : results\merged.ucdb
	@echo   Report         : results\coverage_report.txt
	@echo   Individual logs: results\<testname>_run<N>\sim.log
	@echo ===========================================================================