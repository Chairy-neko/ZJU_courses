`timescale 1ns / 1ps

module decoder (
	input  wire [31:0] ir,
	output wire [4:0] rs,
	output wire require_rs,
	output wire [4:0] rt,
	output wire require_rt,
	output wire [4:0] wd,
	output wire reg_write,
	output wire [31:0] imm,
	output wire [5:0] alu_op
);
	assign rs = ir[25:21];
	assign rt = ir[20:16];
	assign wd = ir[20:16];
	assign imm = {{16 {ir[15]}}, ir[15:0]};
	
	assign require_rs = 1'b1;  // You need to alter this in the future.
	assign require_rt = 1'b0;  // You need to alter this in the future.
	
	assign reg_write = (ir[31:26] == 6'b001000); // You need to alter this in the future.
	
	assign alu_op = 6'b000000;    // This means Add in this demo, you can alter its meaning

endmodule
