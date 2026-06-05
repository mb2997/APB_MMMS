`ifndef APB_MASTER_DRV
`define APB_MASTER_DRV

class apb_master_drv extends uvm_driver #(apb_master_trans);

    //Factory registration
    `uvm_component_utils(apb_master_drv)

    //Required instance of class & interface
    virtual apb_inf vif;

    //Config handles
    apb_master_config config_hm;
    apb_env_config    config_he;
    apb_master_trans  trans_hm;

    //State tracking
    state_e      transfer_state;
    trans_kind_e read_write;
    static int   trans_cnt = 1;
    string       trans;

    //Local variables
    bit clock_disable;

    //uvm_event
    uvm_event data_sent_from_mstr_drv;

    function new(string name = "apb_master_drv", uvm_component parent = null);
        super.new(name, parent);
        $cast(transfer_state, 0);
    endfunction

    // ----------------------------------------------------------------
    // build_phase
    // ----------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // create req — inherited handle from uvm_driver, must exist before run_phase
        req = apb_master_trans::type_id::create("req");

        if(!uvm_config_db #(apb_master_config)::get(this, "", "apb_master_config", config_hm))
            `uvm_fatal(get_type_name(), "Failed to get apb_master_config. Have you set it?")

        if(!uvm_config_db #(apb_env_config)::get(this, "", "apb_env_config", config_he))
            `uvm_fatal(get_type_name(), "Failed to get apb_env_config. Have you set it?")

        if(!uvm_config_db #(virtual apb_inf)::get(this, "", "apb_inf", vif))
            `uvm_fatal(get_type_name(), "Failed to get apb_inf. Have you set it?")

        trans_hm = apb_master_trans::type_id::create("trans_hm");

        $display("------ Execution Done Build-Phase in Master Driver -------");
    endfunction

    // ----------------------------------------------------------------
    // connect_phase
    // ----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    // ----------------------------------------------------------------
    // populate_psel
    // Computes PSEL from address map — exactly one PSEL must be high
    // ----------------------------------------------------------------
    function void populate_psel();
        int unsigned matched;
        matched = 0;

        req.PSEL = new[config_he.no_of_slaves];

        foreach(config_he.config_hs[i]) begin
            if(req.PADDR >= config_he.config_hs[i].start_addr &&
               req.PADDR <= config_he.config_hs[i].end_addr) begin
                req.PSEL[i] = 1'b1;
                matched++;
            end
            else
                req.PSEL[i] = 1'b0;
        end

        // one-hot check — exactly one slave must own this address
        if(matched == 0)
            `uvm_fatal("PSEL_DECODE",
                $sformatf("Address 0x%0h does not belong to any slave", req.PADDR))
        else if(matched > 1)
            `uvm_fatal("PSEL_OVERLAP",
                $sformatf("Address 0x%0h maps to %0d slaves — overlapping address ranges",
                           req.PADDR, matched))

    endfunction

    // ----------------------------------------------------------------
    // idle_bus
    // Drive all outputs to inactive/safe state
    // ----------------------------------------------------------------
    task idle_bus();
        foreach(req.PSEL[i])
            vif.mas_drv_cb.PSEL[i] <= 1'b0;
        vif.mas_drv_cb.PENABLE <= 1'b0;
        vif.mas_drv_cb.PWRITE  <= 1'b0;
        vif.mas_drv_cb.PADDR   <= '0;
        vif.mas_drv_cb.PWDATA  <= '0;
        vif.mas_drv_cb.PSTRB   <= '0;
    endtask

    // ----------------------------------------------------------------
    // run_phase
    // ----------------------------------------------------------------
    task run_phase(uvm_phase phase);

        // Step 1 — idle bus before reset releases
        req.PSEL = new[config_he.no_of_slaves];
        idle_bus();

        // Step 2 — wait for reset ONCE outside the forever loop
        wait_for_reset();

        // Step 3 — one settling cycle after reset deasserts
        @(vif.mas_drv_cb);

        // Step 4 — parallel reset monitor watches for mid-sim reset
        fork
            begin : reset_monitor
                forever begin
                    @(negedge vif.PRESETn);
                    `uvm_warning(get_type_name(),
                        "PRESETn asserted mid-simulation — idling bus")
                    idle_bus();
                    wait(vif.PRESETn == 1'b1);
                    @(vif.mas_drv_cb);
                    `uvm_info(get_type_name(),
                        "PRESETn released — resuming transfers", UVM_MEDIUM)
                end
            end

            begin : driver_main
                // Step 5 — drive transactions continuously
                forever begin
                    seq_item_port.get_next_item(req);

                    trans = $sformatf("MASTER-TRANS-%0d", trans_cnt);

                    if(req.PWRITE == 1)
                        $cast(read_write, 2);
                    else if(req.PWRITE == 0) 
                        $cast(read_write, 1);

                    `uvm_info(get_type_name(), $sformatf("[%s] Data Received at MASTER-DRIVER =\n%s", trans, req.sprint()), UVM_MEDIUM)

                    // Compute PSEL from address map
                    populate_psel();

                    // Drive the transaction
                    drive_item(req);

                    seq_item_port.item_done();

                    `uvm_info(get_type_name(), $sformatf("[%s] Transfer Complete — MASTER-DRIVER\n%s", trans, req.sprint()), UVM_MEDIUM)

                    trans_cnt++;
                end
            end

        join_any

        $display("------ Execution Done Run-Phase in Master Driver -------");
    endtask

    // ----------------------------------------------------------------
    // drive_item
    // Drives one complete APB transfer — setup + access phase
    // ----------------------------------------------------------------
    task drive_item(apb_master_trans req);

        // --------------------------------------------------------
        // SETUP PHASE — assert PSEL, drive address/data, PENABLE=0
        // --------------------------------------------------------
        $cast(transfer_state, 1);

        vif.mas_drv_cb.PADDR   <= req.PADDR;
        vif.mas_drv_cb.PWRITE  <= req.PWRITE;
        vif.mas_drv_cb.PENABLE <= 1'b0;

        // Assert correct PSEL — only one must be high
        if(req.PSEL.size() > 0) begin
            foreach(req.PSEL[i])
                vif.mas_drv_cb.PSEL[i] <= req.PSEL[i];
        end
        else
            `uvm_fatal("PSEL_ERROR", "PSEL array is empty — populate_psel() not called")

        // Drive PWDATA and PSTRB only on WRITE — high-Z on READ
        if(req.PWRITE == 1'b1) begin
            vif.mas_drv_cb.PWDATA <= req.PWDATA;
            vif.mas_drv_cb.PSTRB  <= req.PSTRB;
        end
        else begin
            vif.mas_drv_cb.PWDATA <= 'hz;
            vif.mas_drv_cb.PSTRB  <= 'hz;   // spec mandated — always 0 on reads
        end

        // Wait one clock to complete setup phase
        @(vif.mas_drv_cb);

        // --------------------------------------------------------
        // ACCESS PHASE — assert PENABLE, wait for PREADY
        // --------------------------------------------------------
        $cast(transfer_state, 2);
        vif.mas_drv_cb.PENABLE <= 1'b1;

        // Wait for PREADY with timeout guard
        fork : F_PREADY
            begin : pready_wait
                while(!vif.mas_drv_cb.PREADY)
                    @(vif.mas_drv_cb);
            end
            begin : pready_timeout
                repeat(`PREADY_MAX_WAIT) @(vif.mas_drv_cb);
                `uvm_warning("TIMEOUT_WARNING", $sformatf("[%s] PREADY not asserted within %0d cycles", trans, `PREADY_MAX_WAIT))
            end
        join_any
        disable F_PREADY;

        // Deasserting PENABLE after each transaction as per apb fsm
        vif.mas_drv_cb.PENABLE <= 1'b0;

    endtask

endclass : apb_master_drv

`endif