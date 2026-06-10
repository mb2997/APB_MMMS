`ifndef APB_SINGLE_SLAVE_MIN_MAX_MID_ADDR_SEQS
`define APB_SINGLE_SLAVE_MIN_MAX_MID_ADDR_SEQS

class apb_single_slave_min_max_mid_addr_seqs extends apb_master_seqs;

    `uvm_object_utils(apb_single_slave_min_max_mid_addr_seqs)
    `uvm_declare_p_sequencer(apb_master_seqr)

    int no_of_slaves;

    function new (string name = "apb_single_slave_min_max_mid_addr_seqs");
        super.new(name);
    endfunction

    task body();

        apb_master_trans trans_hm;
        no_of_slaves = p_sequencer.config_ht.no_of_slaves;

        repeat(no_of_trans) begin
            $display("\n---------- apb_single_slave_min_max_mid_addr_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);
            trans_hm = apb_master_trans::type_id::create("trans_hm");
            //  correct UVM handshake order
            start_item(trans_hm);
            //  randomize after start_item — inline constraint as example
            if (!trans_hm.randomize() with {
                PWRITE == 1;
                PADDR dist {0 := 20,
                            [1 : (((2**(`ADDR_WIDTH))-1)/no_of_slaves)-1] :/ 60,
                            ((2**(`ADDR_WIDTH))-1)/no_of_slaves := 20
                           };
                })
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")
            finish_item(trans_hm);
            `uvm_info(get_type_name(), $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)
            apb_master_trans::current_trans_m++;
        end
        
        repeat(no_of_trans) begin
            //  correct UVM handshake order
            start_item(trans_hm);
            //  randomize after start_item — inline constraint as example
            if (!trans_hm.randomize() with {
                PWRITE == 0;
                PADDR dist {0 := 20,
                            [1 : (((2**(`ADDR_WIDTH))-1)/no_of_slaves)-1] :/ 60,
                            ((2**(`ADDR_WIDTH))-1)/no_of_slaves := 20
                           };
                })
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")
            finish_item(trans_hm);
            `uvm_info(get_type_name(), $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)
            apb_master_trans::current_trans_m++;
        end

    endtask

endclass

`endif