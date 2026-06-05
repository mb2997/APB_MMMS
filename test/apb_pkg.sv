`include "../env/apb_inf.sv"

package apb_pkg;

    int no_of_trans = 5;

    `include "../top/apb_defs.sv"

    //memory model - associative array
    // bit [`DATA_WIDTH-1:0] mem_model [int];
    bit [`DATA_WIDTH-1:0] expected_data;
    bit [`DATA_WIDTH-1:0] actual_data;
    virtual apb_inf vif;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef class apb_env_config;

    `include "../master_agent/apb_master_config.sv"
    `include "../slave_agent/apb_slave_config.sv"

    `include "../master_agent/apb_master_trans.sv"
    `include "../slave_agent/apb_slave_trans.sv"
    
    `include "../master_agent/apb_master_seqr.sv"
    `include "../slave_agent/apb_slave_seqr.sv"
    
    `include "../master_agent/apb_master_seqs.sv"
    `include "../slave_agent/apb_slave_seqs.sv"

    // //Testcase sequences
    // `include "apb_low_addr_range_seqs.sv"
    // `include "apb_high_addr_range_seqs.sv"
    // `include "apb_mid_reset_seqs.sv"
    // `include "apb_pready_wait_timeout_seqs.sv"
    // `include "apb_high_data_range_seqs.sv"
    // `include "apb_low_data_range_seqs.sv"
    
    `include "../master_agent/apb_master_mon.sv"
    `include "../slave_agent/apb_slave_mon.sv"
    
    `include "../master_agent/apb_master_drv.sv"
    `include "../slave_agent/apb_slave_drv.sv"
    
    `include "../master_agent/apb_master_agent.sv"
    `include "../slave_agent/apb_slave_agent.sv"
    
    
    `include "../env/apb_sb.sv"
    `include "../env/apb_env_config.sv"
    `include "../env/apb_env.sv"
    
    `include "apb_test_config.sv"
    `include "apb_base_test.sv"
    
    // //Testcases Test
    // `include "apb_low_addr_range_test.sv"
    // `include "apb_high_addr_range_test.sv"
    // `include "apb_mid_reset_test.sv"
    // `include "apb_pready_wait_timeout_test.sv"
    // `include "apb_high_data_range_test.sv"
    // `include "apb_low_data_range_test.sv"

    function void get_vif_in_pkg();
        if(!uvm_config_db #(virtual apb_inf) :: get(null," ","apb_inf",vif))
            `uvm_fatal("APB_PKG :",$sformatf("Can't able to get apb_inf... Have you set it ??"))
    endfunction : get_vif_in_pkg

    task wait_for_pready();
        wait(vif.PREADY == 1);
    endtask

    task wait_for_posedge_clock(int no_of_clocks = 1);
        repeat(no_of_clocks)
            @(posedge vif.PCLK);
    endtask : wait_for_posedge_clock

    task wait_for_reset(int max_wait_clocks = 10);
        fork
            begin : reset_wait
                wait(vif.PRESETn == 1'b1);
            end
            begin : reset_timeout
                repeat(max_wait_clocks)
                    @(vif.slv_drv_cb);
                `uvm_error("RESET_TIMEOUT", $sformatf("PRESETn not deasserted after %0d cycles", max_wait_clocks))
            end
        join_any
        disable fork;
    endtask
    
endpackage : apb_pkg