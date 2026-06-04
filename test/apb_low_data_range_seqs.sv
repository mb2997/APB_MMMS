`ifndef APB_LOW_DATA_RANGE_SEQS
`define APB_LOW_DATA_RANGE_SEQS

class apb_low_data_range_seqs extends apb_master_seqs;
    //Factory registration
    `uvm_object_utils(apb_low_data_range_seqs)

    function new(string name = "apb_low_data_range_seqs");
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
                assert(trans_hm.randomize() with {PWDATA >= 0 && PWDATA <= (('h2**(`DATA_WIDTH))/4);});
                $cast(req,trans_hm.clone());
                start_item(req);
                `uvm_info(get_type_name(), $sformatf("Generated Data From Master SEQS = \n%s",req.sprint()),UVM_MEDIUM)
                finish_item(req);
                req.current_trans_m++;
            end
    endtask

endclass : apb_low_data_range_seqs

`endif