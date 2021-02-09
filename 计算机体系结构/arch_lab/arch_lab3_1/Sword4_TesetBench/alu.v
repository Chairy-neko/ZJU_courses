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
	 reg [31:0] r;
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
	 assign out = r;
	 
	 always @(*)
		 case (opcode)
			`ALU_AND:  r = res_and;	
			`ALU_OR:   r = res_or;	
			`ALU_ADD:  r = res_add;
			`ALU_XOR:  r = res_xor;
			`ALU_NOR:  r = res_nor;
			`ALU_SRL:  r = res_srl;
			`ALU_SUB:  r = res_sub;	
			`ALU_SLT:  r = res_slt;
			`ALU_SLL:  r = res_sll;
			`ALU_SRA:  r = res_sra;
			`ALU_ADDU: r = res_addu;
			`ALU_SUBU: r = res_subu;
			`ALU_SLTU: r = res_sltu;
			`ALU_LUI:  r = res_lui;
			`ALU_NONE: r = 32'b0;
			default: r = 32'hx;
		 endcase
	 assign zero = (r == 0)? 1'b1: 1'b0;
	 
endmodule