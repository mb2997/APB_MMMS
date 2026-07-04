`ifndef APB_MULTI_SLAVE_PWDATA_CORNER_RW_SEQS
`define APB_MULTI_SLAVE_PWDATA_CORNER_RW_SEQS

class apb_multi_slave_pwdata_corner_rw_seqs extends apb_master_seqs;

    `uvm_object_utils(apb_multi_slave_pwdata_corner_rw_seqs)

    function new (string name = "apb_multi_slave_pwdata_corner_rw_seqs");
        super.new(name);
    endfunction

    bit [`ADDR_WIDTH-1:0] save_addr_q [$];

    task body();

        apb_master_trans trans_hm;

        repeat(no_of_trans) begin

            $display("\n---------- apb_multi_slave_pwdata_corner_rw_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);

            trans_hm = apb_master_trans::type_id::create("trans_hm");

            //  correct UVM handshake order
            start_item(trans_hm);

            //  randomize after start_item — inline constraint as example
            if(!trans_hm.randomize() with {PWDATA dist {'0 := 25, '1 := 25, 1 := 25, 2**($size(PWDATA)-1) := 25}; PWRITE == 1;})
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")

            save_addr_q.push_back(trans_hm.PADDR);

            finish_item(trans_hm);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_master_trans::current_trans_m++;

        end
        
        repeat(no_of_trans) begin

            $display("\n---------- apb_multi_slave_pwdata_corner_rw_seqs transaction : %0d ----------\n", apb_master_trans::current_trans_m);

            trans_hm = apb_master_trans::type_id::create("trans_hm");

            //  correct UVM handshake order
            start_item(trans_hm);

            //  randomize after start_item — inline constraint as example
            if(!trans_hm.randomize() with {PWDATA dist {'0 := 25, '1 := 25, 1 := 25, 2**($size(PWDATA)-1) := 25}; PWRITE == 0;})
                `uvm_fatal(get_type_name(), "Randomization failed for master trans")

            trans_hm.PADDR = save_addr_q.pop_front();

            finish_item(trans_hm);

            `uvm_info(get_type_name(),
            $sformatf("Transaction-%0d sent from MASTER SEQS =\n%s", apb_master_trans::current_trans_m, trans_hm.sprint()), UVM_MEDIUM)

            //  increment after finish_item — transaction is done [fully sent]
            apb_master_trans::current_trans_m++;

        end

    endtask

endclass

`endif