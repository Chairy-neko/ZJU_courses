`ifndef defs_vh
`define defs_vh

typedef struct packed {
    logic [31:0] pc;
} IFReg;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] ir;
} IDReg;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] ir;
    logic [ 4:0] wd;
    logic        reg_write;
    logic [31:0] reg_value;
    logic [31:0] alu_src_a;
    logic [31:0] alu_src_b;
    logic [ 5:0] alu_op;
} EXReg;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] ir;
    logic [ 4:0] wd;
    logic        reg_write;
    logic [31:0] reg_value;
    logic [31:0] alu_out;
} MEReg;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] ir;
    logic [ 4:0] wd;
    logic        reg_write;
    logic [31:0] wb_data;
} WBReg;

typedef enum logic [6:0] {
	/* basic calculate */
	OP_ADDI
} op_code_t;

`endif