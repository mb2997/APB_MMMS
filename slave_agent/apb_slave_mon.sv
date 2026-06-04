`ifndef APB_SLAVE_MON
`define APB_SLAVE_MON

class apb_slave_mon extends uvm_monitor;

    virtual apb_inf vif;
    apb_slave_config config_hs;
    apb_slave_trans trans_hs;

    int num_of_slv_packets_sampled;

    `uvm_component_utils(apb_slave_mon)

    // Analysis port
    uvm_analysis_port #(apb_slave_trans) slv_mon_ap;

    function new(string name = "apb_slave_mon", uvm_component parent = null);
        super.new(name, parent);
        slv_mon_ap = new("slv_mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 

        if(!uvm_config_db #(virtual apb_inf)::get(
                this, "", "apb_inf", vif))
            `uvm_fatal(get_type_name(), "Failed to get apb_inf")

        if(!uvm_config_db #(apb_slave_config)::get(
                this, "", "apb_slave_config", config_hs))
            `uvm_fatal(get_type_name(), "Failed to get apb_slave_config")

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task wait_for_reset();
        fork
            begin : reset_wait
                wait(vif.PRESETn == 1'b1);
            end
            begin : reset_timeout
                repeat(10) @(vif.slv_drv_cb);
                `uvm_error("RESET_WAIT_TIMEOUT",
                    "PRESETn not deasserted after 10 clock cycles")
            end
        join_any
        disable fork;
        `uvm_info(get_type_name(), "PRESETn deasserted — slave monitor active", UVM_MEDIUM)
    endtask

    task run_phase(uvm_phase phase);

        // Wait for reset before sampling anything
        wait_for_reset();

        forever begin
            data_from_inf();
        end

    endtask

    // --------------------------------------------------------
    // populate_mem_model
    // Respects PSTRB — only writes valid byte lanes
    // --------------------------------------------------------
    function void populate_mem_model();
        if(trans_hs.PWRITE == 1'b1) begin

            //  byte-lane write — check each PSTRB bit
            for(int b = 0; b < `DATA_WIDTH/8; b++) begin
                if(trans_hs.PSTRB[b])
                    config_hs.mem_model[trans_hs.PADDR][(b*8)+:8] =
                        trans_hs.PWDATA[(b*8)+:8];
            end

            `uvm_info(get_type_name(),
                $sformatf("Slave-%0d mem_model[0x%0h] = 0x%0h | PSTRB=0x%0h",
                           config_hs.slave_id,
                           trans_hs.PADDR,
                           config_hs.mem_model[trans_hs.PADDR],
                           trans_hs.PSTRB),
                UVM_HIGH)
        end
    endfunction

    // --------------------------------------------------------
    // data_from_inf
    // Samples one complete APB transfer at correct clock edge
    // --------------------------------------------------------
    task data_from_inf();
        trans_hs = apb_slave_trans::type_id::create("trans_hs");

        //  wait for this slave's PSEL — not any PSEL
        @(posedge vif.slv_mon_cb);
        wait(vif.PSEL[config_hs.slave_id] == 1'b1);

        //  wait for PENABLE — access phase begun [master has moved to access phase]
        wait(vif.PENABLE == 1'b1);

        //  wait for PREADY — transfer complete [slave has responded]
        wait(vif.PREADY == 1'b1);

        //  sample at clock edge — stable values guaranteed [no glitches]
        @(posedge vif.slv_mon_cb);

        // Capture all signals
        trans_hs.PADDR   = vif.PADDR;
        trans_hs.PWDATA  = vif.PWDATA;
        trans_hs.PWRITE  = vif.PWRITE;
        trans_hs.PREADY  = vif.PREADY;
        trans_hs.PENABLE = vif.PENABLE;
        // trans_hs.PRDATA  = vif.PRDATA;
        trans_hs.PSTRB   = vif.PSTRB;
        trans_hs.PSLVERR = vif.PSLVERR;

        // Log and send to scoreboard
        if(trans_hs.PWRITE == 1'b1)
            `uvm_info(get_type_name(), $sformatf("Slave-%0d WRITE sampled =\n%s", config_hs.slave_id, trans_hs.sprint()), UVM_MEDIUM)
        else
            `uvm_info(get_type_name(), $sformatf("Slave-%0d READ  sampled =\n%s", config_hs.slave_id, trans_hs.sprint()), UVM_MEDIUM)

        // Update memory model
        populate_mem_model();

        // Broadcast [send out] to scoreboard
        slv_mon_ap.write(trans_hs);
        `uvm_info(get_type_name(), $sformatf("Slave-%0d transaction sent to scoreboard", config_hs.slave_id), UVM_MEDIUM)

        num_of_slv_packets_sampled++;

    endtask

    // --------------------------------------------------------
    // report_phase
    // --------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        //  use slave_id instead of static cnt — clean and explicit
        // `uvm_info(get_type_name(), $sformatf("=== SLAVE-%0d MONITOR REPORT | Packets Sampled: %0d ===", config_hs.slave_id,num_of_slv_packets_sampled), UVM_NONE)

        //  foreach already iterates existing keys — exists() check redundant
        foreach(config_hs.mem_model[addr])
            `uvm_info(get_type_name(), $sformatf("mem_model[0x%0h] \t= 0x%0h", addr, config_hs.mem_model[addr]), UVM_NONE)

    endfunction

endclass : apb_slave_mon

`endif