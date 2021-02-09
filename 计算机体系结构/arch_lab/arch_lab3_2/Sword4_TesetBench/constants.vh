// EXE ALU operations
`define ALU_AND 0
`define ALU_OR 1
`define ALU_SLT 2
`define ALU_LUI 3
`define ALU_ADD 4
`define ALU_SUB 5
`define ALU_XOR 6
`define ALU_NOR 7
`define ALU_ADDU 8 
`define ALU_SUBU 9 
`define ALU_SLL 10 
`define ALU_SRL 11 
`define ALU_SRA 12 
`define ALU_NONE 13 
`define ALU_SLTU 14 

// instructions
   // bit 31:26 for instruction type
`define CODE_R_TYPE 6'b000000  // bit 5:0 for function type
// `define FUNCTION_SLL 6'b000000
// `define FUNCTION_SRL 6'b000010  // including ROTR(set bit 21)
`define FUNCTION_SRA 6'b000011
`define FUNCTION_JR 6'b001000
`define FUNCTION_JALR 6'b001001
`define FUNCTION_ADD 6'b100000
`define FUNCTION_SUB 6'b100010
`define FUNCTION_AND 6'b100100
`define FUNCTION_OR 6'b100101
`define FUNCTION_XOR 6'b100110
`define FUNCTION_NOR 6'b100111
`define FUNCTION_SLT 6'b101010
`define FUNCTION_SLL 6'b000000
`define FUNCTION_SRL 6'b000010
`define CODE_J 6'b000010
`define CODE_JAL 6'b000011
`define CODE_BEQ 6'b000100
`define CODE_BNE 6'b000101
`define CODE_ADDI 6'b001000
`define CODE_SLTI 6'b001010
`define CODE_ANDI 6'b001100
`define CODE_ORI 6'b001101
`define CODE_XORI 6'b001110
`define CODE_LUI 6'b001111
`define CODE_LW 6'b100011
`define CODE_SW 6'b101011


