`ifndef APB_PREADY_WAIT_TIMEOUT_TEST
`define APB_PREADY_WAIT_TIMEOUT_TEST

class apb_pready_wait_timeout_test extends apb_base_test;
    
    //Factory registration
    `uvm_component_utils(apb_pready_wait_timeout_test)

    function new(string name = "apb_pready_wait_timeout_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        uvm_root :: get().set_report_severity_id_override(UVM_ERROR,"TIMEOUT_ERROR",UVM_WARNING);
        uvm_root :: get().set_report_severity_override(UVM_ERROR,UVM_WARNING);
        $display("------ TC: Execution Done End-of_ELB in Test -------");
    endfunction

    apb_pready_wait_timeout_seqs seqs_tc_s;
    apb_high_addr_range_seqs seqs_tc_m;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seqs_tc_s = apb_pready_wait_timeout_seqs :: type_id :: create("seqs_tc_s");
        seqs_tc_m = apb_high_addr_range_seqs :: type_id :: create("seqs_tc_m");

        if(config_hm.is_active == UVM_ACTIVE)
        fork
            seqs_tc_m.start(env_hm.agent_hm.seqr_hm);
            seqs_tc_s.start(env_hm.agent_hs.seqr_hs);
        join_any
        if(config_hm.is_active == UVM_PASSIVE)
        begin
            #3000;
        end
        phase.drop_objection(this);
        $display("------ Execution Done Run-Phase in Test -------");
    endtask

endclass : apb_pready_wait_timeout_test

`endif