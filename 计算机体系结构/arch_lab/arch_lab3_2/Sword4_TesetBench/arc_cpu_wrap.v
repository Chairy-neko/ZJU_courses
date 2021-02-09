/**
 * CPU wrapper
 * Author: SOL <3160105063@zju.edu.cn>
 */
`include "define.vh"
 
module arc_cpu_wrap (
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	input wire [6:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	input wire interrupter  // interrupt source, for future use
);

wire [31:0] out0, out1, out2, out3;
wire [31:0] in;

assign in = {24'b0, debug_addr[4], debug_addr[2:1], debug_addr[4:0]};

arc_cpu arc_cpu_inst(
    .clk(debug_en ? debug_step : clk),
    .aresetn(~rst),
    .step(1'b1),
    .chip_debug_in(in),
    .chip_debug_out0(out0),
    .chip_debug_out1(out1),
    .chip_debug_out2(out2),
    .chip_debug_out3(out3)
);

assign debug_data = 
    debug_addr[6:5] == 2'b00 ? out0 : 
    debug_addr[6:3] == 4'b0100 ? (
        debug_addr[0] ? out2 : out1
    ) :
    32'b0;

endmodule
