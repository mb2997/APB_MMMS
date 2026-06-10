`ifndef APB_SINGLE_SLAVE_RAND_RW_TEST
`define APB_SINGLE_SLAVE_RAND_RW_TEST

class apb_single_slave_rand_rw_test extends apb_base_test;

    `uvm_component_utils(apb_single_slave_rand_rw_test)

    apb_single_slave_rand_rw_seqs single_slv_seq;

    function new(string name = "apb_single_slave_rand_rw_test", uvm_component parent = null);
        super.new(name, parent);
        config_ht.no_of_slaves = 1;
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        single_slv_seq = apb_single_slave_rand_rw_seqs :: type_id :: create("single_slv_seq");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            begin
                //  Step 1 — spawn all ACTIVE slave sequences in the background
                foreach (env_h.agent_hs[i]) begin
                    automatic int ai = i;
                    if (config_ht.config_he.config_hs[ai].is_active == UVM_ACTIVE) begin
                        fork
                            begin
                                // capture handle INSIDE the thread so it is always valid
                                // slave_procs[ai] = process::self();
                                seqs_hs[ai].start(env_h.agent_hs[ai].seqr_hs);
                            end
                        join_none
                    end
                end
            end

            begin
                //  Step 2 — run master in the foreground; blocks until all
                single_slv_seq.start(env_h.agent_hm.seqr_hm);
                `uvm_info(get_type_name(), "Master sequence complete — stopping simulation", UVM_MEDIUM)
            end
        join
        //  Step 3 — drop objection — simulation ends cleanly
        phase.phase_done.set_drain_time(this, 20);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Objection dropped — run phase complete", UVM_MEDIUM)
    endtask

endclass

`endif