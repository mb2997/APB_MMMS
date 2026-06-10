`ifndef APB_MULTI_SLAVE_MIN_MAX_MID_ADDR_SEQS
`define APB_MULTI_SLAVE_MIN_MAX_MID_ADDR_SEQS

class apb_multi_slave_min_max_mid_addr_seqs extends apb_master_seqs;

    `uvm_object_utils(apb_multi_slave_min_max_mid_addr_seqs)
    `uvm_declare_p_sequencer(apb_master_seqr)

    int no_of_slaves;

    function new (string name = "apb_multi_slave_min_max_mid_addr_seqs");
        super.new(name);
    endfunction

    task body();

        apb_master_trans trans_hm;
        no_of_slaves = p_sequencer.config_ht.no_of_slaves;

        for(int i=0; i < no_of_slaves; i++)
        begin
            repeat(no_of_trans) begin
                $display("\n---------- apb_multi_slave_min_max_mid_addr_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);
                trans_hm = apb_master_trans::type_id::create("trans_hm");
                //  correct UVM handshake order
                start_item(trans_hm);
                //  randomize after start_item — inline constraint as example
                if (!trans_hm.randomize() with {
                    PWRITE == 1;
                    PADDR dist {(i*((2**(`ADDR_WIDTH))/(no_of_slaves))) := 20,
                                [(i*((2**(`ADDR_WIDTH))/(no_of_slaves))) : ((i+1) * (2**(`ADDR_WIDTH) / no_of_slaves)) - 1] :/ 60,
                                ((i+1) * (2**(`ADDR_WIDTH) / no_of_slaves)) - 1 := 20
                            };
                    })
                    
                    `uvm_fatal(get_type_name(), "Randomization failed for master trans")
                finish_item(trans_hm);
                `uvm_info(get_type_name(), $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)
                apb_master_trans::current_trans_m++;
            end
        end
        
        for(int i=0; i < no_of_slaves; i++)
        begin
            repeat(no_of_trans) begin
                $display("\n---------- apb_multi_slave_min_max_mid_addr_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);
                trans_hm = apb_master_trans::type_id::create("trans_hm");
                //  correct UVM handshake order
                start_item(trans_hm);
                //  randomize after start_item — inline constraint as example
                if (!trans_hm.randomize() with {
                    PWRITE == 0;
                    PADDR dist {(i*((2**(`ADDR_WIDTH))/(no_of_slaves))) := 20, ((i+1) * (2**(`ADDR_WIDTH) / no_of_slaves)) - 1 := 20
                            };
                    })
                    
                    `uvm_fatal(get_type_name(), "Randomization failed for master trans")
                finish_item(trans_hm);
                `uvm_info(get_type_name(), $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)
                apb_master_trans::current_trans_m++;
            end
        end
    endtask

endclass

`endif