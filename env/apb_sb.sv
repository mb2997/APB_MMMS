`ifndef APB_SB
`define APB_SB

class apb_sb extends uvm_scoreboard;

    //Factory registration
    `uvm_component_utils(apb_sb)

    //Required instance of class
    apb_master_trans mas_mon_packet, trans_hm;
    apb_slave_trans slv_mon_packet, trans_hs[];
    apb_env_config config_he;

    //local variables
    bit [`DATA_WIDTH-1:0] exp_data_q [$];
    bit [`DATA_WIDTH-1:0] act_data_q [$];

    // Memory model
    bit [`DATA_WIDTH-1:0] mem_model[int];   // key=address, value=data
    int no_of_wr;
    int no_of_rd;
    int no_of_rd_passed;
    int no_of_rd_failed;
    int no_of_empty_read;
    int total_no_of_ops;

    //Analysis FIFO declaration
    uvm_tlm_analysis_fifo #(apb_master_trans) mas_mon_fifo_h;
    uvm_tlm_analysis_fifo #(apb_slave_trans) slv_mon_fifo_h[];

    function new(string name = "apb_sb", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mas_mon_fifo_h = new("mas_mon_fifo_h",this);
        trans_hm = apb_master_trans :: type_id :: create("trans_hm");
        if(!uvm_config_db #(apb_env_config) :: get(this, "", "apb_env_config", config_he))
            `uvm_fatal(get_type_name(), "Couldn't get apb_env_config in scoreboard")

        slv_mon_fifo_h = new[config_he.no_of_slaves];
        trans_hs = new[config_he.no_of_slaves];
        foreach(trans_hs[i])
            trans_hs[i] = apb_slave_trans :: type_id :: create($sformatf("trans_hs_%0d", i));
        foreach(slv_mon_fifo_h[i])
            slv_mon_fifo_h[i] = new($sformatf("slv_mon_fifo_h_%0d", i), this);
    endfunction

    task run_phase(uvm_phase phase);
        begin
            // Reading master monitor fifo continuously
            fork
                forever begin
                    wait_for_reset(10);
                    data_from_mas_mon(trans_hm);
                end
            join_none

            // Reading slave monitor fifo continuously
            fork
                foreach(trans_hs[i])
                begin
                    automatic int ai = i;
                    fork
                        begin
                            forever begin
                                wait_for_reset(10);
                                data_from_slv_mon(ai, trans_hs[i]);
                            end
                        end
                    join_none
                end
            join_none

            // Comparision logic
            fork
                forever begin
                    compare();
                end
            join_none
        end
    endtask

    task compare();
        wait(exp_data_q.size() > 0 && act_data_q.size() > 0);
        begin
            bit [`DATA_WIDTH-1:0] exp_data, act_data;
            act_data = act_data_q.pop_front();
            exp_data = exp_data_q.pop_front();
            if(exp_data == act_data)
            begin
                `uvm_info("SUCCEED! DATA MATCHED", $sformatf("Exp Data => 0x%x == Act Data => 0x%x", exp_data, act_data), UVM_MEDIUM)
                no_of_rd_passed++;
            end
            else
            begin
                `uvm_error("FAILED! DATA MIS-MATCHED", $sformatf("Exp Data => 0x%x != Act Data => 0x%x", exp_data, act_data))
                no_of_rd_failed++;
            end
        end
    endtask

    task data_from_mas_mon(apb_master_trans trans_hm);
        mas_mon_fifo_h.get(trans_hm);
        `uvm_info(get_type_name(), $sformatf("Data received from master monitor = \n%s", trans_hm.sprint()), UVM_MEDIUM)
        if(trans_hm.PSLVERR)
            `uvm_error(get_type_name(), "Invalid Transaction! PSLVERR is asserted from slave")
        else
        begin
            if(trans_hm.PENABLE && trans_hm.PREADY)
            begin
                if(!trans_hm.PWRITE)
                begin
                    if(!$isunknown(trans_hm.PRDATA))
                    begin
                        act_data_q.push_back(trans_hm.PRDATA);
                        `uvm_info(get_type_name(), $sformatf("act_data_q = %p", act_data_q), UVM_MEDIUM)
                    end
                end
            end
        end
    endtask
    
    task automatic data_from_slv_mon(int slave_id, apb_slave_trans trans_hs);
        slv_mon_fifo_h[slave_id].get(trans_hs);
        `uvm_info(get_type_name(), $sformatf("Data received from slave %0d monitor = \n%s", slave_id, trans_hs.sprint()), UVM_MEDIUM)
        populate_mem_model(trans_hs);
    endtask

    function void populate_mem_model(apb_slave_trans trans_hs);
        if(trans_hs.PENABLE && trans_hs.PREADY)
        begin
            if(trans_hs.PWRITE)
            begin
                //  byte-lane write — check each PSTRB bit
                for(int b = 0; b < `DATA_WIDTH/8; b++) 
                begin
                    if(trans_hs.PSTRB[b])
                        mem_model[trans_hs.PADDR][(b*8)+:8] = trans_hs.PWDATA[(b*8)+:8];
                    else
                        mem_model[trans_hs.PADDR][(b*8)+:8] = 0;
                end
                no_of_wr++;
            end
            else
            begin
                if(mem_model.exists(trans_hs.PADDR))
                begin
                    exp_data_q.push_back(mem_model[trans_hs.PADDR]);
                    `uvm_info(get_type_name(), $sformatf("exp_data_q = %p", exp_data_q), UVM_MEDIUM)
                    no_of_rd++;
                end
                else
                begin
                    `uvm_info(get_type_name(), "Data has not been written at desired location", UVM_MEDIUM)
                    no_of_empty_read++;
                    no_of_rd++;
                end
            end
            total_no_of_ops++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("\n---------------------------------------\n\t   | SIMULATION REPORT |\t\t\n---------------------------------------");
        $display("Total Transactions = %0d", total_no_of_ops);
        $display("WRITE Transactions : %0d", no_of_wr);
        $display("READ  Transactions : %0d", no_of_rd);
        $display("---------------------------------------");
        $display("\t  |SCOREBOARD Comparison|");
        $display("---------------------------------------");
        $display("MATCHED = %0d", no_of_rd_passed);
        $display("MIS-MATCHED = %0d", no_of_rd_failed);
        $display("READ REQUEST AT EMPTY LOCATION = %0d", no_of_empty_read);
        $display("---------------------------------------\n\t    COVERAGE REPORT \t\t\n---------------------------------------");
        // $display("Master IP Coverage = %.2f",apb_cvg_master.get_coverage());
        // $display("Slave  IP Coverage = %.2f",apb_cvg_slave.get_coverage());
        $display("---------------------------------------");
    endfunction

    function void final_phase(uvm_phase phase);
        foreach(mem_model[i])
        begin
            `uvm_info(get_type_name(), $sformatf("mem_model[%0d] = 0x%x", i, mem_model[i]), UVM_MEDIUM)
        end
    endfunction

endclass : apb_sb

`endif