`include "fetch_cycle.svh"
`include "Decode_cycle.svh"
`include "Execute_cycle.svh"
`include "Memory_cycle.svh"
`include "WriteBack_cycle.svh"
`include "PC.svh"
`include "PC_adder.svh"
`include "Mux.svh"
`include "Instruction_Memory.svh"
`include "Control_Unit_Top.svh"
`include "Register_file.svh"
`include "Sign_Extend.svh"
`include "ALU.svh"
`include "Data_memory.svh"
`include "Forward_unit.svh"
`include "Mux3_by_1.svh"

module Multicycle_pipeline_top(
    input logic clk ,rst
);
logic [31:0] PCTargetE, InstrD, PC_De, PCPlus4D, ResultW, ALUResultM, WriteDataM, PCPlus4M, ALUResultW, ReadDataW;
logic [31:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E, PCPlus4W;
logic PCSrcE, RegWriteW, RegWriteE, ResultSrcE, MemWriteE, BranchE, ALUSrcE, RegWriteM, ResultSrcM, MemWriteM, ResultSrcW;
logic [4:0] RdW, RdM, RD_Ex, RS1_Ex, RS2_Ex;
logic [2:0] ALUControlE;
logic [1:0] ForwardAE, ForwardBE;
logic ZeroE;

fetch_cycle fetch_stage( 
    .PCTargetE(PCTargetE), 
    .clk(clk), 
    .rst(rst), 
    .PCSrcE(PCSrcE),
    .InstrD(InstrD),
    .PC_De(PC_De),
    .PCPlus4D(PCPlus4D)
);

Decode_cycle decode_stage(
    .clk(clk), 
    .rst(rst), 
    .RegWriteW(RegWriteW),
    .RdW(RdW),
    .InstrD(InstrD), 
    .PC_De(PC_De), 
    .PCPlus4D(PCPlus4D), 
    .ResultW(ResultW),
    //.ZeroE(ZeroE),

    .RegWriteE(RegWriteE), 
    .ResultSrcE(ResultSrcE), 
    .MemWriteE(MemWriteE), 
    .BranchE(BranchE), 
    .ALUSrcE(ALUSrcE),
    .ALUControlE(ALUControlE),
    .RD1_Ex(RD1_Ex), 
    .RD2_Ex(RD2_Ex), 
    .PC_Ex(PC_Ex), 
    .Imm_Ext_E(Imm_Ext_E), 
    .PCPlus4E(PCPlus4E),
    .RD_Ex(RD_Ex),
    .RS1_Ex(RS1_Ex),
    .RS2_Ex(RS2_Ex)
);

Forward_unit forwarding(
    .rst(rst), 
    .RegWriteM(RegWriteM), 
    .RegWriteW(RegWriteW), 
    .ALUResultM(ALUResultM), 
    .ResultW(ResultW),
    .RdM(RdM), 
    .RdW(RdW),
    .RS1_Ex(RS1_Ex), 
    .RS2_Ex(RS2_Ex),

    .ForwardAE(ForwardAE), 
    .ForwardBE(ForwardBE)

);

Execute_cycle execute_stage(
    .clk(clk), 
    .rst(rst), 
    .RegWriteE(RegWriteE), 
    .ResultSrcE(ResultSrcE), 
    .MemWriteE(MemWriteE), 
    .BranchE(BranchE), 
    .ALUSrcE(ALUSrcE),
    .ALUControlE(ALUControlE),
    .RD1_Ex(RD1_Ex), 
    .RD2_Ex(RD2_Ex), 
    .PC_Ex(PC_Ex), 
    .Imm_Ext_E(Imm_Ext_E), 
    .PCPlus4E(PCPlus4E),
    .RD_Ex(RD_Ex),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .ResultW(ResultW),

    .RegWriteM(RegWriteM), 
    .ResultSrcM(ResultSrcM), 
    .MemWriteM(MemWriteM), 
    .PCSrcE(PCSrcE),
    .ALUResultM(ALUResultM), 
    .WriteDataM(WriteDataM), 
    .PCPlus4M(PCPlus4M), 
    .PCTargetE(PCTargetE),
    .RdM(RdM),
    .RS1_Ex(RS1_Ex),
    .RS2_Ex(RS2_Ex)
    //.ZeroE(ZeroE)
);

Memory_cycle memory_stage(
    .clk(clk), 
    .rst(rst), 
    .RegWriteM(RegWriteM), 
    .ResultSrcM(ResultSrcM), 
    .MemWriteM(MemWriteM),
    .ALUResultM(ALUResultM), 
    .WriteDataM(WriteDataM), 
    .PCPlus4M(PCPlus4M),
    .RdM(RdM),

    .RegWriteW(RegWriteW), 
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW), 
    .ReadDataW(ReadDataW), 
    .PCPlus4W(PCPlus4W),
    .RdW(RdW)
);

WriteBack_cycle writeback_stage(
    .clk(clk),
    .rst(rst),
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW), 
    .ReadDataW(ReadDataW), 
    .PCPlus4W(PCPlus4W),

    .ResultW(ResultW)

);

endmodule
