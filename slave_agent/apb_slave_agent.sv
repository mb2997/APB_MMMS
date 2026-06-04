`ifndef APB_SLAVE_AGENT
`define APB_SLAVE_AGENT

class apb_slave_agent extends uvm_agent;

    `uvm_component_utils(apb_slave_agent)

    //  one slave agent owns exactly one slave config — not an array
    apb_slave_seqr   seqr_hs;
    apb_slave_drv    drv_hs;
    apb_slave_mon    mon_hs;
    apb_slave_config config_hs;   //  single config — not config_hs[]

    //  vif removed — children fetch their own via config_db

    function new(string name = "apb_slave_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ----------------------------------------------------------------
    // build_phase
    // ----------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Executing Build-Phase in Slave Agent", UVM_MEDIUM)

        //  get single slave config — key must match what env set
        // env sets it as "apb_slave_config" scoped to this agent's path
        if(!uvm_config_db #(apb_slave_config)::get(this, "", "apb_slave_config", config_hs))
            `uvm_fatal(get_type_name(), "Failed to get apb_slave_config")

        //  monitor always created — passive [observes only, never drives]
        mon_hs = apb_slave_mon::type_id::create("mon_hs", this);

        //  driver and sequencer only when active
        if(config_hs.is_active == UVM_ACTIVE) begin
            drv_hs  = apb_slave_drv::type_id::create("drv_hs", this);
            seqr_hs = apb_slave_seqr::type_id::create("seqr_hs", this);
        end

        `uvm_info(get_type_name(), "Build-Phase Complete in Slave Agent", UVM_MEDIUM)
    endfunction

    // ----------------------------------------------------------------
    // connect_phase
    // ----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Executing Connect-Phase in Slave Agent", UVM_MEDIUM)

        //  connect driver to sequencer only if active
        if(config_hs.is_active == UVM_ACTIVE)
            drv_hs.seq_item_port.connect(seqr_hs.seq_item_export);

        `uvm_info(get_type_name(), "Connect-Phase Complete in Slave Agent", UVM_MEDIUM)
    endfunction

endclass : apb_slave_agent

`endif