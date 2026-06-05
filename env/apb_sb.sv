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
    bit [`DATA_WIDTH-1:0] expected_data;
    bit [`DATA_WIDTH-1:0] actual_data;
    int no_of_wr;
    int no_of_rd;
    int no_of_wr_passed;
    int no_of_wr_failed;
    int no_of_rd_passed;
    int no_of_rd_failed;
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

        wait_for_reset(10);
        forever begin
            fork
                begin
                    data_from_mas_mon(trans_hm);
                end
                begin
                    foreach(trans_hs[i])
                    begin
                        automatic int ai = i;
                        fork
                            data_from_slv_mon(ai, trans_hs[ai]);
                        join_none
                    end
                end
            join
        end

    endtask

    task data_from_mas_mon(apb_master_trans trans_hm);
        mas_mon_fifo_h.get(trans_hm);
        `uvm_info(get_type_name(), $sformatf("Data received from master monitor = \n%s", trans_hm.sprint()), UVM_NONE)
    endtask
    
    task data_from_slv_mon(int slave_id, apb_slave_trans trans_hs);
        slv_mon_fifo_h[slave_id].get(trans_hs);
        `uvm_info(get_type_name(), $sformatf("Data received from slave monitor = \n%s", trans_hm.sprint()), UVM_NONE)
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("\n---------------------------------------\n\t    SIMULATION REPORT \t\t\n---------------------------------------");
        $display("Total Transactions = %0d",total_no_of_ops);
        $display("---------------------------------------");
        $display("WRITE Transactions : \n\t TOTAL\t\t= %0d \n\t SUCCEED\t= %0d \n\t FAILED\t\t= %0d",no_of_wr, no_of_wr_passed, no_of_wr_failed);
        $display("---------------------------------------");
        $display("READ  Transactions : \n\t TOTAL\t\t= %0d \n\t SUCCEED\t= %0d \n\t FAILED\t\t= %0d",no_of_rd, no_of_rd_passed, no_of_rd_failed);
        $display("\n---------------------------------------\n\t    COVERAGE REPORT \t\t\n---------------------------------------");
        // $display("Master IP Coverage = %.2f",apb_cvg_master.get_coverage());
        // $display("Slave  IP Coverage = %.2f",apb_cvg_slave.get_coverage());
        $display("---------------------------------------");
    endfunction

endclass : apb_sb

`endif