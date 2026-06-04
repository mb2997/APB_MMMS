`ifndef APB_MASTER_AGENT
`define APB_MASTER_AGENT

class apb_master_agent extends uvm_agent;

    `uvm_component_utils(apb_master_agent)

    //  only what the agent actually owns [needs]
    apb_master_seqr  seqr_hm;
    apb_master_drv   drv_hm;
    apb_master_mon   mon_hm;
    apb_master_config config_hm;

    function new(string name = "apb_master_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ----------------------------------------------------------------
    // build_phase
    // ----------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Executing Build-Phase in Master Agent", UVM_MEDIUM)

        //  no pre-create — get() assigns handle directly
        if(!uvm_config_db #(apb_master_config)::get(
                this, "", "apb_master_config", config_hm))
            `uvm_fatal(get_type_name(), "Failed to get apb_master_config")

        //  monitor always created — passive component [observes only]
        mon_hm = apb_master_mon::type_id::create("mon_hm", this);

        //  driver and sequencer only for active agent
        if(config_hm.is_active == UVM_ACTIVE) begin
            drv_hm  = apb_master_drv::type_id::create("drv_hm",  this);
            seqr_hm = apb_master_seqr::type_id::create("seqr_hm", this);
        end

        `uvm_info(get_type_name(), "Build-Phase Complete in Master Agent", UVM_MEDIUM)
    endfunction

    // ----------------------------------------------------------------
    // connect_phase
    // ----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Executing Connect-Phase in Master Agent", UVM_MEDIUM)

        //  connect driver to sequencer only if active
        if(config_hm.is_active == UVM_ACTIVE)
            drv_hm.seq_item_port.connect(seqr_hm.seq_item_export);

        `uvm_info(get_type_name(), "Connect-Phase Complete in Master Agent", UVM_MEDIUM)
    endfunction

endclass : apb_master_agent

`endif