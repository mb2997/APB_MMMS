`ifndef APB_MAX_PREADY_TEST
`define APB_MAX_PREADY_TEST

class apb_max_pready_test extends apb_base_test;

    `uvm_component_utils(apb_max_pready_test)

    apb_max_pready_seqs pready_seqs[];

    function new(string name = "apb_max_pready_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        pready_seqs = new[config_ht.no_of_slaves];
        foreach(pready_seqs[i])
            pready_seqs[i] = apb_max_pready_seqs :: type_id :: create($sformatf("pready_seqs_%0d", i));
        fork
            begin
                //  Step 1 — spawn all ACTIVE slave sequences in the background
                foreach (env_h.agent_hs[i]) begin
                    automatic int ai = i;
                    if (config_ht.config_he.config_hs[ai].is_active == UVM_ACTIVE) begin
                        fork
                            begin
                                // capture handle INSIDE the thread so it is always valid
                                pready_seqs[ai].start(env_h.agent_hs[ai].seqr_hs);
                            end
                        join_none
                    end
                end
            end

            begin
                //  Step 2 — run master in the foreground; blocks until all
                seqs_hm.start(env_h.agent_hm.seqr_hm);
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