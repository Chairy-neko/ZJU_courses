`timescale 1ns / 1ps

module arc_cpu (
	input  wire clk,
	input  wire aresetn,
	input  wire step,
	output wire [31:0] address,
	output wire [31:0] data_out,
	input  wire [31:0] data_in,
	input  wire [31:0] chip_debug_in,
	output wire [31:0] chip_debug_out0,
	output wire [31:0] chip_debug_out1,
	output wire [31:0] chip_debug_out2,
	output wire [31:0] chip_debug_out3
);
	
	// stage registers
	wire [31:0] if_in_pc;
	wire [31:0] if_in_ir;
	reg  [31:0] if_reg_pc;
	reg  [31:0] if_reg_ir;

	wire [31:0] if_out_pc;
	wire [31:0] if_out_ir;

	reg  [31:0] id_reg_pc;
	reg  [31:0] id_reg_ir;

	wire [31:0] id_out_pc;
    wire [31:0] id_out_ir;
    wire [ 4:0] id_out_wd;
    wire        id_out_reg_write;
    wire [31:0] id_out_reg_value;
    wire [31:0] id_out_alu_src_a;
    wire [31:0] id_out_alu_src_b;
    wire [ 5:0] id_out_alu_op;

	reg  [31:0] ex_reg_pc;
    reg  [31:0] ex_reg_ir;
    reg  [ 4:0] ex_reg_wd;
    reg         ex_reg_reg_write;
    reg  [31:0] ex_reg_reg_value;
    reg  [31:0] ex_reg_alu_src_a;
    reg  [31:0] ex_reg_alu_src_b;
    reg  [ 5:0] ex_reg_alu_op;

    wire [31:0] ex_out_pc;
    wire [31:0] ex_out_ir;
    wire [ 4:0] ex_out_wd;
    wire        ex_out_reg_write;
    wire [31:0] ex_out_reg_value;
    wire [31:0] ex_out_alu_out;

	reg  [31:0] me_reg_pc;
    reg  [31:0] me_reg_ir;
    reg  [ 4:0] me_reg_wd;
    reg         me_reg_reg_write;
    reg  [31:0] me_reg_reg_value;
    reg  [31:0] me_reg_alu_out;

    wire [31:0] me_out_pc;
    wire [31:0] me_out_ir;
    wire [ 4:0] me_out_wd;
    wire        me_out_reg_write;
    wire [31:0] me_out_wb_data;

	reg  [31:0] wb_reg_pc;
    reg  [31:0] wb_reg_ir;
    reg  [ 4:0] wb_reg_wd;
    reg         wb_reg_reg_write;
    reg  [31:0] wb_reg_wb_data;

	// regs
	reg [31:0] regs [31:0];

	// IF-in
	assign if_in_pc = if_reg_pc + 4;

	// IF
	always @(posedge clk) begin
		if (aresetn) begin
		  if(step) begin
			if_reg_pc <= if_in_pc;
			if_reg_ir <= if_in_ir;
		  end else begin
		    if_reg_pc <= if_reg_pc;
			if_reg_ir <= if_reg_ir;
		  end
		end
		else begin
			if_reg_pc <= 0;
			if_reg_ir <= 0;
		end
	end
	
	icache icache_inst(
		.clka(clk),
		.rsta(~aresetn),
		.wea(1'b0),
		.addra(if_reg_pc[31:2]),
		.dina(),
		.douta(if_out_ir),

		.clkb(clk),
		.rstb(~aresetn),
		.web(1'b0),
		.addrb(),
		.dinb(),
		.doutb()
	);

	assign if_out_pc = if_reg_pc;

	// ID
	always @(posedge clk) begin
		if (aresetn) begin
		    if(step) begin
			 id_reg_pc <= if_out_pc;
			 id_reg_ir <= if_out_ir;
			end else begin
			 id_reg_pc <= id_reg_pc;
			 id_reg_ir <= id_reg_ir;
			end
		end
		else begin
			id_reg_pc <= 0;
			id_reg_ir <= 0;
		end
	end

	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] wd;
	wire [31:0] imm;

	decoder decoder_inst(
		.ir(id_reg_ir),
		.rs(rs),
		.require_rs(),
		.rt(rt),
		.require_rt(),
		.wd(id_out_wd),
		.reg_write(id_out_reg_write),
		.imm(imm),
		.alu_op(id_out_alu_op)
	);
	
	assign id_out_pc = id_reg_pc;
	assign id_out_ir = id_reg_ir;
	assign id_out_reg_value = regs[rt];
	assign id_out_alu_src_a = regs[rs];
	assign id_out_alu_src_b = imm;

	// EXE
	always @(posedge clk) begin
		if (aresetn) begin
		  if (step) begin
			ex_reg_pc <= id_out_pc;
			ex_reg_ir <= id_out_ir;
			ex_reg_wd <= id_out_wd;
			ex_reg_reg_write <= id_out_reg_write;
			ex_reg_reg_value <= id_out_reg_value;
			ex_reg_alu_src_a <= id_out_alu_src_a;
			ex_reg_alu_src_b <= id_out_alu_src_b;
			ex_reg_alu_op <= id_out_alu_op;
		  end else begin
		    ex_reg_pc <= ex_reg_pc;
			ex_reg_ir <= ex_reg_ir;
			ex_reg_wd <= ex_reg_wd;
			ex_reg_reg_write <= ex_reg_reg_write;
			ex_reg_reg_value <= ex_reg_reg_value;
			ex_reg_alu_src_a <= ex_reg_alu_src_a;
			ex_reg_alu_src_b <= ex_reg_alu_src_b;
			ex_reg_alu_op <= ex_reg_alu_op;
		  end
		end
		else begin
			ex_reg_pc <= 0;
			ex_reg_ir <= 0;
			ex_reg_wd <= 0;
			ex_reg_reg_write <= 0;
			ex_reg_reg_value <= 0;
			ex_reg_alu_src_a <= 0;
			ex_reg_alu_src_b <= 0;
			ex_reg_alu_op <= 0;
		end
	end

	alu alu_inst(
		.op1(ex_reg_alu_src_a),
		.op2(ex_reg_alu_src_b),
		.opcode(ex_reg_alu_op),
		.out(ex_out_alu_out),
		.overflow(),
		.zero()
	);
    
    assign ex_out_pc = ex_reg_pc;
    assign ex_out_ir = ex_reg_ir;
    assign ex_out_wd = ex_reg_wd;
	assign ex_out_reg_write = ex_reg_reg_write;
	assign ex_out_reg_value = ex_reg_reg_value;

	// MEM
	always @(posedge clk) begin
		if (aresetn) begin
		  if(step) begin
			me_reg_pc <= ex_out_pc; 
			me_reg_ir <= ex_out_ir; 
			me_reg_wd <= ex_out_wd; 
			me_reg_reg_write <= ex_out_reg_write; 
			me_reg_reg_value <= ex_out_reg_value; 
			me_reg_alu_out <= ex_out_alu_out; 
		  end else begin
		    me_reg_pc <= me_reg_pc; 
			me_reg_ir <= me_reg_ir; 
			me_reg_wd <= me_reg_wd; 
			me_reg_reg_write <= me_reg_reg_write; 
			me_reg_reg_value <= me_reg_reg_value; 
			me_reg_alu_out <= me_reg_alu_out; 
		  end
		end
		else begin
			me_reg_pc <= 0;
			me_reg_ir <= 0;
			me_reg_wd <= 0;
			me_reg_reg_write <= 0;
			me_reg_reg_value <= 0;
			me_reg_alu_out <= 0;
		end
	end
/*
	dcache dcache_inst(
		.clka(),
		.rsta(),
		.wea(),
		.addra(),
		.dina(),
		.douta(),

		.clkb(),
		.rstb(),
		.web(),
		.addrb(),
		.dinb(),
		.doutb()
	);
*/
    assign me_out_pc = me_reg_pc;
    assign me_out_ir = me_reg_ir;
    assign me_out_wd = me_reg_wd;
    assign me_out_reg_write = me_reg_reg_write;
    assign me_out_wb_data = me_reg_alu_out;

	// WB
	always @(posedge clk) begin
		if (aresetn) begin
		  if (step) begin
			wb_reg_pc <= me_out_pc;
			wb_reg_ir <= me_out_ir;
			wb_reg_wd <= me_out_wd;
			wb_reg_reg_write <= me_out_reg_write;
			wb_reg_wb_data <= me_out_wb_data;
		  end else begin
		    wb_reg_pc <= wb_reg_pc;
			wb_reg_ir <= wb_reg_ir;
			wb_reg_wd <= wb_reg_wd;
			wb_reg_reg_write <= wb_reg_reg_write;
			wb_reg_wb_data <= wb_reg_wb_data;
		  end
		end
		else begin
			wb_reg_pc <= 0;
			wb_reg_ir <= 0;
			wb_reg_wd <= 0;
			wb_reg_reg_write <= 0;
			wb_reg_wb_data <= 0;
		end
	end
    
    // REG FILE
    integer i;
    
	always @(posedge clk) begin
		if (aresetn) begin
			if (step && wb_reg_reg_write && wb_reg_wd != 0) begin
				regs[wb_reg_wd] <= wb_reg_wb_data;
			end
		end
		else begin
			for (i = 0; i < 32; i = i + 1) begin
				regs[i] <= 32'b0;
			end
		end
	end

	// Debug
	assign chip_debug_out0 =   regs[chip_debug_in[4:0]];
	assign chip_debug_out1 =   (chip_debug_in[7:5] == 0) ? if_reg_pc : 
	                           (chip_debug_in[7:5] == 1) ? id_reg_pc : 
	                           (chip_debug_in[7:5] == 2) ? ex_reg_pc : 
	                           (chip_debug_in[7:5] == 3) ? me_reg_pc : 
	                           wb_reg_pc;
    
    assign chip_debug_out2 =   (chip_debug_in[7:5] == 0) ? 0 : 
	                           (chip_debug_in[7:5] == 1) ? id_reg_ir : 
	                           (chip_debug_in[7:5] == 2) ? ex_reg_ir : 
	                           (chip_debug_in[7:5] == 3) ? me_reg_ir : 
	                           wb_reg_ir;
	                           
endmodule
