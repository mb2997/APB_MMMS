`define ADDR_WIDTH 8
`define DATA_WIDTH 32
`define STRB_WIDTH (`DATA_WIDTH/8) 
`define PREADY_MAX_WAIT 15
`define NO_OF_SLAVES 4
`define CYCLE 20

typedef enum bit [1:0] {
    BYTE      = 2'b00,   // 8-bit  transfer — 1 byte valid
    HALFWORD  = 2'b01,   // 16-bit transfer — 2 bytes valid
    WORD      = 2'b10    // 32-bit transfer — all 4 bytes valid
} transfer_size_e;

typedef enum bit [1:0] {IDLE,SETUP,ACCESS} state_e;
typedef enum bit [1:0] {NONE,READ,WRITE} trans_kind_e;