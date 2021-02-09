`timescale 1ns / 1ps

`include "constants.vh"

module decoder (
	input  wire [31:0] ir,
	input wire [31:0] pc_in,
	input wire [4:0] wd_exe,
	input wire wb_wen_exe,
	input wire [10:0] reg_exe,
	input wire mem_w_exe,
	input wire branch_exe,
	input wire [4:0] wd_mem,
	input wire wb_wen_mem,
	input wire branch_mem,
	input wire branch_id,

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
	output wire jr,

	output reg if_en,
	output reg id_rst,
	output reg id_en,
	output reg ex_rst
);

	assign rs = ir[25:21];
	assign rt = ir[20:16];
	
	wire [4:0]rd;
	assign rd = ir[15:11];
	
	wire [31:0]simm;
	wire [31:0]uimm;
	wire [31:0]store;
	wire [5:0]shamt;
	assign simm = {{16 {ir[15]}}, ir[15:0]};
	assign uimm = {{16'b0}, ir[15:0]};
	assign shamt = {{27'b0}, ir[10:6]};
	assign store = rs + simm;

	wire [31:0]pc_4;
	wire [31:0]branch;
	wire [31:0]j;

	assign pc_4 = pc_in + 4;
	assign branch = pc_4 + {simm[29:0], 2'b0};
	assign j = {{pc_4[31:28]}, ir[25:0], 2'b0};
	
	wire[5:0]op;
	wire[5:0]func;
	wire[4:0]V0;
	assign op = ir[31:26];
	assign func = ir[5:0];
	assign V0 = 5'b11111;
	
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
				: (func == `FUNCTION_SRL) ? `ALU_SRL
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
			: (op == `CODE_JAL) ? `ALU_ADD
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
						|| (func == `FUNCTION_SRL)
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
				|| (func == `FUNCTION_SRL)
			)
			) ? 1'b0 : 1'b1;
	
	assign require_rt = (
			(op == `CODE_ADDI)
			|| (op == `CODE_ANDI)
			|| (op == `CODE_XORI)
			|| (op == `CODE_ORI)
			|| (op == `CODE_SLTI)
			|| (op == `CODE_LUI)
			|| (op == `CODE_LW)
			|| (op == `CODE_SW)
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
			) ? j : pc_in;

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
	
	//pipeline control
	reg reg_stall;
	reg branch_stall;
	
	always @(*) begin
		reg_stall = 0;
		//rs
		if(require_rs && rs != 0)begin
			if ((wd_exe == rs) && wb_wen_exe) begin
				reg_stall = 1;
			end
			else if ((wd_mem == rs) && wb_wen_mem) begin
				reg_stall = 1;
			end
			else if ((reg_exe == store[11:2]) && mem_w_exe) begin
				reg_stall = 1;
			end
		end
		 //rt
		if((require_rt || mem_w)&& rt != 0)begin//sw use rt but src_b is not rt
			if((wd_exe == rt) && wb_wen_exe)begin
				reg_stall = 1;
			end
			else if ((wd_mem == rt) && wb_wen_mem) begin
				reg_stall = 1;
			end
		end
	end

	always @(*) begin
		branch_stall = 0;
		if(branch_id)
			branch_stall =1;
	end

	always @(*)begin
		if_en = 1;
		id_en = 1;
		id_rst = 0;
		ex_rst = 0;
		if(reg_stall)begin
			if_en = 0;
			id_en = 0;
			ex_rst = 1;
		end
		//this stall indicate that a jump/branch instruction is running, so 1 NOP should be inserted between IF and ID
		else if(branch_stall)begin
			id_rst = 1;
		end
	end

endmodule
