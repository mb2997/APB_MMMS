`ifndef APB_COVERAGE
`define APB_COVERAGE

class apb_coverage extends uvm_subscriber #(apb_master_trans);

    `uvm_component_utils(apb_coverage)

    apb_master_trans m_trans;
    apb_slave_trans s_trans;

    // =========================================================================
    // Local parameters — all bin boundaries derived [calculated] from macros
    // so they scale automatically when ADDR_WIDTH / DATA_WIDTH / STRB_WIDTH
    // change, and never overflow [exceed] the coverpoint signal width.
    // =========================================================================

    // Address boundaries
    localparam int ADDR_MAX  = (2**`ADDR_WIDTH) - 1;
    localparam int ADDR_Q1_H = ADDR_MAX / 4;
    localparam int ADDR_Q2_H = ADDR_MAX / 2;
    localparam int ADDR_Q3_H = (ADDR_MAX * 3) / 4;

    // Data boundaries — use (2**N)-1 instead of replication {N{1'b1}}
    // because replication is not legal in a localparam on older tools
    localparam int unsigned DATA_MAX  = (2**(`DATA_WIDTH)) - 1;
    localparam int unsigned DATA_MSB  = (2**(`DATA_WIDTH - 1));

    // Strobe boundaries — same reasoning as data
    localparam int STRB_MAX  = (2**`STRB_WIDTH) - 1;   // all bytes enabled e.g. 4'hF
    localparam int STRB_BYTE = 1;                        // byte     m_transfer  e.g. 4'h1
    localparam int STRB_HALF = 3;                        // halfword transfer  e.g. 4'h3

    uvm_tlm_analysis_fifo #(apb_slave_trans) slv_mon2_cov_af[];

    // =========================================================================
    // COVERGROUP
    // =========================================================================
    covergroup apb_master_cg;

        PWRITE  :   coverpoint m_trans.PWRITE
                    {
                        ignore_bins write_op = {1};
                        bins read_op  = {0};
                    }
                        
        PADDR   :   coverpoint m_trans.PADDR
                    {
                        bins addr_low = {[0           : ADDR_Q1_H]};
                        bins addr_mid1 = {[ADDR_Q1_H+1 : ADDR_Q2_H]};
                        bins addr_mid2 = {[ADDR_Q2_H+1 : ADDR_Q3_H]};
                        bins addr_max = {[ADDR_Q3_H+1 : ADDR_MAX]};
                    }

        PRDATA  :   coverpoint m_trans.PRDATA 
                    {
                        bins all_zeros = {0};
                        bins all_ones  = {DATA_MAX};
                        bins msb_only  = {DATA_MSB};
                        bins lsb_only  = {1};
                        bins other     = default;
                    }

        PSLVERR :   coverpoint m_trans.PSLVERR
                    {
                        bins no_error = {0};
                        bins error    = {1};
                    }

        PREADY  :   coverpoint m_trans.PREADY
                    {
                        bins immediate = {1};
                        ignore_bins stalled = {0};
                    }

        cx_dir_ready : cross PWRITE, PREADY;
        cx_addr_dir : cross PADDR, PWRITE;

    endgroup
    
    covergroup apb_slave_cg;

        PWRITE  :   coverpoint s_trans.PWRITE 
                    {
                        bins write_op = {1};
                        bins read_op  = {0};
                    }
        
        PENABLE :   coverpoint s_trans.PENABLE 
                    {
                        bins access_phase = {1};
                    }
                        
        NO_OF_SLAVES    :   coverpoint s_trans.no_of_slaves
                    {
                        bins four_slave_selected = {4};
                        bins three_slave_selected = {3};
                        bins two_slave_selected = {2};
                        bins one_slave_selected = {1};
                    }

        PADDR   :   coverpoint s_trans.PADDR
                    {
                        bins addr_low = {[0           : ADDR_Q1_H]};
                        bins addr_mid1 = {[ADDR_Q1_H+1 : ADDR_Q2_H]};
                        bins addr_mid2 = {[ADDR_Q2_H+1 : ADDR_Q3_H]};
                        bins addr_max = {[ADDR_Q3_H+1 : ADDR_MAX]};
                    }

        PWDATA  :   coverpoint s_trans.PWDATA
                    {
                        bins all_zeros = {0};
                        bins all_ones  = {DATA_MAX};
                        bins msb_only  = {DATA_MSB};
                        bins lsb_only  = {1};
                        bins other     = default;
                    }

        PSTRB   :   coverpoint s_trans.PSTRB 
                    {
                        bins byte_only     = {STRB_BYTE};
                        bins halfword      = {STRB_HALF};
                        bins full_word     = {STRB_MAX};
                        bins other_partial = {[STRB_BYTE+1 : STRB_MAX-1]};
                    }

        PWRITExPSTRB    :   cross PWRITE, PSTRB
                            {
                                illegal_bins read_trans_with_strb = binsof(PWRITE) intersect {0}; 
                            }
        PADDRxPWRITE    :   cross PADDR, PWRITE;

    endgroup

    function new(string name = "apb_coverage", uvm_component parent = null);
        super.new(name, parent);
        apb_master_cg = new();
        apb_slave_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        foreach(slv_mon2_cov_af[i])
        begin
            slv_mon2_cov_af[i] = new($sformatf("slv_mon2_cov_af_%0d", i), this);
        end
    endfunction

    // =========================================================================
    // write() — Data received from master monitor
    // =========================================================================
    function void write(apb_master_trans t);
        m_trans = t;
        apb_master_cg.sample();
    endfunction

    task run_phase(uvm_phase phase);
        fork
            foreach(slv_mon2_cov_af[i])
            begin
                automatic int ai = i;
                fork
                    begin
                        forever begin
                            slv_mon2_cov_af[ai].get(s_trans);
                            apb_slave_cg.sample();
                        end
                    end
                join_none
            end
        join_none
    endtask

    // =========================================================================
    // final_phase — prints per-group and total merged coverage report
    // =========================================================================
    function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info(get_type_name(), "============================================", UVM_NONE)
        `uvm_info(get_type_name(), "          APB FUNCTIONAL COVERAGE           ", UVM_NONE)
        `uvm_info(get_type_name(), "============================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf(" TOTAL (merged)       : %6.2f%%", $get_coverage()), UVM_NONE)
        `uvm_info(get_type_name(), "============================================", UVM_NONE)
    endfunction

endclass : apb_coverage

`endif