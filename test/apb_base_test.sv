`ifndef APB_BASE_TEST
`define APB_BASE_TEST

class apb_base_test extends uvm_test;

    `uvm_component_utils(apb_base_test)

    apb_env           env_h;
    apb_master_seqs   seqs_hm;
    apb_slave_seqs    seqs_hs[];
    apb_test_config   config_ht;
    int unsigned      stride;

    function new(string name = "apb_base_test", uvm_component parent = null);
        super.new(name, parent);
        config_ht = apb_test_config::type_id::create("config_ht");
    endfunction

    // --------------------------------------------------------
    // create_test_config
    // --------------------------------------------------------
    function void create_test_config();
        config_ht.config_he        = apb_env_config::type_id::create("config_he");
        config_ht.config_he.config_hm = apb_master_config::type_id::create("config_hm");

        config_ht.config_he.no_of_slaves           = config_ht.no_of_slaves;
        config_ht.config_he.config_hm.no_of_slaves = config_ht.no_of_slaves;

        config_ht.config_he.config_hs = new[config_ht.no_of_slaves];
        seqs_hs                       = new[config_ht.no_of_slaves];

        foreach (config_ht.config_he.config_hs[i])
            config_ht.config_he.config_hs[i] =
                apb_slave_config::type_id::create($sformatf("config_hs_%0d", i));

        stride = (2**`ADDR_WIDTH) / config_ht.no_of_slaves;

        foreach (config_ht.config_he.config_hs[i]) begin
            config_ht.config_he.config_hs[i].slave_id   = i;
            config_ht.config_he.config_hs[i].start_addr = i * stride;
            config_ht.config_he.config_hs[i].end_addr   = (i * stride) + stride - 1;
            config_ht.config_he.config_hs[i].is_active  = UVM_ACTIVE;
        end

        uvm_config_db #(apb_env_config)::set(this, "*", "apb_env_config", config_ht.config_he);
    endfunction

    // --------------------------------------------------------
    // build_phase
    // --------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        get_vif_in_pkg();
        create_test_config();
        env_h   = apb_env::type_id::create("env_h", this);
        seqs_hm = apb_master_seqs::type_id::create("seqs_hm");
        foreach (seqs_hs[i])
            seqs_hs[i] = apb_slave_seqs::type_id::create($sformatf("seqs_hs_%0d", i));
        `uvm_info(get_type_name(), "Build-Phase complete in Test", UVM_MEDIUM)
    endfunction

    // --------------------------------------------------------
    // end_of_elaboration_phase
    // --------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        `uvm_info(get_type_name(), "End-of-Elaboration complete in Test", UVM_MEDIUM)
    endfunction

    // --------------------------------------------------------
    // run_phase
    // --------------------------------------------------------
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
                seqs_hm.start(env_h.agent_hm.seqr_hm);
                `uvm_info(get_type_name(), "Master sequence complete — stopping simulation", UVM_MEDIUM)
            end
        join

        //  Step 3 — drop objection — simulation ends cleanly
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Objection dropped — run phase complete", UVM_MEDIUM)
    endtask

endclass : apb_base_test

`endif