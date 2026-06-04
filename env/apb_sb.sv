`ifndef APB_SB
`define APB_SB

class apb_sb extends uvm_scoreboard;

    //Factory registration
    `uvm_component_utils(apb_sb)

    //Required instance of class
    apb_master_trans mas_mon_packet, trans_hm;
    apb_slave_trans slv_mon_packet, trans_hs;

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
    bit sample_cov;
    bit PWRITE;

    //memory model - associative array
    //bit [`DATA_WIDTH-1:0] mem_model [int];

    //Analysis FIFO declaration
    uvm_tlm_analysis_fifo #(apb_master_trans) mas_mon_fifo_h;
    uvm_tlm_analysis_fifo #(apb_slave_trans) slv_mon_fifo_h;

    covergroup apb_cvg_master with function sample(apb_master_trans trans_hm);

        M_RW        :   coverpoint trans_hm.PWRITE
                            {
                                bins PWRITE_LOW          = (1 => 0);
                                bins PWRITE_HIGH         = (0 => 1);
                            }
        
        // M_RESET     :   coverpoint trans_hm.PRESETn
        //                     {
        //                         bins PRESETn_LOW          = (1 => 0);
        //                         bins PRESETn_HIGH         = (0 => 1);
        //                     }

        M_PENABLE   :   coverpoint trans_hm.PENABLE
                            {
                                bins PENABLE_LOW          = (1 => 0);
                                bins PENABLE_HIGH         = (0 => 1);
                            }

        // M_PSEL      :   coverpoint trans_hm.PSEL
        //                     {
        //                         bins PSEL_LOW          = (1 => 0);
        //                         bins PSEL_HIGH         = (0 => 1);
        //                     }

        M_ADDR      :   coverpoint trans_hm.PADDR
                            {
                                bins PADDR_MIN       = {0};
                                bins PADDR_MID       = {[1:(('h2**(`ADDR_WIDTH-1))-1)]};
                                bins PADDR_MAX       = {(('h2**(`ADDR_WIDTH))-1)};
                            }
        
        M_DATA      :   coverpoint trans_hm.PWDATA
                            {
                                bins PWDATA_MIN       = {0};
                                bins PWDATA_MID       = {[1:(('h2**(`DATA_WIDTH-1))-1)]};
                                bins PWDATA_MAX       = {(('h2**(`DATA_WIDTH))-1)};
                            }
        
        cross trans_hm.PWRITE, trans_hm.PENABLE;

    endgroup : apb_cvg_master

    covergroup apb_cvg_slave with function sample(apb_slave_trans trans_hs);

        S_RW        :   coverpoint trans_hs.PWRITE
                            {
                                bins S_PWRITE_LOW         = (1 => 0);
                                bins S_PWRITE_HIGH        = (0 => 1);
                            }

        // S_RESET     :   coverpoint trans_hs.PRESETn
        //                     {
        //                         bins S_PRESETn_LOW          = (1 => 0);
        //                         bins S_PRESETn_HIGH         = (0 => 1);
        //                     }

        S_PENABLE   :   coverpoint trans_hs.PENABLE
                            {
                                bins S_PENABLE_LOW          = (1 => 0);
                                bins S_PENABLE_HIGH         = (0 => 1);
                            }

        // S_PSEL      :   coverpoint trans_hs.PSEL
        //                     {
        //                         bins S_PSEL_LOW          = (1 => 0);
        //                         bins S_PSEL_HIGH         = (0 => 1);
        //                     }

        S_ADDR      :   coverpoint trans_hs.PADDR
                            {
                                bins S_PADDR_MIN       = {0};
                                bins S_PADDR_MID       = {[1:(('h2**(`ADDR_WIDTH-1))-1)]};
                                bins S_PADDR_MAX       = {(('h2**(`ADDR_WIDTH))-1)};
                            }
        
        S_WDATA     :   coverpoint trans_hs.PWDATA
                            {
                                bins S_PWDATA_MIN       = {0};
                                bins S_PWDATA_MID       = {[1:(('h2**(`DATA_WIDTH-1))-1)]};
                                bins S_PWDATA_MAX       = {(('h2**(`DATA_WIDTH))-1)};
                            }

        S_RDATA     :   coverpoint trans_hs.PRDATA
                            {
                                bins S_PRDATA_MIN       = {0};
                                bins S_PRDATA_MID       = {[1:(('h2**(`DATA_WIDTH-1))-1)]};
                                bins S_PRDATA_MAX       = {(('h2**(`DATA_WIDTH))-1)};
                            }

    endgroup : apb_cvg_slave

    function new(string name = "apb_sb", uvm_component parent = null);
        super.new(name,parent);
        mas_mon_fifo_h = new("mas_mon_fifo_h",this);
        slv_mon_fifo_h = new("slv_mon_fifo_h",this);
        trans_hm = new("trans_hm");
        trans_hs = new("trans_hs");
        apb_cvg_master = new();
        apb_cvg_slave = new();
    endfunction

    task run_phase(uvm_phase phase);

        forever
        begin	
            fork
                begin
                    mas_mon_fifo_h.get(mas_mon_packet);
                
                end
                begin
                    slv_mon_fifo_h.get(slv_mon_packet);
                end
            join
            `uvm_info(get_type_name(), $sformatf("MASTER_MON_PKT = \n%s",mas_mon_packet.sprint()),UVM_MEDIUM)
            `uvm_info(get_type_name(), $sformatf("SLAVE_MON_PKT = \n%s",slv_mon_packet.sprint()),UVM_MEDIUM)
            // compare(mas_mon_packet,slv_mon_packet);
            apb_cvg_master.sample(mas_mon_packet);
            apb_cvg_slave.sample(slv_mon_packet);
        end
    endtask

    // task compare(apb_master_trans mas_pack, apb_slave_trans slv_pack);

    //     if(mas_pack.PWRITE == 1) 
    //         begin
    //             total_no_of_ops++;
    //             no_of_wr++;
    //             mem_model[mas_pack.PADDR] = mas_pack.PWDATA;
    //             if(mas_pack.PADDR == slv_pack.PADDR)
    //                 begin
    //                     if(mas_pack.PWDATA == slv_pack.PWDATA) 
    //                         begin
    //                             no_of_wr_passed++;
    //                             `uvm_info("SUCCESS",$sformatf("MASTER Write Address = %0h -> SLAVE Write Address = %0h",mas_pack.PADDR, slv_pack.PADDR),UVM_MEDIUM)
    //                             `uvm_info("SUCCESS",$sformatf("MASTER Write Data = %0h -> SLAVE Write Data = %0h",mas_pack.PWDATA, slv_pack.PWDATA),UVM_MEDIUM)
    //                         end
    //                     else
    //                         begin
    //                             no_of_wr_failed++;
    //                             `uvm_error("FAIL",$sformatf("MASTER Write Data = %0h -> SLAVE Write Data = %0h",mas_pack.PWDATA, slv_pack.PWDATA))
    //                         end
    //                 end
    //             else
    //                 begin
    //                     no_of_wr_failed++;
    //                     `uvm_error("FAIL",$sformatf("MASTER Write Address = %0h -> SLAVE Write Address = %0h",mas_pack.PADDR, slv_pack.PADDR))
    //                 end
    //         end
    //     else if(mas_pack.PWRITE == 0)
    //         begin		
    //             no_of_rd++;
    //             total_no_of_ops++;
    //             if(mas_pack.PADDR == slv_pack.PADDR)
    //                 begin
    //                     if(slv_pack.PRDATA == mem_model[slv_pack.PADDR])
    //                         begin
    //                             if(mas_pack.PRDATA == mem_model[slv_pack.PADDR])
    //                                 begin
    //                                     no_of_rd_passed++;
    //                                     `uvm_info("SUCCESS",$sformatf("MASTER Read Data = %0h -> SLAVE Read Data = %0h",mas_pack.PRDATA, mem_model[slv_pack.PADDR]),UVM_MEDIUM)
    //                                 end
    //                             else
    //                                 begin
    //                                     no_of_rd_failed++;
    //                                     `uvm_error("FAIL",$sformatf("MASTER Read Data = %0h -> SLAVE Read Data = %0h",mas_pack.PRDATA, mem_model[slv_pack.PADDR]))
    //                                 end
    //                         end
    //                     else
    //                         begin
    //                             no_of_rd_failed++;
    //                             `uvm_error("","SLV DIDNT SENT EXPECTED DATA TO MASTER")
    //                         end
    //                 end
    //             else
    //                 begin
    //                     no_of_rd_failed++;
    //                     `uvm_error("",$sformatf("MAS_ADDR = %0h -> SLV_ADDR = %0h , SLAVE & MAS ADDR MISMATCH",mas_pack.PADDR, slv_pack.PADDR))
    //                 end
    //         end

    // endtask : compare

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("\n---------------------------------------\n\t    SIMULATION REPORT \t\t\n---------------------------------------");
        $display("Total Transactions = %0d",total_no_of_ops);
        $display("---------------------------------------");
        $display("WRITE Transactions : \n\t TOTAL\t\t= %0d \n\t SUCCEED\t= %0d \n\t FAILED\t\t= %0d",no_of_wr, no_of_wr_passed, no_of_wr_failed);
        $display("---------------------------------------");
        $display("READ  Transactions : \n\t TOTAL\t\t= %0d \n\t SUCCEED\t= %0d \n\t FAILED\t\t= %0d",no_of_rd, no_of_rd_passed, no_of_rd_failed);
        $display("\n---------------------------------------\n\t    COVERAGE REPORT \t\t\n---------------------------------------");
        $display("Master IP Coverage = %.2f",apb_cvg_master.get_coverage());
        $display("Slave  IP Coverage = %.2f",apb_cvg_slave.get_coverage());
        $display("---------------------------------------");
    endfunction

endclass : apb_sb

`endif