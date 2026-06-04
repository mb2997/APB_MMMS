`ifndef APB_PREADY_WAIT_TIMEOUT_SEQS
`define APB_PREADY_WAIT_TIMEOUT_SEQS

class apb_pready_wait_timeout_seqs extends apb_slave_seqs;

    `uvm_object_utils(apb_pready_wait_timeout_seqs)

    apb_slave_trans trans_hs;
    
    function new(string name = "apb_pready_wait_timeout_seqs");
        super.new(name);
        uvm_root :: get().set_report_severity_id_override(UVM_ERROR,"TIMEOUT_ERROR",UVM_WARNING);
    endfunction

    task body();
        forever
            begin
                //`uvm_error("3ERROR","ERROR")
                trans_hs = apb_slave_trans :: type_id :: create("trans_hs");
                start_item(trans_hs);
                assert(trans_hs.randomize() with {no_of_wait_cycles > 20; wait_enable == 1;}); // with wait states
                fork : F4
                    begin
                        wait_for_pready();
                    end
                    begin
                        wait_for_posedge_clock(`PREADY_MAX_WAIT);
                        uvm_report_warning("TIMEOUT_ERROR","SLAVE is not generating TREADY - MAX_WAIT_TIME is DONE");
                    end
                join_any
                finish_item(trans_hs);
                disable F4;
            end
    endtask

endclass : apb_pready_wait_timeout_seqs

`endif