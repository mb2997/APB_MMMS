`ifndef APB_SLAVE_DRV
`define APB_SLAVE_DRV

class apb_slave_drv extends uvm_driver #(apb_slave_trans);

    `uvm_component_utils(apb_slave_drv)

    // Interface and config handles
    virtual apb_inf vif;
    apb_slave_config     config_hs;

    function new(string name = "apb_slave_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ----------------------------------------------------------------
    // build_phase
    // ----------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual apb_inf)::get(
                this, "", "apb_inf", vif))
            `uvm_fatal(get_type_name(), "Failed to get apb_inf")

        if(!uvm_config_db #(apb_slave_config)::get(
                this, "", "apb_slave_config", config_hs))
            `uvm_fatal(get_type_name(), "Failed to get apb_slave_config")

        `uvm_info(get_type_name(), "Build-Phase Complete in Slave Driver", UVM_MEDIUM)
    endfunction

    // ----------------------------------------------------------------
    // connect_phase
    // ----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    // ----------------------------------------------------------------
    // run_phase
    // ----------------------------------------------------------------
    task run_phase(uvm_phase phase);

        // Step 1 — idle outputs during reset
        idle_outputs();

        // Step 2 — wait for reset to deassert
        wait_for_reset();

        // Step 3 — one settling cycle
        @(vif.slv_drv_cb);

        // Step 4 — drive transactions forever
        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info(get_type_name(),
                $sformatf("Transaction received at SLAVE-DRIVER =\n%s",
                           req.sprint()),
                UVM_MEDIUM)

            drive_to_inf();

            seq_item_port.item_done();

            `uvm_info(get_type_name(),
                $sformatf("Transaction complete at SLAVE-DRIVER =\n%s",
                           req.sprint()),
                UVM_MEDIUM)
        end

    endtask

    // ----------------------------------------------------------------
    // idle_outputs
    // Keep all driven signals in safe inactive state
    // ----------------------------------------------------------------
    task idle_outputs();
        vif.slv_drv_cb.PREADY  <= 1'b0;
        vif.slv_drv_cb.PRDATA  <= '0;
        vif.slv_drv_cb.PSLVERR <= 1'b0;
    endtask

    // ----------------------------------------------------------------
    // wait_for_reset
    // ----------------------------------------------------------------
    task wait_for_reset();
        fork
            begin : reset_wait
                wait(vif.PRESETn == 1'b1);
            end
            begin : reset_timeout
                repeat(10) @(vif.slv_drv_cb);
                `uvm_error("RESET_TIMEOUT",
                    "PRESETn not deasserted after 10 cycles in slave driver")
            end
        join_any
        disable fork;
        `uvm_info(get_type_name(),
            "PRESETn deasserted — slave driver active", UVM_MEDIUM)
    endtask

    // ----------------------------------------------------------------
    // drive_to_inf
    // Handles one complete APB transfer — write or read
    // ----------------------------------------------------------------
    task drive_to_inf();

        // Wait for this slave's PSEL to be asserted [go high]
        // config_hs.slave_id tells us which PSEL index belongs to this slave
        @(vif.slv_drv_cb);
        wait(vif.slv_drv_cb.PSEL[config_hs.slave_id] === 1'b1);

        // Wait for PENABLE — access phase started [master is ready]
        wait(vif.slv_drv_cb.PENABLE === 1'b1);

        // Insert wait cycles [simulate slave latency] before asserting PREADY
        if(req.no_of_wait_cycles > 0) begin
            repeat(req.no_of_wait_cycles) begin
                vif.slv_drv_cb.PREADY <= 1'b0;   // hold PREADY low during wait
                @(vif.slv_drv_cb);
            end
        end

        vif.slv_drv_cb.PREADY  <= 1'b1;

        // ----------------------------------------
        // WRITE transfer
        // ----------------------------------------
        if(vif.slv_drv_cb.PWRITE == 1'b1) begin

            // Write each valid byte lane [only where PSTRB is set]
            // for(int b = 0; b < `DATA_WIDTH/8; b++)
            foreach(vif.slv_drv_cb.PSTRB[b])
            begin
                if(vif.slv_drv_cb.PSTRB[b]) 
                begin
                    config_hs.mem_model[vif.slv_drv_cb.PADDR][b*8 +: 8] = vif.slv_drv_cb.PWDATA[b*8 +: 8];
                end
            end

            `uvm_info(get_type_name(), $sformatf("WRITE | ADDR=0x%0h | DATA=0x%0h | STRB=0x%0h", vif.slv_drv_cb.PADDR, config_hs.mem_model[vif.slv_drv_cb.PADDR], vif.slv_drv_cb.PSTRB), UVM_MEDIUM)

            // Assert PREADY — write complete
            vif.slv_drv_cb.PSLVERR <= 1'b0;
            @(vif.slv_drv_cb);

        end

        // ----------------------------------------
        // READ transfer
        // ----------------------------------------
        else begin

            // Check if address exists in memory
            if(config_hs.mem_model.exists(vif.slv_drv_cb.PADDR)) begin
                vif.slv_drv_cb.PRDATA <= config_hs.mem_model[vif.slv_drv_cb.PADDR];
                vif.slv_drv_cb.PSLVERR <= 1'b0;
                `uvm_info(get_type_name(), $sformatf("READ  | ADDR=0x%0h | DATA=0x%0h", vif.slv_drv_cb.PADDR, config_hs.mem_model[vif.slv_drv_cb.PADDR]), UVM_MEDIUM)
            end
            else begin
                // Address never written — return 0 and flag error
                vif.slv_drv_cb.PRDATA  <= '0;
                `uvm_info(get_type_name(), $sformatf("READ_ERROR | ADDR=0x%0h not in mem_model — returning 0, asserting PSLVERR", vif.slv_drv_cb.PADDR), UVM_MEDIUM)
            end

            // Assert PREADY — read data valid on bus
            vif.slv_drv_cb.PREADY <= 1'b1;
            @(vif.slv_drv_cb);

        end

        // Deassert PREADY after one cycle — ready for next transfer
        vif.slv_drv_cb.PREADY  <= 1'b0;
        vif.slv_drv_cb.PSLVERR <= 1'b0;

    endtask

endclass : apb_slave_drv

`endif