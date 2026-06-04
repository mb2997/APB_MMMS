`ifndef APB_MASTER_SEQS
`define APB_MASTER_SEQS

class apb_master_seqs extends uvm_sequence #(apb_master_trans);

    `uvm_object_utils(apb_master_seqs)

    //  declare no_of_trans — configurable [adjustable] from test level
    int unsigned no_of_trans = 10;   // default value — overridable [changeable] per test

    function new(string name = "apb_master_seqs");
        super.new(name);
    endfunction

    task body();
        apb_master_trans trans_hm;   //  declare locally — fresh [new] each iteration

        repeat(no_of_trans) begin

            $display("\n---------- Master Transaction : %0d ----------\n", apb_master_trans::current_trans_m);

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

endclass : apb_master_seqs

`endif