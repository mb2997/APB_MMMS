`ifndef APB_SB
`define APB_SB

class apb_sb extends uvm_scoreboard;

    //Factory registration
    `uvm_component_utils(apb_sb)

    //Required instance of class
    apb_master_trans mas_mon_packet, trans_hm;
    apb_slave_trans slv_mon_packet, trans_hs;
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
        trans_hm = new("trans_hm");
        trans_hs = new("trans_hs");
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mas_mon_fifo_h = new("mas_mon_fifo_h",this);
        if(!uvm_config_db #(apb_env_config) :: get(this, "", "apb_env_config", config_he))
            `uvm_fatal(get_type_name(), "Couldn't get apb_env_config in scoreboard")
    endfunction

    task run_phase(uvm_phase phase);

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