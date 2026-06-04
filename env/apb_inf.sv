`include "../top/apb_defs.sv"

`ifndef APB_INF
`define APB_INF

interface apb_inf(input logic PCLK, input logic PRESETn);
    
    logic [`ADDR_WIDTH-1:0] PADDR;
    logic PSEL[`NO_OF_SLAVES];
    logic PENABLE;                          
    logic PWRITE;                           
    logic [`DATA_WIDTH-1:0] PWDATA;         
    logic [`STRB_WIDTH-1:0] PSTRB;
    logic PREADY;
    logic [`DATA_WIDTH-1:0] PRDATA;      
    logic PSLVERR;         
    
    clocking mas_drv_cb@(posedge PCLK);
        default input #1 output #1;
        output PWRITE;
        output PSTRB;
        output PENABLE;
        output PSEL;
        output PWDATA;
        output PADDR;
        input  PREADY;
        input  PRDATA;
        input  PSLVERR;
    endclocking

    clocking mas_mon_cb@(posedge PCLK);
        default input #1 output #1;
        input PWRITE;
        input PRESETn;
        input PENABLE;
        input PSTRB;
        input PSEL;
        input PWDATA;
        input PADDR;
        input PREADY;
        input PRDATA;
        input PSLVERR;
    endclocking

    clocking slv_drv_cb@(posedge PCLK);
        default input #1 output #1;
        input PWRITE;
        input PRESETn;
        input PENABLE;
        input PSTRB;
        input PSEL;
        input PWDATA;
        input PADDR;
        output PREADY;
        output PRDATA;
        output PSLVERR;
    endclocking

    clocking slv_mon_cb@(posedge PCLK);
        default input #1 output #1;
        input PWRITE;
        input PRESETn;
        input PENABLE;
        input PSEL;
        input PWDATA;
        input PADDR;
        input PSTRB;
        input PREADY;
        input PRDATA;
    endclocking

    modport MAS_DRV_MP(clocking mas_drv_cb);
    modport MAS_MON_MP(clocking mas_mon_cb);
    modport SLV_DRV_MP(clocking slv_drv_cb);
    modport SLV_MON_MP(clocking slv_mon_cb);

endinterface : apb_inf

`endif