`ifndef APB_MULTI_SLAVE_RAW_SEQS
`define APB_MULTI_SLAVE_RAW_SEQS

class apb_multi_slave_raw_seqs extends apb_master_seqs;

    `uvm_object_utils(apb_multi_slave_raw_seqs)

    function new (string name = "apb_multi_slave_raw_seqs");
        super.new(name);
    endfunction

    bit [`ADDR_WIDTH-1:0] addr_q [$];

    task body();

        apb_master_trans trans_hm;

        repeat(no_of_trans) begin

            $display("\n---------- apb_multi_slave_raw_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);

            trans_hm = apb_master_trans::type_id::create("trans_hm");

            //  correct UVM handshake order
            start_item(trans_hm);

            //  randomize after start_item — inline constraint as example
            if(!trans_hm.randomize() with {PWRITE==1;})
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")
            
            addr_q.push_back(trans_hm.PADDR);

            finish_item(trans_hm);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_master_trans::current_trans_m++;

        end
        
        repeat(no_of_trans) begin

            $display("\n---------- apb_multi_slave_raw_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);

            trans_hm = apb_master_trans::type_id::create("trans_hm");

            //  correct UVM handshake order
            start_item(trans_hm);

            //  randomize after start_item — inline constraint as example
            if(!trans_hm.randomize() with {PWRITE==0;})
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")
            
            trans_hm.PADDR = addr_q.pop_back();

            finish_item(trans_hm);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_master_trans::current_trans_m++;

        end

    endtask

endclass

`endif