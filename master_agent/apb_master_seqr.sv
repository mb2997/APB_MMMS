`ifndef APB_MASTER_SEQR
`define APB_MASTER_SEQR

class apb_master_seqr extends uvm_sequencer #(apb_master_trans);

    //Factory registration
    `uvm_component_utils(apb_master_seqr)

    function new(string name = "apb_master_seqr", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass : apb_master_seqr

`endif