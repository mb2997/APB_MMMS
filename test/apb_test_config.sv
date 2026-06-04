`ifndef APB_TEST_CONFIG
`define APB_TEST_CONFIG

class apb_test_config extends uvm_object;

    //Factory registration
    `uvm_object_utils(apb_test_config)

    function new(string name = "apb_test_config");
        super.new(name);
    endfunction

    apb_env_config config_he;
    int no_of_slaves = 4;

endclass : apb_test_config

`endif