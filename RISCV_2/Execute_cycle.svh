`include "cpu_parameters.svh"
import cpu_parameters::*;

module Execute_cycle(
    input logic clk, rst, RegWriteE, ResultSrcE, MemWriteE, BranchE, ALUSrcE,
    input logic [ALU_CONTROL_WIDTH-1:0] ALUControlE,
    input logic [DATA_WIDTH-1:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E, ResultW,
    input logic [REG_ADDR_WIDTH-1:0] RD_Ex, RS1_Ex, RS2_Ex,
    input logic [FWD_MUX_WIDTH-1:0] ForwardAE, ForwardBE,
    // Prediction info from Decode stage
    input logic predict_E,
    input logic [DATA_WIDTH-1:0] PC_E,

    output logic RegWriteM, ResultSrcM, MemWriteM, ZeroE, 
    output logic Mispredict_E,             // Misprediction detected
    output logic actual_taken_E,           // Actual branch outcome
    output logic update_en_E,              // Update enable for BHT/BTB (= BranchE)
    output logic [DATA_WIDTH-1:0] ALUResultM, WriteDataM, PCPlus4M, PCTargetE,
    output logic [REG_ADDR_WIDTH-1:0] RdM
);

logic Carry, Overflow, Negative, Zero, ZeroE_r;
logic [DATA_WIDTH-1:0] SrcAE, SrcBE, ALUResultE, WriteDataE;

logic RegWriteE_r, ResultSrcE_r, MemWriteE_r;
logic [DATA_WIDTH-1:0] WriteDataE_r, ALUResultE_r, PCPlus4E_r, SrcBE_wire;
logic [REG_ADDR_WIDTH-1:0] RdE_r;


Mux3_by_1 Mux_a(
    .a(RD1_Ex),
    .b(ResultW),
    .c(ALUResultM),
    .s(ForwardAE),
    .out(SrcAE)
);
Mux3_by_1 Mux_b(
    .a(RD2_Ex),
    .b(ResultW),
    .c(ALUResultM),
    .s(ForwardBE),
    .out(SrcBE_wire)
);

Mux ALU_mux(
    .a(SrcBE_wire),
    .b(Imm_Ext_E),
    .s(ALUSrcE),
    .out(SrcBE)
);

//assign SrcAE = RD1_E;

ALU ALU_E(
    .Aa(SrcAE),
    .Bb(SrcBE),
    .ALUControl(ALUControlE),
    .Result(ALUResultE),
    .Carry(Carry), 
    .Overflow(Overflow), 
    .Zero(Zero), 
    .Negative(Negative)
);

//assign PCTargetE = PC_Ex + Imm_Ext_E;

PC_adder pc_next(
    .a(PC_Ex), 
    .b(Imm_Ext_E),
    .s(PCTargetE)
);

// Branch prediction resolution
// ALUResultE[0] = 1 means branch condition is true (taken)
// BranchE = 1 means this is a branch instruction
assign actual_taken_E = ALUResultE[0] & BranchE;
assign Mispredict_E = BranchE & (predict_E ^ actual_taken_E);
assign update_en_E = BranchE;

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        RegWriteE_r <= 1'b0;
        ResultSrcE_r <= 1'b0;
        MemWriteE_r <= 1'b0;
        ALUResultE_r <= 32'h00000000;
        WriteDataE_r <= 32'h00000000;
        RdE_r <= 5'b0000;
        PCPlus4E_r <= 32'h00000000;
        ZeroE_r <= 1'b0;
    end else begin
        RegWriteE_r <= RegWriteE;
        ResultSrcE_r <= ResultSrcE;
        MemWriteE_r <= MemWriteE;
        ALUResultE_r <= ALUResultE;
        WriteDataE_r <= SrcBE_wire;
        RdE_r <= RD_Ex;
        PCPlus4E_r <= PCPlus4E;
        ZeroE_r <= Zero;
    end
end

//memory stage inputs and execute stage outputs
//assign WriteDataE = RD2_E;

assign RegWriteM = RegWriteE_r;
assign ResultSrcM = ResultSrcE_r;
assign MemWriteM = MemWriteE_r;
assign ALUResultM = ALUResultE_r;
assign WriteDataM = WriteDataE_r;
assign RdM = RdE_r;
assign PCPlus4M = PCPlus4E_r;

assign ZeroE = ZeroE_r;
// PCSrcE is now Mispredict_E - handled at top level

endmodule
