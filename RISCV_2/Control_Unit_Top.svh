//include library files main decoder and ALU decoder
//`include "main_decoder.svh"
//`include "ALU_decoder.svh"
//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Control_Unit_Top(
    input logic Zero,
    input logic [OPCODE_WIDTH-1:0] Op, 
    input logic [FUNCT7_WIDTH-1:0] funct7,
    input logic [FUNCT3_WIDTH-1:0] funct3,
    input logic [DATA_WIDTH-1:0] ALUResult,

    output logic ResultSrc,MemWrite, ALUSrc, RegWrite, Branch, PCSrc,
    output logic[IMM_SRC_WIDTH-1:0] ImmSrc,
    output logic [ALU_CONTROL_WIDTH-1:0] ALUControl
);
//logic Branch;
logic [ALU_OP_WIDTH-1:0] ALUOp;

//assign PCSrc = Branch && ALUResult[0]; // Assuming ALUResult[0] is the Zero flag for branch comparison
assign PCSrc = Zero & Branch;

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
