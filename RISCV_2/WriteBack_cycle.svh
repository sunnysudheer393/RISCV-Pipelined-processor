`include "cpu_parameters.sv"
import cpu_parameters::*;

module WriteBack_cycle(
    input logic clk, rst, 
    input logic ResultSrcW,
    input logic [DATA_WIDTH-1:0] ALUResultW, ReadDataW, PCPlus4W,

    output logic [DATA_WIDTH-1:0] ResultW

);

Mux Mux(
    .a(ALUResultW),
    .b(ReadDataW),
    .s(ResultSrcW),
    .out(ResultW)
);

endmodule
