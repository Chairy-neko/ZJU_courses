`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/16 18:21:25
// Design Name: 
// Module Name: arc_cpu
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

`include "defs.vh" 

module arc_cpu(
    input  logic        clk,
    input  logic        aresetn,
    input  logic        step,

    output logic [31:0] address,
    output logic [31:0] data_out,
    input  logic [31:0] data_in,
    
    input  logic [31:0] chip_debug_in,
    output logic [31:0] chip_debug_out0,
    output logic [31:0] chip_debug_out1,
    output logic [31:0] chip_debug_out2,
    output logic [31:0] chip_debug_out3
);


IFReg if_in,  if_reg;
IDReg if_out, id_reg;
EXReg id_out, ex_reg;
MEReg ex_out, me_reg;
WBReg me_out, wb_reg;

// Regs

logic [31:0] regs [31:0];

// IF-in

assign if_in.pc = if_reg.pc + 4;

// IF
always_ff @ (posedge clk) begin
    if (aresetn)
        if_reg <= if_in;
    else
        if_reg <= 0;
end

icache icache_inst(
    .clka(clk),
    .rsta(~aresetn),
    .wea(1'b0),
    .addra(if_reg.pc[31:2]),
    .dina(),
    .douta(if_out.ir),
    
    .clkb(),
    .rstb(),
    .web(),
    .addrb(),
    .dinb(),
    .doutb()
);

always_comb begin
    if_out.pc <= if_reg.pc;
end

// ID
always_ff @ (posedge clk) begin
    if (aresetn)
        id_reg <= if_out;
    else
        id_reg <= 0;
end

logic [4:0] rs, rt, wd;
logic [31:0] imm;

decoder decoder_inst(
    .ir(id_reg.ir),
    .rs(rs),
    .require_rs(),
    .rt(rt),
    .require_rt(),
    .wd(id_out.wd),
    .reg_write(id_out.reg_write),
    .imm(imm),
    .alu_op(id_out.alu_op)
);

always_comb begin
    id_out.pc        <= id_reg.pc;
    id_out.ir        <= id_reg.ir;
    id_out.reg_value <= regs[rt];
    id_out.alu_src_a <= regs[rs];
    id_out.alu_src_b <= imm;
end

// EXE
always_ff @ (posedge clk) begin
    if (aresetn)
        ex_reg <= id_out;
    else
        ex_reg <= 0;
end

alu alu_inst(
    .a(ex_reg.alu_src_a),
    .b(ex_reg.alu_src_b),
    .op(ex_reg.alu_op),
    .o(ex_out.alu_out),
    .of(),
    .zf()
);

always_comb begin
    ex_out.pc        <= ex_reg.pc; 
    ex_out.ir        <= ex_reg.ir;
    ex_out.wd        <= ex_reg.wd;
    ex_out.reg_write <= ex_reg.reg_write;
    ex_out.reg_value <= ex_reg.reg_value;
end

// MEM
always_ff @ (posedge clk) begin
    if (aresetn)
        me_reg <= ex_out;
    else
        me_reg <= 0;
end

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

always_comb begin
    me_out.pc        <= me_reg.pc;
    me_out.ir        <= me_reg.ir;
    me_out.wd        <= me_reg.wd;
    me_out.reg_write <= me_reg.reg_write;
    me_out.wb_data   <= me_reg.alu_out;
end

// WB
always_ff @ (posedge clk) begin
    if (aresetn)
        wb_reg <= me_out;
    else
        wb_reg <= 0;
end

always_ff @ (posedge clk) begin
    if (aresetn) begin
        if (wb_reg.reg_write && wb_reg.wd != 0)
            regs[wb_reg.wd] <= wb_reg.wb_data;
    end
    else begin
        foreach (regs[i])
            regs[i] <= 32'b0;
    end
end

// Debug

/*    
    input  logic [31:0] chip_debug_in,
    output logic [31:0] chip_debug_out0, Output Reg[in[4:0]]
    output logic [31:0] chip_debug_out1, Output pc[in[7:5]]
    output logic [31:0] chip_debug_out2, Output ir[in[7:5]]
    output logic [31:0] chip_debug_out3, Output cusstomized data
*/

always_comb begin
    chip_debug_out0 <= regs[chip_debug_in[4:0]];
    
    case(chip_debug_in[7:5])
        0: begin chip_debug_out1 <= if_reg.pc; chip_debug_out2 <= 0; end
        1: begin chip_debug_out1 <= id_reg.pc; chip_debug_out2 <= id_reg.ir; end
        2: begin chip_debug_out1 <= ex_reg.pc; chip_debug_out2 <= ex_reg.ir; end
        3: begin chip_debug_out1 <= me_reg.pc; chip_debug_out2 <= me_reg.ir; end
        default: begin chip_debug_out1 <= wb_reg.pc; chip_debug_out2 <= wb_reg.ir; end
    endcase
end
    
endmodule
