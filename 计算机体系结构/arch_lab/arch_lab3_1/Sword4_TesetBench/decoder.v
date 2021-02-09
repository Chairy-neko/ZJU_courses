`timescale 1ns / 1ps

`include "constants.vh"

module decoder (
	input  wire [31:0] ir,
	input wire [31:0] pc_in,
	output wire [4:0] rs,
	output wire require_rs,
	output wire [4:0] rt,
	output wire require_rt,
	output wire [4:0] wd,
	output wire reg_write,
	output wire [31:0] imm,
	output wire [5:0] alu_op,
	//new port
	output wire data_in,//control data_in
	output wire jal,//control regDst
	output wire branch_en,
	output wire [31:0]branch_pc,
	output wire beq,
	output wire bne,
	output wire mem_w,
	output wire jr
);

	assign rs = ir[25:21];
	assign rt = ir[20:16];
	
	wire [4:0]rd;
	assign rd = ir[15:11];
	
	wire [31:0]simm;
	wire [31:0]uimm;
	wire [5:0]shamt;
	assign simm = {{16 {ir[15]}}, ir[15:0]};
	assign uimm = {{16'b0}, ir[15:0]};
	assign shamt = {{27'b0}, ir[10:6]};
	
	wire [31:0]branch;
	wire [31:0]j;
	assign branch = pc_in + {simm[29:0], 2'b0};
	assign j = {{pc_in[31:28]}, ir[25:0], 2'b0};
	
	wire[5:0]op;
	wire[5:0]func;
	wire[4:0]V0;
	assign op = ir[31:26];
	assign func = ir[5:0];
	assign V0 = 5'b1111;
	
	assign alu_op = 
			(op == `CODE_R_TYPE) ? (
				(func == `FUNCTION_ADD) ? `ALU_ADD 
				: (func == `FUNCTION_AND) ? `ALU_AND 
				: (func ==`FUNCTION_XOR) ? `ALU_XOR
				: (func == `FUNCTION_OR) ? `ALU_OR
				: (func == `FUNCTION_NOR) ? `ALU_NOR
				: (func == `FUNCTION_SUB) ? `ALU_SUB
				: (func == `FUNCTION_SLL) ? `ALU_SLL
				: (func == `FUNCTION_SLT) ? `ALU_SLT
				: (func == `FUNCTION_SRA) ? `ALU_SRA
				: (func == `FUNCTION_JR) ? `ALU_AND
				: (func == `FUNCTION_JALR) ? `ALU_AND
				: `ALU_NONE
			)
			: (op == `CODE_ADDI) ? `ALU_ADD
			: (op == `CODE_ANDI) ? `ALU_AND
			: (op == `CODE_ORI) ? `ALU_OR
			: (op == `CODE_XORI) ? `ALU_XOR
			: (op == `CODE_LUI) ? `ALU_LUI
			: (op == `CODE_SLTI) ? `ALU_SLT
			: (op == `CODE_LW) ? `ALU_ADD
			: (op == `CODE_SW) ? `ALU_ADD
			: (op == `CODE_BEQ) ? `ALU_SUB
			: (op == `CODE_BNE) ? `ALU_SUB
			: (op == `CODE_J) ? `ALU_AND
			: (op == `CODE_JAL) ? `ALU_AND
			: `ALU_NONE;
	
	assign imm = (
				(op == `CODE_ANDI)
				|| (op == `CODE_ORI)
				|| (op == `CODE_XORI)
				) ? uimm 
			: ((op == `CODE_R_TYPE) 
					&& (
						(func == `FUNCTION_SRA)
						|| (func == `FUNCTION_SLL)
					)
				) ?
			shamt : simm;
			
	assign reg_write = (
			(op == `CODE_BEQ)
			|| (op == `CODE_BNE)
			|| (op == `CODE_SW)
			|| (op == `CODE_J)
			|| ((op == `CODE_R_TYPE) && (func == `FUNCTION_JR))
			) ? 1'b0 : 1'b1;
			
	assign require_rs = 
			((op == `CODE_R_TYPE) 
			&& (
				(func == `FUNCTION_SRA)
				|| (func == `FUNCTION_SLL)
			)
			) ? 1'b0 : 1'b1;
	
	assign require_rt = (
			(op == `CODE_ADDI)
			|| (op == `CODE_ANDI)
			|| (op == `CODE_XORI)
			|| (op == `CODE_ORI)
			|| (op == `CODE_SLTI)
			|| (op == `CODE_LUI)
			|| (op == `CODE_SW)
			|| (op == `CODE_LW)
			) ? 1'b0 : 1'b1;
	
	assign wd = (
				((op == `CODE_R_TYPE) && (func ==  `FUNCTION_JALR))
				|| (op == `CODE_JAL)
			) ? V0 
			: ((op == `CODE_ADDI)
				|| (op == `CODE_ANDI)
				|| (op == `CODE_ORI)
				|| (op == `CODE_XORI)
				|| (op == `CODE_SLTI)
				|| (op == `CODE_LW)
				|| (op == `CODE_LUI)
			) ? rt : rd;

	assign branch_pc = 
			((op == `CODE_BEQ)
				|| (op == `CODE_BNE)
			) ? branch
			: ((op == `CODE_J)
				|| (op == `CODE_JAL)
			) ? j : 
			pc_in;

	assign branch_en = (branch_pc != pc_in);
			
	assign jr = (
			(op == `CODE_R_TYPE) && 
				(
					(func == `FUNCTION_JR)
					|| (func == `FUNCTION_JALR)
				)
			) ;

	assign jal = (
			((op == `CODE_R_TYPE) && (func ==  `FUNCTION_JALR))
			|| (op == `CODE_JAL));
	
	assign mem_w = (op == `CODE_SW);
	
	assign data_in = (op == `CODE_LW);
	
	assign beq = (op == `CODE_BEQ);
	
	assign bne = (op == `CODE_BNE);
	

endmodule
