`timescale 1ns / 1ps

module alu (
	input  wire [31:0] op1,
	input  wire [31:0] op2,
	input  wire [ 5:0] opcode,
	output wire [31:0] out,
	output wire overflow,
	output wire zero
);
    // assuem opcode == 0
	assign out = (opcode == 0) ? (op1 + op2) : 0;
	assign overflow = 0;
	assign zero = (out == 0);

endmodule
