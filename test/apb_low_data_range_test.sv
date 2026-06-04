`ifndef APB_LOW_DATA_RANGE_TEST
`define APB_LOW_DATA_RANGE_TEST

class apb_low_data_range_test extends apb_base_test;
    
    //Factory registration
    `uvm_component_utils(apb_low_data_range_test)

    function new(string name = "apb_low_data_range_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    apb_low_data_range_seqs seqs_tc;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seqs_tc = apb_low_data_range_seqs :: type_id :: create("seqs_tc");
        if(config_hm.is_active == UVM_ACTIVE)
        fork
            seqs_tc.start(env_hm.agent_hm.seqr_hm);
            seqs_hs.start(env_hm.agent_hs.seqr_hs);
        join_any
        if(config_hm.is_active == UVM_PASSIVE)
        begin
            #3000;
        end
        phase.drop_objection(this);
        $display("------ Execution Done Run-Phase in Test -------");
    endtask

endclass : apb_low_data_range_test

`endif