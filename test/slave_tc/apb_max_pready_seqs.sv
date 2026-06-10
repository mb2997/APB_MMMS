`ifndef APB_MAX_PREADY_SEQS
`define APB_MAX_PREADY_SEQS

class apb_max_pready_seqs extends apb_slave_seqs;

    `uvm_object_utils(apb_max_pready_seqs)

    function new (string name = "apb_max_pready_seqs");
        super.new(name);
    endfunction

    task body();

        apb_slave_trans trans_hs;

        repeat(no_of_trans) begin

            $display("\n---------- apb_max_pready_seqs transaction : %0d ----------\n", apb_slave_trans::current_trans_s);

            trans_hs = apb_slave_trans::type_id::create("trans_hs");

            trans_hs.c_wait_cycles.constraint_mode(0);
            trans_hs.c_wait_enable.constraint_mode(0);

            //  correct UVM handshake order
            start_item(trans_hs);

            //  randomize after start_item — inline constraint as example
            if(!trans_hs.randomize() with {wait_enable == 1; no_of_wait_cycles == `PREADY_MAX_WAIT-3;})
                `uvm_fatal(get_type_name(), "Randomization failed for slave trans")

            finish_item(trans_hs);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_slave_trans::current_trans_s, trans_hs.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_slave_trans::current_trans_s++;

        end

    endtask

endclass

`endif