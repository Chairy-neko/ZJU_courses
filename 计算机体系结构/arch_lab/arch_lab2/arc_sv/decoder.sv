`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/17 17:30:31
// Design Name: 
// Module Name: decoder
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


module decoder(
    input  logic [31:0] ir,
    output logic [ 4:0] rs,
    output logic        require_rs,
    output logic [ 4:0] rt,
    output logic        require_rt,
    output logic [ 4:0] wd,
    output logic        reg_write,
    output logic [31:0] imm,
    output logic [ 5:0] alu_op
);

always_comb begin
    
    rs <= ir[25:21];
    require_rs <= 1'b1;
    rt <= ir[20:16];
    require_rt <= 1'b0;
    wd <= ir[20:16];
    
    reg_write <= ir[31:26] == 6'b001000;
    
    imm <= {{16{ir[15]}}, ir[15:0]};
    alu_op <= 6'b000000;    // This means Add in this demo, you can alter its meaning
    
end 

endmodule
