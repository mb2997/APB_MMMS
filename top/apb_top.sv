`include "apb_defs.sv"
import apb_pkg::*;

module apb_top();

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    logic clk = 0;
    logic rstn = 1;
    apb_inf inf(clk, rstn);
    apb_base_test test_hm;

    // Initial reset for all
    initial begin
        rstn = 0;
        @(negedge clk);
        @(negedge clk);
        rstn = 1;
    end

    initial
        forever
        begin
            #(`CYCLE/2) clk = ~clk;
        end

    initial
    begin
        uvm_config_db#(virtual apb_inf) :: set(null,"*","apb_inf",inf);
        run_test("apb_base_test");  
    end

endmodule : apb_top