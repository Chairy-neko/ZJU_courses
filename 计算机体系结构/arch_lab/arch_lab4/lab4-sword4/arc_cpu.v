`timescale 1ns / 1ps

`include "constants.vh"

module arc_cpu (
	input  wire clk,
	input  wire aresetn,
	input  wire step,
	input  wire [31:0] chip_debug_in,
	output wire [31:0] chip_debug_out0,
	output wire [31:0] chip_debug_out1,
	output wire [31:0] chip_debug_out2,
	output wire [31:0] chip_debug_out3
);

	// cache control
	wire        port_B_ctrl;
	wire        icache_replace;
	wire [31:0] icache_B_addr;
	wire [31:0] icache_B_in;
	wire [31:0] icache_B_out;
	wire        dcache_replace;
	wire [31:0] dcache_B_addr;
	wire [31:0] dcache_B_in;
	wire [31:0] dcache_B_out;

	// stage registers

	wire [31:0] if_in_pc;
	wire [31:0] if_in_ir;
	reg [31:0] if_begin_pc;

	reg  [31:0] if_reg_pc;
	reg  [31:0] if_reg_ir;

	wire [31:0] if_out_pc;
	wire [31:0] if_out_ir;
	wire [31:0] ir;
	wire if_en;

	reg  [31:0] id_reg_pc;
	reg  [31:0] id_reg_ir;
	reg  [ 4:0] id_reg_wd;
	reg         id_reg_reg_write;

	wire [31:0] id_out_pc;
    wire [31:0] id_out_ir;
    wire [ 4:0] id_out_wd;
    wire        id_out_reg_write;
	wire        id_out_mem_w;
    wire [31:0] id_out_reg_value;
    wire [31:0] id_out_alu_src_a;
    wire [31:0] id_out_alu_src_b;
	wire        id_out_jal;
	wire        id_out_data_in;
    wire [ 5:0] id_out_alu_op;
	wire        id_out_branch_en;
	wire [31:0] id_out_branch_pc;
	wire	    id_en;
	wire	    id_rst;

	reg  [31:0] ex_reg_pc;
    reg  [31:0] ex_reg_ir;
    reg  [ 4:0] ex_reg_wd;
    reg         ex_reg_reg_write;
	reg         ex_reg_mem_w;
    reg  [31:0] ex_reg_reg_value;
    reg  [31:0] ex_reg_alu_src_a;
    reg  [31:0] ex_reg_alu_src_b;
	reg         ex_reg_jal;
	reg  	    ex_reg_data_in;
    reg  [ 5:0] ex_reg_alu_op;
	reg         ex_reg_branch_en;

    wire [31:0] ex_out_pc;
    wire [31:0] ex_out_ir;
    wire [ 4:0] ex_out_wd;
    wire        ex_out_reg_write;
	wire        ex_out_mem_w;
    wire [31:0] ex_out_reg_value;
    wire [31:0] ex_out_alu_out;
	wire        ex_out_jal;
	wire        ex_out_data_in;
	wire 		ex_rst;
	wire        ex_out_branch_en;

	reg  [31:0] me_reg_pc;
    reg  [31:0] me_reg_ir;
    reg  [ 4:0] me_reg_wd;
    reg         me_reg_reg_write;
	reg         me_reg_mem_w;
    reg  [31:0] me_reg_reg_value;
    reg  [31:0] me_reg_alu_out;
	reg         me_reg_jal;
	reg  	    me_reg_data_in;
	reg 		me_reg_branch_en;

    wire [31:0] me_out_pc;
    wire [31:0] me_out_ir;
    wire [ 4:0] me_out_wd;
    wire        me_out_reg_write;
	wire  	    me_out_data_in;
    wire [31:0] me_out_wb_data;
	wire [31:0] me_out_me_data;

	reg  [31:0] wb_reg_pc;
    reg  [31:0] wb_reg_ir;
    reg  [ 4:0] wb_reg_wd;
    reg         wb_reg_reg_write;
	reg  	    wb_reg_data_in;
    reg  [31:0] wb_reg_wb_data;
	reg         wb_reg_data;
	reg  [31:0] wb_reg_me_data;

	// Cache Output
    wire [31:0] icache_content, icache_tag;
    wire [31:0] dcache_content, dcache_tag;

	// regs
	reg [31:0] regs [31:0];

	// IF-in
	assign if_in_pc = id_out_branch_en ? id_out_branch_pc : if_reg_pc + 4;
	
	// IF
	always @(posedge clk) begin
		if (aresetn) begin
		  if(step && if_en && !cache_latch) begin
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
	
	wire icache_dirty_bit;
	wire [31:0] icache_tag_seq;

	my_icache icache_inst(
		.clka(~clk),
		.wea(1'b0),
		.addra(if_reg_pc[31:2]),
		.dina(),
		.douta(if_out_ir)
	);

	// Demo 
    // assign icache_tag_seq = icache_B_out[13:0];
    assign icache_dirty_bit = 1'b1;
    // assign dcache_tag_seq = dcache_B_out[13:0];
    // assign dcache_dirty_bit = 1'b0;

	assign if_out_pc = if_reg_pc;

	// ID
	always @(posedge clk) begin
		if (aresetn && ~id_rst) begin
		    if(step && id_en && !cache_latch) begin
			 id_reg_pc <= if_out_pc;
			 id_reg_ir <= if_out_ir;
			 id_reg_wd <= id_out_wd;
			 id_reg_reg_write <= id_out_reg_value;
			end else begin
			 id_reg_pc <= id_reg_pc;
			 id_reg_ir <= id_reg_ir;
			 id_reg_wd <= id_reg_wd;
			 id_reg_reg_write <= id_reg_reg_write;
			end
		end
		else begin
			id_reg_pc <= 0;
			id_reg_ir <= 0;
			id_reg_wd <= 0;
			id_reg_reg_write <= 0;
		end
	end

	wire [4:0] rs;
	wire [4:0] rt;
	wire [31:0] imm;
	
	wire require_rs;
	wire require_rt;
	wire beq;
	wire bne;
	wire jr;
	wire branch_en;
	wire [31:0]branch_pc;

	decoder decoder_inst(
		.ir(id_reg_ir),
		.pc_in(id_reg_pc),
		.wd_exe(ex_reg_wd),
		.wb_wen_exe(ex_reg_reg_write),
		.reg_exe(ex_out_alu_out[11:2]),
		.mem_w_exe(ex_reg_mem_w),
		.branch_exe(ex_reg_branch_en),
	    .wd_mem(me_reg_wd),
		.wb_wen_mem(me_reg_reg_write),
	    .branch_mem(me_reg_branch_en),
		.branch_id(id_out_branch_en),

		.rs(rs),
		.require_rs(require_rs),
		.rt(rt),
		.require_rt(require_rt),
		.wd(id_out_wd),
		.reg_write(id_out_reg_write),
		.imm(imm),
		.alu_op(id_out_alu_op),
		
		.data_in(id_out_data_in),
		.jal(id_out_jal),
		.branch_en(branch_en),
		.branch_pc(branch_pc),
		.beq(beq),
		.bne(bne),
		.mem_w(id_out_mem_w),
		.jr(jr),

		.if_en(if_en),
		.id_rst(id_rst),
		.id_en(id_en),
		.ex_rst(ex_rst)
	); 

	assign id_out_branch_en = (beq == 1'b1) ? ((regs[rs] == regs[rt]) && branch_en)
							: (bne == 1'b1) ? ((regs[rs] != regs[rt]) && branch_en)
							: (jr == 1'b1) ? 1 
							: branch_en;
	assign id_out_branch_pc = (jr == 1'b1) ? regs[rs] : branch_pc;
	assign id_out_pc = id_reg_pc;
	assign id_out_ir = id_reg_ir;
	assign id_out_reg_value = regs[rt];
	assign id_out_alu_src_a = (require_rs == 1'b1)?regs[rs]:imm;
	assign id_out_alu_src_b = (require_rt == 1'b1)?regs[rt]:imm;

	// EXE
	always @(posedge clk) begin
		if (aresetn) begin
			if (cache_latch) begin
				ex_reg_pc <= ex_reg_pc;
				ex_reg_ir <= ex_reg_ir;
				ex_reg_wd <= ex_reg_wd;
				ex_reg_reg_write <= ex_reg_reg_write;
				ex_reg_mem_w     <= ex_reg_mem_w;
				ex_reg_reg_value <= ex_reg_reg_value;
				ex_reg_alu_src_a <= ex_reg_alu_src_a;
				ex_reg_alu_src_b <= ex_reg_alu_src_b;
				ex_reg_jal 	  <= ex_reg_jal;
				ex_reg_data_in <= ex_reg_data_in;
				ex_reg_alu_op  <= ex_reg_alu_op;
				ex_reg_branch_en <= ex_reg_branch_en;
			end
			else if (ex_rst) begin
				ex_reg_pc <= 0;
				ex_reg_ir <= 0;
				ex_reg_wd <= 0;
				ex_reg_reg_write <= 0;
				ex_reg_mem_w     <= 0;
				ex_reg_reg_value <= 0;
				ex_reg_alu_src_a <= 0;
				ex_reg_alu_src_b <= 0;
				ex_reg_jal 	  <= 0;
				ex_reg_data_in <= 0;
				ex_reg_alu_op  <= 0;
				ex_reg_branch_en <= 0;
			end
			else if (step) begin
				ex_reg_pc <= id_out_pc;
				ex_reg_ir <= id_out_ir;
				ex_reg_wd <= id_out_wd;
				ex_reg_reg_write <= id_out_reg_write;
				ex_reg_mem_w     <= id_out_mem_w;
				ex_reg_reg_value <= id_out_reg_value;
				ex_reg_alu_src_a <= id_out_alu_src_a;
				ex_reg_alu_src_b <= id_out_alu_src_b;
				ex_reg_jal 	<= id_out_jal;
				ex_reg_data_in <= id_out_data_in;
				ex_reg_alu_op  <= id_out_alu_op;
				ex_reg_branch_en <= id_out_branch_en;
			end else begin
				ex_reg_pc <= ex_reg_pc;
				ex_reg_ir <= ex_reg_ir;
				ex_reg_wd <= ex_reg_wd;
				ex_reg_reg_write <= ex_reg_reg_write;
				ex_reg_mem_w     <= ex_reg_mem_w;
				ex_reg_reg_value <= ex_reg_reg_value;
				ex_reg_alu_src_a <= ex_reg_alu_src_a;
				ex_reg_alu_src_b <= ex_reg_alu_src_b;
				ex_reg_jal 	  <= ex_reg_jal;
				ex_reg_data_in <= ex_reg_data_in;
				ex_reg_alu_op  <= ex_reg_alu_op;
				ex_reg_branch_en <= ex_reg_branch_en;
			end
		end
		else begin
			ex_reg_pc <= 0;
			ex_reg_ir <= 0;
			ex_reg_wd <= 0;
			ex_reg_reg_write <= 0;
			ex_reg_mem_w     <= 0;
			ex_reg_reg_value <= 0;
			ex_reg_alu_src_a <= 0;
			ex_reg_alu_src_b <= 0;
			ex_reg_jal 	  <= 0;
			ex_reg_data_in <= 0;
			ex_reg_alu_op  <= 0;
			ex_reg_branch_en <= 0;
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
	assign ex_out_mem_w = ex_reg_mem_w;
	assign ex_out_reg_value = ex_reg_reg_value;
	assign ex_out_jal = ex_reg_jal;
	assign ex_out_data_in = ex_reg_data_in;

	// MEM
	always @(posedge clk) begin
		if (aresetn) begin
		  if(step && !cache_latch) begin
			me_reg_pc <= ex_out_pc; 
			me_reg_ir <= ex_out_ir; 
			me_reg_wd <= ex_out_wd; 
			me_reg_reg_write <= ex_out_reg_write; 
			me_reg_mem_w <= ex_out_mem_w;
			me_reg_reg_value <= ex_out_reg_value; 
			me_reg_alu_out <= ex_out_alu_out;
			me_reg_jal <= ex_out_jal;
			me_reg_data_in <= ex_out_data_in;
			me_reg_branch_en <= ex_out_branch_en;
		  end else begin
		    me_reg_pc <= me_reg_pc; 
			me_reg_ir <= me_reg_ir; 
			me_reg_wd <= me_reg_wd; 
			me_reg_reg_write <= me_reg_reg_write; 
			me_reg_mem_w <= me_reg_mem_w;
			me_reg_reg_value <= me_reg_reg_value; 
			me_reg_alu_out <= me_reg_alu_out; 
			me_reg_jal <= me_reg_jal;
			me_reg_data_in <= me_reg_data_in;//lw
			me_reg_branch_en <= me_reg_branch_en;
		  end
		end
		else begin
			me_reg_pc <= 0;
			me_reg_ir <= 0;
			me_reg_wd <= 0;
			me_reg_reg_write <= 0;
			me_reg_mem_w <= 0;
			me_reg_reg_value <= 0;
			me_reg_alu_out <= 0;
			me_reg_jal <= 0;
			me_reg_data_in <= 0;
			me_reg_branch_en <= 0;
		end
	end

	wire cache_read;//controll cache read
	wire cache_write;//controll cache write
	reg cache_temp;//make cache_stall last 1 step later
	wire cache_latch = cache_temp || cache_stall;
	wire cache_stall;//mark the stall caused by cache
	assign cache_read = me_reg_data_in;//lw
	assign cache_write = me_reg_mem_w;//sw

	always @(posedge clk) begin
		if(cache_stall)
			cache_temp = 1'b1;
		else
			cache_temp = 1'b0;
	end

	wire dcache_dirty_bit;
	wire dcache_valid_bit;
	wire [31:0] dcache_tag_seq;
	wire write_back;
	wire read_allocate;
	wire mem_read;
	wire mem_write;
	wire [31:0] mem_data_out;
	wire [31:0] mem_address;
	wire [31:0] mem_data_in;
	
	cache dcache(
		.clk(~clk), 
		.aresetn(aresetn), 
		.cache_write(cache_write), 
		.cache_read(cache_read), 
		.address(me_reg_alu_out), 
		.data_in(me_reg_reg_value), 
		.write_back(write_back), 
		.read_allocate(read_allocate), 
		.data_out(me_out_me_data), 
		.stall(cache_stall), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.mem_data_out(mem_data_out), 
		.mem_data_in(mem_data_in), 
		.mem_address(mem_address), 

		//debug
		.debug_cache_index(chip_debug_in[25:16]), 
		.debug_cache_dirty(dcache_dirty_bit), 
		.debug_cache_valid(dcache_valid_bit), 
		.debug_cache_tag(dcache_tag_seq[11:0]), 
		.debug_cache_data(dcache_B_out)
	);

	LatencyMemory memory(
		.clk(~clk), 
		.rst(~aresetn), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.mem_address(mem_address), 
		.mem_data_in(mem_data_in), 
		.mem_data_out(mem_data_out), 
		.write_back(write_back), 
		.read_allocate(read_allocate)
	);

    assign me_out_pc = me_reg_pc;
    assign me_out_ir = me_reg_ir;
    assign me_out_wd = me_reg_wd;
    assign me_out_reg_write = me_reg_reg_write;
	assign me_out_data_in = me_reg_data_in;
    assign me_out_wb_data = (me_reg_jal == 1'b1) ? me_reg_pc + 4 : 
							me_reg_alu_out;

	// WB
	always @(posedge clk) begin
		if (aresetn) begin
		  if (step) begin
			  if(cache_latch)begin
				wb_reg_pc <= 0;
				wb_reg_ir <= 0;
				wb_reg_wd <= 0;
				wb_reg_reg_write <= 0;
				wb_reg_wb_data <= 0;
				wb_reg_data_in <= 0;
				wb_reg_me_data <= 0;
			  end
			  else begin
				wb_reg_pc <= me_out_pc;
				wb_reg_ir <= me_out_ir;
				wb_reg_wd <= me_out_wd;
				wb_reg_reg_write <= me_out_reg_write;
				wb_reg_wb_data <= me_out_wb_data;
				wb_reg_data_in <= me_out_data_in;
				wb_reg_me_data <= me_out_me_data;
			  end
		  end else begin
		    wb_reg_pc <= wb_reg_pc;
			wb_reg_ir <= wb_reg_ir;
			wb_reg_wd <= wb_reg_wd;
			wb_reg_reg_write <= wb_reg_reg_write;
			wb_reg_wb_data <= wb_reg_wb_data;
			wb_reg_data_in <= wb_reg_data_in;
			wb_reg_me_data <= wb_reg_me_data;
		  end
		end
		else begin
			wb_reg_pc <= 0;
			wb_reg_ir <= 0;
			wb_reg_wd <= 0;
			wb_reg_reg_write <= 0;
			wb_reg_wb_data <= 0;
			wb_reg_data_in <= 0;
			wb_reg_me_data <= 0;
		end
	end
    
    // REG FILE
	integer i;

	always @(negedge clk) begin
		if (aresetn) begin
			if (step && wb_reg_reg_write && wb_reg_wd != 0) begin
				regs[wb_reg_wd] <= (wb_reg_data_in == 1'b1) ? wb_reg_me_data : wb_reg_wb_data;
			end
		end
		else begin
			for (i = 0; i < 32; i = i + 1) begin
				regs[i] <= 32'b0;
			end
		end
	end 

	// Icache Debug
    assign icache_content = icache_B_out[31:0];
    assign icache_tag = {6'b0, chip_debug_in[25:16], icache_tag_seq[11:0], 3'b0, icache_dirty_bit};
    // Dcache Debug
    assign dcache_content = dcache_B_out[31:0];
	assign dcache_tag = {6'b0, chip_debug_in[25:16], dcache_tag_seq[11:0], 2'b0, dcache_valid_bit, dcache_dirty_bit};

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

	assign chip_debug_out3 =   (chip_debug_in[11:10] == 0) ? dcache_content :
	                           (chip_debug_in[11:10] == 1) ? dcache_tag:dcache_content ;

	assign port_B_ctrl = chip_debug_in[12];

endmodule
