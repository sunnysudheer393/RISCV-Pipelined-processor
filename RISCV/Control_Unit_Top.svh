//include library files main decoder and ALU decoder
`include "main_decoder.svh"
`include "ALU_decoder.svh"

module Control_Unit_Top(
    input logic Zero,
    input logic [6:0] Op, funct7,
    input logic [2:0] funct3,
    output logic ResultSrc,MemWrite, ALUSrc, RegWrite, Branch,
    output logic[1:0] ImmSrc,
    output logic [2:0] ALUControl
);
//logic Branch;
logic [1:0] ALUOp;

//assign PCSrc = Zero & Branch;

main_decoder decoder(
    .Op(Op),
    .funct3(funct3),
    .ResultSrc(ResultSrc), 
    .MemWrite(MemWrite), 
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite), 
    //.PCSrc(PCSrc),
    .ALUOp(ALUOp), 
    .ImmSrc(ImmSrc),
    //.ALUControl(ALUControl),
    .Branch(Branch)
);

ALU_decoder ALU_Dec(
    .ALUOp(ALUOp),
    .Op(Op),
    .funct7(funct7),
    .funct3(funct3),
    .ALUControl(ALUControl)

);


endmodule
