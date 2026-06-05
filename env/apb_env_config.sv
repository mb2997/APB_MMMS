`ifndef APB_ENV_CONFIG
`define APB_ENV_CONFIG

class apb_env_config extends uvm_object;

    // --------------------------------------------------------
    // Fields
    // --------------------------------------------------------
    int unsigned      no_of_slaves;    //  unsigned — can never be negative
    apb_master_config config_hm;       // master agent config
    apb_slave_config  config_hs[];     // one per slave — sized at test level

    // --------------------------------------------------------
    // Factory registration with field automation
    // --------------------------------------------------------
    `uvm_object_utils_begin(apb_env_config)
        `uvm_field_int         (no_of_slaves, UVM_ALL_ON | UVM_DEC)
        `uvm_field_object      (config_hm,    UVM_ALL_ON)
        `uvm_field_array_object(config_hs,    UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_env_config");
        super.new(name);
    endfunction

    // --------------------------------------------------------
    // check_config
    // Call from start_of_simulation_phase to catch [detect]
    // misconfiguration [wrong setup] before simulation runs
    // --------------------------------------------------------
    function void check_config();

        // no_of_slaves must be at least 1
        if(no_of_slaves == 0)
            `uvm_fatal(get_type_name(),
                "no_of_slaves is 0 — must have at least one slave")

        // master config must exist [not be null]
        if(config_hm == null)
            `uvm_fatal(get_type_name(),
                "config_hm is null — master config not created")

        // slave config array must be sized
        if(config_hs.size() == 0)
            `uvm_fatal(get_type_name(),
                "config_hs array is empty — slave configs not created")

        // slave config array size must match no_of_slaves
        if(config_hs.size() != no_of_slaves)
            `uvm_fatal(get_type_name(),
                $sformatf("config_hs.size()=%0d does not match no_of_slaves=%0d",
                           config_hs.size(), no_of_slaves))

        // each slave config must not be null
        foreach(config_hs[i]) begin
            if(config_hs[i] == null)
                `uvm_fatal(get_type_name(),
                    $sformatf("config_hs[%0d] is null — not created", i))
        end

        // address ranges must not overlap [two slaves cannot own the same address]
        foreach(config_hs[i]) begin
            foreach(config_hs[j]) begin
                if(i == j) continue;   // skip [don't compare] same slave
                if(config_hs[i].start_addr <= config_hs[j].end_addr &&
                   config_hs[i].end_addr   >= config_hs[j].start_addr)
                    `uvm_fatal(get_type_name(),
                        $sformatf("Address overlap detected [found] between slave-%0d (0x%0h-0x%0h) and slave-%0d (0x%0h-0x%0h)",
                                   i, config_hs[i].start_addr, config_hs[i].end_addr,
                                   j, config_hs[j].start_addr, config_hs[j].end_addr))
            end
        end

        `uvm_info(get_type_name(),
            $sformatf("Config check passed | slaves=%0d | master=%0s",
                       no_of_slaves, config_hm.get_name()),
            UVM_MEDIUM)

    endfunction

    // --------------------------------------------------------
    // print_config — quick summary [snapshot] of full config
    // --------------------------------------------------------
    function void print_config();
        `uvm_info(get_type_name(),
            $sformatf("=== ENV CONFIG SUMMARY ===\n No of Slaves : %0d",
                       no_of_slaves),
            UVM_MEDIUM)
        foreach(config_hs[i])
            config_hs[i].print_slave_info();
    endfunction

endclass : apb_env_config

`endif