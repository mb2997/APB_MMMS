`ifndef APB_ENV
`define APB_ENV

class apb_env extends uvm_env;

    `uvm_component_utils(apb_env)

    // --------------------------------------------------------
    // Component handles
    // --------------------------------------------------------
    apb_master_agent  agent_hm;
    apb_slave_agent   agent_hs[];
    apb_env_config    config_he;
    apb_sb            sb_h;

    // --------------------------------------------------------
    // Virtual interface handle — set from top/test
    // --------------------------------------------------------
    virtual apb_inf vif;

    function new(string name = "apb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    // ----------------------------------------------------------------
    // build_phase
    // ----------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //  Step 1 — get env config
        if(!uvm_config_db #(apb_env_config)::get(this, "", "apb_env_config", config_he))
            `uvm_fatal(get_type_name(), "apb_env_config not found in config_db")

        //  Step 2 — get virtual interface
        if(!uvm_config_db #(virtual apb_inf)::get(this, "", "apb_inf", vif))
            `uvm_fatal(get_type_name(), "apb_inf not found in config_db")

        //  Step 3 — set master config scoped to master agent only
        uvm_config_db #(apb_master_config)::set(this, "agent_hm*", "apb_master_config", config_he.config_hm);

        //  Step 4 — set env config for master driver — needs it for PSEL decode
        uvm_config_db #(apb_env_config)::set(this, "agent_hm*", "apb_env_config", config_he);

        //  Step 6 — size slave agent array
        agent_hs = new[config_he.no_of_slaves];

        //  Step 7 — create all components
        agent_hm = apb_master_agent::type_id::create("agent_hm", this);
        sb_h     = apb_sb::type_id::create("sb_h",     this);

        foreach(agent_hs[i]) begin
            agent_hs[i] = apb_slave_agent::type_id::create($sformatf("agent_hs_%0d", i), this);
            //  scope slave config to exact agent path — not "*"
            uvm_config_db #(apb_slave_config)::set(this, $sformatf("agent_hs_%0d*", i), "apb_slave_config", config_he.config_hs[i]);
        end

        `uvm_info(get_type_name(), $sformatf("ENV built | slaves=%0d", config_he.no_of_slaves), UVM_MEDIUM)

    endfunction

    // ----------------------------------------------------------------
    // connect_phase
    // ----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);   //  was missing

        //  master monitor → scoreboard
        agent_hm.mon_hm.mas_mon_ap.connect(sb_h.mas_mon_fifo_h.analysis_export);

        //  ALL slave monitors → scoreboard — properly connected [not commented out]
        foreach(agent_hs[i])
            agent_hs[i].mon_hs.slv_mon_ap.connect(sb_h.slv_mon_fifo_h[i].analysis_export);

        `uvm_info(get_type_name(), "Connect-Phase complete in ENV", UVM_MEDIUM)

    endfunction

    // ----------------------------------------------------------------
    // start_of_simulation_phase
    // Size each slave monitor's wave-mirror array after all builds done
    // ----------------------------------------------------------------
    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);

        foreach(agent_hs[i]) begin
            int unsigned size;
            size = config_he.config_hs[i].end_addr - config_he.config_hs[i].start_addr + 1;
            config_he.config_hs[i].print_slave_info();
        end

    endfunction

endclass : apb_env

`endif