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
`include "cpu_parameters.svh"
import cpu_parameters::*;

module Multicycle_pipeline_top(
    input logic clk ,rst
);
logic [DATA_WIDTH-1:0] PCTargetE, InstrD, PC_De, PCPlus4D, ResultW, ALUResultM, WriteDataM, PCPlus4M, ALUResultW, ReadDataW;
logic [DATA_WIDTH-1:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E, PCPlus4W;
logic RegWriteW, RegWriteE, ResultSrcE, MemWriteE, BranchE, ALUSrcE, RegWriteM, ResultSrcM, MemWriteM, ResultSrcW;
logic [REG_ADDR_WIDTH-1:0] RdW, RdM, RD_Ex, RS1_Ex, RS2_Ex;
logic [ALU_CONTROL_WIDTH-1:0] ALUControlE;
logic [FWD_MUX_WIDTH-1:0] ForwardAE, ForwardBE;
logic ZeroE;

// Branch prediction signals
logic predict_D, predict_E;
logic [DATA_WIDTH-1:0] PC_D, PC_E;
logic Mispredict_E, actual_taken_E, update_en_E;
logic FlushE;

fetch_cycle fetch_stage( 
    .PCTargetE(PCTargetE), 
    .clk(clk), 
    .rst(rst), 
    .PCSrcE(FlushE),           // Use Mispredict_E for PC mux correction
    .FlushE(FlushE),
    // Branch predictor update signals from Execute stage
    .BranchE(BranchE),
    .PC_Ex(PC_Ex),
    .actual_taken_E(actual_taken_E),
    .InstrD(InstrD),
    .PC_De(PC_De),
    .PCPlus4D(PCPlus4D),
    // Prediction info passed to Decode stage
    .predict_D(predict_D),
    .PC_D(PC_D)
);

Decode_cycle decode_stage(
    .clk(clk), 
    .rst(rst), 
    .RegWriteW(RegWriteW),
    .ZeroE(ZeroE),
    .FlushE(FlushE),

    .RdW(RdW),
    .InstrD(InstrD), 
    .PC_De(PC_De), 
    .PCPlus4D(PCPlus4D), 
    .ResultW(ResultW),
    // Prediction info from Fetch stage
    .predict_D(predict_D),
    .PC_D(PC_D),
    
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
    .RS2_Ex(RS2_Ex),
    // Prediction info passed to Execute stage
    .predict_E(predict_E),
    .PC_E(PC_E)
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
    // Prediction info from Decode stage
    .predict_E(predict_E),
    .PC_E(PC_E),

    .RegWriteM(RegWriteM), 
    .ResultSrcM(ResultSrcM), 
    .MemWriteM(MemWriteM), 
    .ZeroE(ZeroE),
    .Mispredict_E(Mispredict_E),
    .actual_taken_E(actual_taken_E),
    .update_en_E(update_en_E),
    .ALUResultM(ALUResultM), 
    .WriteDataM(WriteDataM), 
    .PCPlus4M(PCPlus4M), 
    .PCTargetE(PCTargetE),
    .RdM(RdM)
);

assign FlushE = Mispredict_E; // Flush on misprediction, not on taken branches

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
