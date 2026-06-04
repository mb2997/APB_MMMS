`ifndef APB_MASTER_CONFIG
`define APB_MASTER_CONFIG

class apb_master_config extends uvm_object;

    //Factory registration
    `uvm_object_utils(apb_master_config)

    //Master agent selection :- ACTIVE or PASSIVE
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    int no_of_slaves;
    logic selected_slave;

    static int trans_sent_from_master_drv = 0;
    static int trans_rcvd_to_master_mon = 0;

    function new(string name = "apb_master_config");
        super.new(name);
    endfunction

endclass : apb_master_config

`endif