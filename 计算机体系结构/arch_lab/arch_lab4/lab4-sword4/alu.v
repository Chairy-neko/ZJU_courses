`timescale 1ns / 1ps

`include "constants.vh"

module alu(
		input  wire [31:0] op1, op2,
		input  wire [ 5:0] opcode,
		output wire [31:0] out,
		output wire overflow,
		output wire zero
    );
	 
	 wire [31:0] res_and,res_or,res_add,res_sub,res_nor,res_slt,res_xor,res_srl,res_lui,res_sra,res_sll,res_sltu,res_subu,res_addu,shamt;
	 parameter one = 32'h00000001, zero_0 = 32'h00000000;
	 assign res_and = op1 & op2;
	 assign res_or = op1 | op2;
	 assign res_add = $signed(op1) + $signed(op2);
	 assign res_addu = op1 + op2;
	 assign res_sub = $signed(op1) - $signed(op2);
	 assign res_subu = op1 - op2;
	 assign res_nor = ~(op1 | op2);
	 assign res_xor = op1 ^ op2;
	 assign res_srl = op2 >> op1;//srl
	 assign res_slt =($signed(op1) < $signed(op2)) ? one : zero_0;
	 assign res_sltu =(op1 < op2) ? one : zero_0;
	 assign res_sll = op2 << op1;//sll
	 assign res_sra = op2 >>> op1;//sra
	 assign res_lui = op2 << 5'b10000;
	 
	 assign out = (opcode == `ALU_AND) ? res_and 
	 			: (opcode == `ALU_OR) ? res_or
				: (opcode == `ALU_ADD) ? res_add
				: (opcode == `ALU_XOR) ? res_xor
				: (opcode == `ALU_NOR) ? res_nor
				: (opcode == `ALU_SRL) ? res_srl
				: (opcode == `ALU_SUB) ? res_sub
				: (opcode == `ALU_SLT) ? res_slt
				: (opcode == `ALU_SLL) ? res_sll
				: (opcode == `ALU_SRA) ? res_sra
				: (opcode == `ALU_ADDU) ? res_addu
				: (opcode == `ALU_SUBU) ? res_subu
				: (opcode == `ALU_SLTU) ? res_slt
				: (opcode == `ALU_LUI) ? res_lui
				: (opcode == `ALU_NONE) ? zero_0
				: 32'hx;

	 assign zero = (out == 0) ? one : zero_0;
	 
endmodule