`ifndef APB_SLAVE_SEQR
`define APB_SLAVE_SEQR

class apb_slave_seqr extends uvm_sequencer #(apb_slave_trans);

    //Factory registration
    `uvm_component_utils(apb_slave_seqr)

    function new(string name = "apb_slave_seqr", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass : apb_slave_seqr

`endif