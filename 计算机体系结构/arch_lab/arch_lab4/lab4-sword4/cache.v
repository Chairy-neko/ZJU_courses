`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:18:03 01/10/2021 
// Design Name: 
// Module Name:    cache 
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
module cache(
        input clk,
        input aresetn,
        input cache_write, //write request
        input cache_read, //read request
        input [31:0] address,
        input [31:0] data_in,
        input write_back, //interact with memory
        input read_allocate,
        output reg [31:0] data_out,
        output reg stall,
        output reg mem_read,
        output reg mem_write,
        input [31:0] mem_data_out, //data get from memory
        output reg [31:0] mem_data_in, //data write back to memory
        output reg [31:0] mem_address, 
        //debug
        input [9:0]debug_cache_index,
        output debug_cache_dirty,
        output debug_cache_valid,
        output [11:0] debug_cache_tag,
        output [31:0] debug_cache_data
    );
    localparam S_IDLE = 3'b000, S_BACK = 3'b001, S_BACK_WAIT = 3'b010,
                S_FILL = 3'b011, S_FILL_WAIT = 3'b100, S_ERROR = 3'b101;

    wire hit;
    wire [6:0] cache_index;
    wire [22:0] cache_tag;
    wire cache_dirty;
    wire cache_valid;

    reg [2:0] state;
    reg [24:0] cache_tbl[127:0]; //tag-23, V, D 
    reg [31:0] data[127:0];
    
    assign cache_index = address[8:2];
    assign cache_tag = address[31:9];
    assign hit = (cache_tag == cache_tbl[cache_index][24:2]) && cache_tbl[cache_index][1];//equal && valid
    
    always @(posedge clk)begin
        if(aresetn)begin
            case (state)
                S_IDLE: begin
                    if(!cache_read && !cache_write)begin
                        state <= state; //keep the state
                    end
                    else begin
                        if(!hit)begin
                            if(cache_tbl[cache_index][0])//dirty
                                state <= S_BACK;
                            else 
                                state <= S_FILL;//011
                        end
                        else begin//hit
                            state <= state;
                        end
                    end
                end
                S_BACK: begin
                    if(write_back)
                        state <= S_BACK_WAIT;
                    else
                        state <= state;
                end
                S_BACK_WAIT: begin
                    state <= S_FILL;
                end
                S_FILL: begin
                    if(read_allocate)
                        state <= S_FILL_WAIT;
                    else    
                        state <= state;
                end
                S_FILL_WAIT: begin
                    state <= S_IDLE;
                end
                S_ERROR: state <= S_ERROR;
                default: state <= S_ERROR;
            endcase
        end
        else begin
            state <= S_IDLE;
        end
    end

    integer i;
    always @(posedge clk)begin
        if(aresetn)begin
            case (state)
                S_IDLE: begin
                    if(hit && cache_write) begin
                        cache_tbl[cache_index][0] <= 1'b1;
                        data[cache_index] <= data_in;
                    end
                end
                S_BACK,
                S_BACK_WAIT,
                S_FILL:;
                S_FILL_WAIT: begin
                    if (cache_write) begin
                        data[cache_index] <= data_in;
                        cache_tbl[cache_index][0] <= 1'b1;
                    end
                    else if (cache_read) begin
                        data[cache_index] <= mem_data_out; 
								cache_tbl[cache_index][0] <= 1'b0;
                    end
                    cache_tbl[cache_index][1] <= 1'b1;
                    cache_tbl[cache_index][24:2] <= cache_tag;
                end
                S_ERROR:;
                default:;
            endcase
        end
        else begin
            for(i = 0; i < 128; i = i+1)begin
                cache_tbl[i] <= 1'b0;
                data[i] <= 1'b0;
            end
        end
    end

    always @* begin
        mem_data_in = 'bx;
        mem_address = 'bx;
        stall = 1'b1;
        mem_write = 1'b0;
        mem_read = 1'b0;
        case (state)
            S_IDLE: begin
                data_out = data[cache_index];
                stall = 1'b0;
            end
            S_BACK: begin
                mem_write = 1'b1;
                mem_address = {cache_tbl[cache_index][24:2], cache_index};
                mem_data_in = data[cache_index];
            end 
            S_FILL: begin
                mem_read = 1'b1;
                mem_address = address >> 2;
            end
            S_BACK_WAIT:;
            S_FILL_WAIT: begin
                mem_address = address >> 2;
            end
            S_ERROR:;
            default:;
        endcase
    end

    //debug
    assign debug_cache_dirty = cache_tbl[debug_cache_index][0];
    assign debug_cache_valid = cache_tbl[debug_cache_index][1];
    assign debug_cache_tag = cache_tbl[debug_cache_index][13:2];
    assign debug_cache_data = data[debug_cache_index];
    assign cache_dirty = cache_tbl[cache_index][0];
    assign cache_valid = cache_tbl[cache_index][1];


endmodule
