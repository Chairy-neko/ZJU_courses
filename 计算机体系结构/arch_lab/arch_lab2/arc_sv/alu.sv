`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/17 20:15:07
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] op,
    output logic [31:0] o,
    output logic [31:0] of,
    output logic [31:0] zf
);

always_comb begin
    o <= a + b;
    of <= 0;
    zf <= (o == 0);
end

endmodule
