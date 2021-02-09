`timescale 1ns / 1ps


module sim_mips;
	
	// Inputs
	reg debug_en;
	reg debug_step;
	reg [6:0] debug_addr;
	reg clk;
	reg rst;
	reg interrupter;
	
	// Outputs
	wire [31:0] debug_data;
	
	// Instantiate the Unit Under Test (UUT)
	arc_cpu_wrap uut (
		.debug_en(debug_en), 
		.debug_step(debug_step), 
		.debug_addr(debug_addr), 
		.debug_data(debug_data), 
		.clk(clk), 
		.rst(rst), 
		.interrupter(interrupter)
	);
	integer i;
	initial begin
		// Initialize Inputs
		debug_en = 0;
		debug_step = 0;
		// debug_addr = 1;
		clk = 0;
		rst = 0;
		interrupter = 0;

		#100 rst = 1;
		#100 rst = 0;
		
		
	end

	initial begin
		fork
			forever #10 clk = ~clk;
			forever #0 begin
				for(i = 0; i < 20; i = i + 1) begin
					debug_addr = i+1;
					#1;
				end
			end
		join
	end
	
	
	
	
endmodule
