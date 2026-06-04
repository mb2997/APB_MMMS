`ifndef APB_MID_RESET_SEQS
`define APB_MID_RESET_SEQS

class apb_mid_reset_seqs extends apb_master_seqs;
    //Factory registration
    `uvm_object_utils(apb_mid_reset_seqs)

    function new(string name = "apb_mid_reset_seqs");
        super.new(name);
    endfunction

    //Required instance of class
    apb_master_trans trans_hm;

    //Body task to randomize data and send to driver by hand-shaking process
    task body();
        trans_hm = apb_master_trans :: type_id :: create("trans_hm");
        repeat(no_of_trans)
            begin
                $display("\n-------------------- Master Transaction : %0d --------------------\n",req.current_trans_m);
                assert(trans_hm.randomize() with {PSEL == 1; conti_wr_conti_rd == 1;});
                $cast(req,trans_hm.clone());
                if(req.current_trans_m == (no_of_trans/2))
                    req.PRESETn = 0;
                else
                    req.PRESETn = 1;
                start_item(req);
                `uvm_info(get_type_name(), $sformatf("Generated Data From Master SEQS = \n%s",req.sprint()),UVM_MEDIUM)
                finish_item(req);
                req.current_trans_m++;
            end
    endtask

endclass : apb_mid_reset_seqs

`endif