`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:33:33 11/13/2020
// Design Name:   decoder
// Module Name:   C:/depository/Arch/cpu_arc/arch_lab3_1/Sword4_TesetBench/sim_decoder.v
// Project Name:  sword4-test-bench
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: decoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim_decoder;

	// Inputs
	reg [31:0] ir;
	reg [31:0] pc_in;

	// Outputs
	wire [4:0] rs;
	wire require_rs;
	wire [4:0] rt;
	wire require_rt;
	wire [4:0] wd;
	wire reg_write;
	wire [31:0] imm;
	wire [5:0] alu_op;
	wire data_in;
	wire jal;
	wire mem_w;
	wire [31:0] pc_out;

	// Instantiate the Unit Under Test (UUT)
	decoder uut (
		.ir(ir), 
		.pc_in(pc_in), 
		.rs(rs), 
		.require_rs(require_rs), 
		.rt(rt), 
		.require_rt(require_rt), 
		.wd(wd), 
		.reg_write(reg_write), 
		.imm(imm), 
		.alu_op(alu_op), 
		.data_in(data_in), 
		.jal(jal), 
		.mem_w(mem_w), 
		.pc_out(pc_out)
	);

	initial begin
		// Initialize Inputs
		ir = 0;
		pc_in = 0;

		// Wait 100 ns for global reset to finish
		#40;
		ir	= 32'h3c060666; 
		#20;
		ir	= 32'h20010002;
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000;
		#20;
		ir	= 32'h2022000e;
		#20;
		ir	= 32'hac410008; 
		#20;
		ir	= 32'h34230004;
		#20;
		ir	= 32'h00010900;
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000;
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h8c24fff8; 
		#20;
		ir	= 32'h00010843;
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h10220005; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h20c6ffff; 
		#20;
		ir	= 32'h20010002;
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h1481fff4; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00000000; 
		#20;
		ir	= 32'h00423820;

        
		// Add stimulus here

	end
      
endmodule

