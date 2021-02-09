`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:16:32 01/12/2021 
// Design Name: 
// Module Name:    LatencyMemory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LatencyMemory(
        input clk,
        input rst,
        input mem_read,
        input mem_write,
        input [31:0] mem_address,
        input [31:0] mem_data_in,
        output [31:0] mem_data_out,
        output reg write_back,
        output reg read_allocate
    );

    integer i = 0;
    integer j = 0;
    always @(posedge clk) begin
        read_allocate <= 0;
        write_back <= 0;
        if(mem_read)begin
            i <= i+1;
        end
        if(i == 1)begin
            read_allocate <= 1;
            i <= 0;
        end
        if(mem_write)begin
            j <= j+1;
        end
        if (j == 1) begin
            write_back <= 1;
            j <= 0;
        end
    end


    memory_data memory_data_inst(
        .clka(clk),
		.rsta(rst),
		.wea(mem_write), 
		.addra(mem_address),
		.dina(mem_data_in), 
		.douta(mem_data_out),

		.clkb(clk),
		.rstb(rst),
		.web(1'b0),
		.addrb(),
		.dinb(),
		.doutb()
    );

endmodule
