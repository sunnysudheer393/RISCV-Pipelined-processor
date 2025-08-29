module WriteBack_cycle(
    input logic clk, rst, 
    input logic ResultSrcW,
    input logic [31:0] ALUResultW, ReadDataW, PCPlus4W,

    output logic [31:0] ResultW

);

Mux Mux(
    .a(ALUResultW),
    .b(ReadDataW),
    .s(ResultSrcW),
    .out(ResultW)
);

endmodule
