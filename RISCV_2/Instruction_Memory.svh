//`timescale 1ns/100ps
//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Instruction_Memory(
    input logic clk, rst,
    input logic [ADDR_WIDTH-1:0] Aa,
    output logic [DATA_WIDTH-1:0] RDd
);
logic[DATA_WIDTH-1:0] mem[MEMORY_SIZE-1:0]; //this can store 1024 instructions of DATA_WIDTH bit each

assign RDd = (rst)? mem[Aa[ADDR_WIDTH-1:2]] : {DATA_WIDTH{1'b0}}; // Output the instruction at the given address, word-aligned

initial begin : memfile
    $readmemh("memfile.hex", mem);
end

// always_ff @(posedge clk) begin
//     $readmemh("memfile.hex",mem);
//     // $display("Memory Contents:");
//     // for (int i = 0; i < 7; i++) begin // Assuming you want to see the first 7 entries
//     //     $display("mem[%0d] = %h", i, mem[i]);
//     // end
//     // mem[0] = 32'h0;
//     // mem[0] = 32'hFFC4A303;
//     // //#20;
//     // mem[1] = 32'h00832383;
//     // mem[2] = 32'h0062E3B3;
//     // mem[3] = 32'h0064A423;
//     // mem[4] = 32'h0064E3B2;
//     // mem[5] = 32'h003256A5;
//     // mem[6] = 32'hFFCA3054;
//     // mem[7] = 32'hE432FFCC;

// end




endmodule
