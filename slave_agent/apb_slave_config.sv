`ifndef APB_SLAVE_CONFIG
`define APB_SLAVE_CONFIG

class apb_slave_config extends uvm_object;

    // --------------------------------------------------------
    // Slave identity [which slave this config belongs to]
    // --------------------------------------------------------
    int unsigned slave_id;   //  matches PSEL[slave_id] in driver

    // --------------------------------------------------------
    // Address range — set by test/env
    // --------------------------------------------------------
    bit [`ADDR_WIDTH-1:0] start_addr;
    bit [`ADDR_WIDTH-1:0] end_addr;

    // --------------------------------------------------------
    // Agent mode — active drives, passive only observes
    // --------------------------------------------------------
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    // --------------------------------------------------------
    // Slave behaviour settings [how this slave responds]
    // --------------------------------------------------------
    int unsigned no_of_wait_cycles  = 0;     // default = zero wait [responds immediately]
    bit          has_error_response = 1'b0;  // default = no error [normal operation]

    // Memory model
    bit [`DATA_WIDTH-1:0] mem_model[int];   // key=address, value=data


    // --------------------------------------------------------
    // Factory registration with field automation
    // --------------------------------------------------------
    `uvm_object_utils_begin(apb_slave_config)
        `uvm_field_int  (slave_id,           UVM_ALL_ON | UVM_DEC)
        `uvm_field_int  (start_addr,         UVM_ALL_ON | UVM_HEX)
        `uvm_field_int  (end_addr,           UVM_ALL_ON | UVM_HEX)
        `uvm_field_enum (uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int  (no_of_wait_cycles,  UVM_ALL_ON | UVM_DEC)
        `uvm_field_int  (has_error_response, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "apb_slave_config");
        super.new(name);
    endfunction

    // --------------------------------------------------------
    // Helper — prints this slave's address range cleanly
    // --------------------------------------------------------
    function void print_slave_info();
        `uvm_info(get_type_name(),
            $sformatf("Slave-%0d | Range: 0x%0h–0x%0h | is_active=%0s | wait=%0d",
                       slave_id,
                       start_addr,
                       end_addr,
                       is_active.name(),
                       no_of_wait_cycles),
            UVM_NONE)
    endfunction

endclass : apb_slave_config

`endif