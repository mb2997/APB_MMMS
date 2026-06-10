`ifndef APB_SINGLE_SLAVE_RAND_RW_SEQS
`define APB_SINGLE_SLAVE_RAND_RW_SEQS

class apb_single_slave_rand_rw_seqs extends apb_master_seqs;

    `uvm_object_utils(apb_single_slave_rand_rw_seqs)

    function new (string name = "apb_single_slave_rand_rw_seqs");
        super.new(name);
    endfunction

    task body();

        apb_master_trans trans_hm;

        repeat(no_of_trans) begin

            $display("\n---------- apb_single_slave_rand_rw_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);

            trans_hm = apb_master_trans::type_id::create("trans_hm");

            //  correct UVM handshake order
            start_item(trans_hm);

            //  randomize after start_item — inline constraint as example
            if(!trans_hm.randomize())
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")

            finish_item(trans_hm);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_master_trans::current_trans_m++;

        end

    endtask

endclass

`endif