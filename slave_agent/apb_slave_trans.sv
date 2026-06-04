`ifndef APB_SLAVE_TRANS
`define APB_SLAVE_TRANS

class apb_slave_trans extends uvm_sequence_item;

    // --------------------------------------------------------
    // Static counter
    // --------------------------------------------------------
    static int current_trans_s = 1;

    // --------------------------------------------------------
    // APB signals — sampled [captured] by monitor from interface
    // --------------------------------------------------------
    bit [`ADDR_WIDTH-1:0]  PADDR;
    bit [`DATA_WIDTH-1:0]  PWDATA;
    bit [`DATA_WIDTH-1:0]  PRDATA;
    bit [`STRB_WIDTH-1:0]  PSTRB;     //  added — byte lane enables
    bit                    PWRITE;
    bit                    PENABLE;
    bit                    PREADY;    //  default 0 — driver controls this
    bit                    PSLVERR;   //  added — slave error response
    bit                    PSEL[];    //  added — which slave selected

    // --------------------------------------------------------
    // Randomized slave behaviour fields
    // --------------------------------------------------------
    rand int unsigned  no_of_wait_cycles;   // how many cycles PREADY stays low
    rand bit           wait_enable;         // 0=respond immediately, 1=insert waits

    // --------------------------------------------------------
    // Constraints
    // --------------------------------------------------------

    // solve wait_enable first — it gates [controls] no_of_wait_cycles
    constraint c_solve_order {
        solve wait_enable before no_of_wait_cycles;
    }

    // wait cycles range
    constraint c_wait_cycles {
        if(wait_enable == 1'b1)
            no_of_wait_cycles inside {[1:4]};   //  hard constraint [cannot be overridden]
        else
            no_of_wait_cycles == 0;              //  hard zero — no soft
    }

    // weighted distribution — most transfers respond immediately
    constraint c_wait_enable {
        wait_enable dist {1'b0 := 70, 1'b1 := 30};
    }

    // --------------------------------------------------------
    // Factory registration and field automation
    // --------------------------------------------------------
    `uvm_object_utils_begin(apb_slave_trans)
        `uvm_field_int       (PADDR,            UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PWDATA,           UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PRDATA,           UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PSTRB,            UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PWRITE,           UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PENABLE,          UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PREADY,           UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PSLVERR,          UVM_ALL_ON | UVM_HEX)
        `uvm_field_array_int (PSEL,             UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (no_of_wait_cycles,UVM_ALL_ON | UVM_DEC)  //  DEC for readability
        `uvm_field_int       (wait_enable,      UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "apb_slave_trans");
        super.new(name);
    endfunction

endclass : apb_slave_trans

`endif