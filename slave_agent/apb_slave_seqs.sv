`ifndef APB_SLAVE_SEQS
`define APB_SLAVE_SEQS

// ----------------------------------------------------------------
// Base slave sequence — flexible [adaptable], no hardcoded constraints
// ----------------------------------------------------------------
class apb_slave_seqs extends uvm_sequence #(apb_slave_trans);

    `uvm_object_utils(apb_slave_seqs)

    function new(string name = "apb_slave_seqs");
        super.new(name);
    endfunction

    task body();
        apb_slave_trans trans_hs;   // ✅ local — fresh object every iteration

        forever begin
            trans_hs = apb_slave_trans::type_id::create("trans_hs");

            // ✅ correct handshake order
            start_item(trans_hs);

            // ✅ fatal on failure — don't silently swallow [ignore] randomization errors
            if(!trans_hs.randomize())
                `uvm_fatal(get_type_name(), "Slave trans randomization failed")

            finish_item(trans_hs);

            `uvm_info(get_type_name(),
                $sformatf("Slave transaction sent =\n%s", trans_hs.sprint()),
                UVM_HIGH)

            apb_slave_trans::current_trans_s++;
        end
    endtask

endclass : apb_slave_seqs

`endif