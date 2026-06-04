`ifndef APB_MASTER_MON
`define APB_MASTER_MON

class apb_master_mon extends uvm_monitor;

    //Factory registration
    `uvm_component_utils(apb_master_mon)
    virtual apb_inf vif;

    //Required instance of class
    apb_master_trans trans_hm;
    apb_master_config config_hm;
    int no_of_pkt_sampled;

    //Analysis port declaration for connection of master monitor to scoreboard
    uvm_analysis_port #(apb_master_trans) mas_mon_ap;

    function new(string name = "apb_master_mon", uvm_component parent = null);
        super.new(name,parent);
        //New method for analysis port
        mas_mon_ap = new("mas_mon_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        trans_hm = apb_master_trans :: type_id :: create("trans_hm"); 
        //Get config_db to monitor class for required configuration
        if(!uvm_config_db #(apb_master_config) :: get(this,"","apb_master_config",config_hm))
            `uvm_fatal(get_type_name(),"Failed to get apb_config... Have you set it ?") 
        if(!uvm_config_db #(virtual apb_inf) :: get(this,"","apb_inf",vif))
            `uvm_fatal(get_type_name(),"Failed to get apb_inf... Have you set it ?") 
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        trans_hm = apb_master_trans::type_id::create("trans_hm");

        forever
        begin
            data_from_inf();
            `uvm_info(get_type_name(),$sformatf("Data Received at MASTER-MONITOR from SLAVE-DRIVER = \n%s",trans_hm.sprint()),UVM_MEDIUM)
            //send_to_sb();
        end

    endtask

    task data_from_inf();
        begin
            @(vif.PSEL or vif.PADDR or vif.PWDATA or vif.PWRITE or vif.PREADY or vif.PRDATA);
            
            @(posedge vif.PCLK);

            foreach(vif.PSEL[i])
                trans_hm.PSEL[i] = vif.PSEL[i];

            trans_hm.PADDR = vif.PADDR;
            trans_hm.PWDATA = vif.PWDATA;
            trans_hm.PWRITE = vif.PWRITE;
            
            wait(vif.PENABLE);
            wait(vif.PREADY);

            trans_hm.PENABLE = vif.PENABLE;
            trans_hm.PREADY = vif.PREADY;

            if(trans_hm.PWRITE == 0)
                trans_hm.PRDATA = vif.PRDATA;

            if(trans_hm.PENABLE && trans_hm.PREADY)
                begin
                    mas_mon_ap.write(trans_hm);
                    no_of_pkt_sampled++;
                    `uvm_info(get_type_name(),$sformatf("Data Sent from MASTER-MONITOR to SCOREBOARD = \n%s",trans_hm.sprint()),UVM_MEDIUM)
                end
        end
    endtask

    function void report_phase(uvm_phase  phase);
        super.report_phase(phase);
        `uvm_info(get_full_name(),$sformatf("num_of_packets_sampled %d",no_of_pkt_sampled),UVM_MEDIUM)
    endfunction

endclass : apb_master_mon

`endif