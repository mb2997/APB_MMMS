`ifndef APB_MASTER_SEQR
`define APB_MASTER_SEQR

class apb_master_seqr extends uvm_sequencer #(apb_master_trans);

    //Factory registration
    `uvm_component_utils(apb_master_seqr)

    apb_test_config config_ht;

    function new(string name = "apb_master_seqr", uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(apb_test_config)::get(this, "", "apb_test_config", config_ht))
            `uvm_fatal(get_type_name(), "apb_test_config not found in config_db")
    endfunction

endclass : apb_master_seqr

`endif