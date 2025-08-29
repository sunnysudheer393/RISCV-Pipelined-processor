`timescale 1ns/100ps

module MultCycle_pipeline_tb();
logic clk = 1'b0, rst;

// logic [31:0] PCTargetE; 
// logic PCSrcE;
// logic [31:0] InstrD,PC_De,PCPlus4D;

// logic RegWriteW, ZeroE;
// logic [31:0] ResultW;
// logic [4:0] RdW;

// logic RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE;
// logic [2:0] ALUControlE;
// logic [31:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E;
// logic [4:0] RD_Ex, RS1_Ex, RS2_Ex;

// logic [1:0] ForwardAE, ForwardBE;

// logic RegWriteM, ResultSrcM, MemWriteM; //ZeroE,
// logic [31:0] ALUResultM, WriteDataM, PCPlus4M;
// logic [4:0] RdM;

// fetch_cycle fetch_stage(.PCTargetE(PCTargetE), 
//     .clk(clk), .rst(rst), .PCSrcE(PCSrcE),
//     .InstrD(InstrD),.PC_De(PC_De),.PCPlus4D(PCPlus4D));

// Decode_cycle decode_stage(
//     .clk(clk), .rst(rst), .RegWriteW(RegWriteW), .ZeroE(ZeroE),
//     .RdW(RdW),
//     .InstrD(InstrD), .PC_De(PC_De), .PCPlus4D(PCPlus4D), .ResultW(ResultW),

//     .RegWriteE(RegWriteE), .ALUSrcE(ALUSrcE), .MemWriteE(MemWriteE), .ResultSrcE(ResultSrcE), .BranchE(BranchE),
//     .ALUControlE(ALUControlE),
//     .RD1_Ex(RD1_Ex), .RD2_Ex(RD2_Ex), .PC_Ex(PC_Ex), .Imm_Ext_E(Imm_Ext_E), .PCPlus4E(PCPlus4E),
//     .RD_Ex(RD_Ex),
//     .RS1_Ex(RS1_Ex), .RS2_Ex(RS2_Ex)
// );

// Forward_unit forward(
//     .rst(rst), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), 
//     .ALUResultM(ALUResultM), .ResultW(ResultW),
//     .RdM(RdM), .RdW(RdW),
//     .RS1_Ex(RS1_Ex), .RS2_Ex(RS2_Ex),

//     .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)

// );

// Execute_cycle execute_stage(
//     .clk(clk), .rst(rst), .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE), .BranchE(BranchE), .ALUSrcE(ALUSrcE),
//     .ALUControlE(ALUControlE),
//     .RD1_Ex(RD1_Ex), .RD2_Ex(RD2_Ex), .PC_Ex(PC_Ex), .Imm_Ext_E(Imm_Ext_E), .PCPlus4E(PCPlus4E), .ResultW(ResultW),
//     .RD_Ex(RD_Ex), .RS1_Ex(RS1_Ex), .RS2_Ex(RS2_Ex),
//     .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),

//     .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .MemWriteM(MemWriteM), .PCSrcE(PCSrcE), //ZeroE,
//     .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M), .PCTargetE(PCTargetE),
//     .RdM(RdM)
// );

initial begin : generate_clock
    forever #5 clk = ~clk;
end

Multicycle_pipeline_top pipeline(.clk(clk), .rst(rst));

initial begin : Stimulus_generation
    $timeformat(-9, 0, "ns");
    @(posedge clk);
    rst <= 1'b0;
    repeat(3) @(posedge clk);
    //#150;
    @(negedge clk);
    rst <= 1'b1;
    @(posedge clk);
    #500;
    disable generate_clock;
end

endmodule
