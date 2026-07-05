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

    // Assertions
    property one_bit_asserted_in_psel;
        @(posedge clk) disable iff (!inf.PRESETn)
        (inf.PENABLE && (!$isunknown(inf.PADDR))) |-> $onehot(inf.PSEL);
    endproperty

    ONE_BIT_ASSERTED_IN_PSEL: assert property (one_bit_asserted_in_psel);
    
    property read_with_unknown_strb;
        @(posedge clk) disable iff (!inf.PRESETn)
        (!inf.PWRITE && inf.PENABLE) |-> $isunknown(inf.PSTRB);
    endproperty

    READ_WITH_UNKNOWN_STRB: assert property (read_with_unknown_strb);
    
    property ready_signal_check;
        @(posedge clk) disable iff (!inf.PRESETn)
        $rose(inf.PENABLE) |-> s_eventually inf.PREADY
    endproperty

    READY_SIGNAL_CHECK: assert property (ready_signal_check);
    
    property ready_stable_check;
        @(posedge clk) disable iff (!inf.PRESETn)
        $rose(inf.PREADY) |-> (inf.PREADY) until $fell(inf.PENABLE);
    endproperty

    READY_STABLE_CHECK: assert property (ready_stable_check);

endmodule : apb_top