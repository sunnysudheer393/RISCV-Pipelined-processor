//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Data_memory(
    input logic clk, rst,We,
    input logic [ADDR_WIDTH-1:0] Aa,
    input logic [DATA_WIDTH-1:0] Wd,
    output logic [DATA_WIDTH-1:0] Rd
);

logic [DATA_WIDTH-1:0] data_memory [MEMORY_SIZE-1:0];

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        for(int i = 0; i< MEMORY_SIZE; i++) data_memory[i] <= {DATA_WIDTH{1'b0}};
    end else if (We) begin
        data_memory[Aa[ADDR_WIDTH-1:2]] <= Wd;
    end
end

assign Rd = (rst)? data_memory[Aa[ADDR_WIDTH-1:2]] : {DATA_WIDTH{1'b0}};
    
// initial begin : data_memory_file
//     data_memory[28] = {DATA_WIDTH{1'b0}};
//     data_memory[40] = {DATA_WIDTH{1'b0}};
// end

endmodule
