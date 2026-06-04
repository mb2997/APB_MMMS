`ifndef APB_MASTER_TRANS
`define APB_MASTER_TRANS

class apb_master_trans extends uvm_sequence_item;

    // --------------------------------------------------------
    // Static tracking variables
    // --------------------------------------------------------
    static int                       current_trans_m = 1;
    static bit [`ADDR_WIDTH-1:0]     prev_addr;

    // --------------------------------------------------------
    // Randomized signals
    // --------------------------------------------------------
    rand bit                         PWRITE;
    randc bit [`ADDR_WIDTH-1:0]      PADDR;
    rand bit [`DATA_WIDTH-1:0]       PWDATA;
    rand transfer_size_e             trans_size;

    // --------------------------------------------------------
    // Non-random signals
    // Driver controls PENABLE — never randomize it
    // PSEL computed by populate_psel() in driver — never randomize
    // PSTRB computed in post_randomize via strobe_calc()
    // --------------------------------------------------------
    bit                              PENABLE;
    bit [`STRB_WIDTH-1:0]            PSTRB;
    bit                              PSEL[];

    // --------------------------------------------------------
    // Response signals — driven by slave, captured by driver
    // --------------------------------------------------------
    bit                              PREADY;
    bit [`DATA_WIDTH-1:0]            PRDATA;
    bit                              PSLVERR;

    // --------------------------------------------------------
    // Factory & field registration
    // --------------------------------------------------------
    `uvm_object_utils_begin(apb_master_trans)
        `uvm_field_int       (PWRITE,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PADDR,     UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PWDATA,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PSTRB,     UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PENABLE,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_array_int (PSEL,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_enum      (transfer_size_e, trans_size, UVM_ALL_ON)
        `uvm_field_int       (PREADY,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PRDATA,    UVM_ALL_ON | UVM_HEX)
        `uvm_field_int       (PSLVERR,   UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    // --------------------------------------------------------
    // Constraints
    // --------------------------------------------------------

    // Transfer size distribution — WORD weighted [favored] heavily
    constraint c_trans_size {
        trans_size dist {
            WORD     := 70,
            HALFWORD := 20,
            BYTE     := 10
        };
    }

    // Read/write distribution
    constraint c_pwrite {
        PWRITE dist {1 := 60, 0 := 40};
    }

    // PWDATA must be 0 on reads — no point [no meaning] driving data during a read
    constraint c_pwdata {
        if(PWRITE == 1'b0) PWDATA == '0;
        solve PWRITE before PWDATA;
    }

    // Address must stay within valid range
    constraint c_paddr {
        PADDR inside {[0 : (2**`ADDR_WIDTH)-1]};
    }

    // Transfer size and PWRITE must be solved before PSTRB is computed
    constraint c_solve_order {
        solve PWRITE     before trans_size;
        solve trans_size before PWDATA;
    }

    // --------------------------------------------------------
    // Constructor
    // --------------------------------------------------------
    function new(string name = "apb_master_trans");
        super.new(name);
    endfunction

    // --------------------------------------------------------
    // pre_randomize — called just before randomize()
    // --------------------------------------------------------
    function void pre_randomize();
        // store previous address for debug tracking [keeping tabs on history]
        prev_addr = PADDR;
    endfunction

    // --------------------------------------------------------
    // post_randomize — called just after randomize()
    // --------------------------------------------------------
    function void post_randomize();
        strobe_calc();   // compute PSTRB based on final PWRITE + trans_size values
    endfunction

    // --------------------------------------------------------
    // strobe_calc
    // PSTRB depends on both transfer size AND direction
    // --------------------------------------------------------
    function void strobe_calc();

        // reads — spec mandated [required by APB specification] — always zero
        if(PWRITE == 1'b0) begin
            PSTRB = '0;
            return;
        end

        // writes — PSTRB reflects [matches] transfer size
        case(trans_size)
            BYTE     : PSTRB = 'h1;    // only byte 0 valid
            HALFWORD : PSTRB = 'h3;    // bytes 0-1 valid
            WORD     : PSTRB = 'hF;    // all bytes valid
            default  : begin
                PSTRB = 'hF;
                `uvm_warning("STRB_WARN",
                    $sformatf("Unknown trans_size=%0s — defaulting PSTRB to 0xF",
                               trans_size.name()))
            end
        endcase

    endfunction

    // --------------------------------------------------------
    // do_print override — cleaner [easier to read] transaction display
    // --------------------------------------------------------
    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_string ("Direction",  PWRITE ? "WRITE" : "READ");
        printer.print_string ("Trans Size", trans_size.name());
    endfunction

endclass : apb_master_trans

`endif