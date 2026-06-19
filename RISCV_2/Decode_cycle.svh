`include "cpu_parameters.sv"
import cpu_parameters::*;

module Decode_cycle(
    input logic clk, rst, RegWriteW, ZeroE, FlushE,
    input logic [REG_ADDR_WIDTH-1:0] RdW,
    input logic [DATA_WIDTH-1:0] InstrD, PC_De, PCPlus4D, ResultW,
    // Prediction info from Fetch stage
    input logic predict_D,
    input logic [DATA_WIDTH-1:0] PC_D,

    output logic RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE,
    output logic [ALU_CONTROL_WIDTH-1:0] ALUControlE,
    output logic [DATA_WIDTH-1:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E,
    output logic [REG_ADDR_WIDTH-1:0] RD_Ex,
    output logic [REG_ADDR_WIDTH-1:0] RS1_Ex, RS2_Ex,
    // Prediction info passed to Execute stage
    output logic predict_E,
    output logic [DATA_WIDTH-1:0] PC_E
);

logic ResultSrcD, PCSrcD, MemWriteD, ALUSrcD, RegWriteD, BranchD;
logic [IMM_SRC_WIDTH-1:0] ImmSrcD;
logic [ALU_CONTROL_WIDTH-1:0] ALUControlD;
logic [DATA_WIDTH-1:0] RD1_De, RD2_De, Imm_Ext_D;

logic RegWriteD_r, ResultSrcD_r, MemWriteD_r, BranchD_r, ALUSrcD_r;
logic [ALU_CONTROL_WIDTH-1:0] ALUControlD_r;
logic [DATA_WIDTH-1:0] RD1_D_r, RD2_D_r, PCD_r, Imm_Ext_D_r, PCPlus4D_r;
logic [REG_ADDR_WIDTH-1:0] RdD_r, RS1De, RS2De, RS1_D_r, RS2_D_r;

// Prediction pipeline registers
logic predict_D_r;
logic [DATA_WIDTH-1:0] PC_D_r;

logic [DATA_WIDTH-1:0] ALUResultE; // Assuming ALUResultE is available for branch comparison in the Decode stage


Control_Unit_Top control_unit(
    .Zero(ZeroE),
    .Op(InstrD[6:0]), 
    .funct7(InstrD[31:25]),
    .funct3(InstrD[14:12]),
    .PCSrc(PCSrcD), 
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD), 
    .ALUSrc(ALUSrcD), 
    .RegWrite(RegWriteD),
    .Branch(BranchD),
    .ImmSrc(ImmSrcD),
    .ALUControl(ALUControlD),
    .ALUResult(ALUResultE) // Connect ALUResultE for branch comparison
);

Register_file registers(
    .a1(InstrD[19:15]), 
    .a2(InstrD[24:20]), 
    .a3(RdW),
    .Wd3(ResultW),
    .clk(clk),
    .rst(rst), 
    .We3(RegWriteW),
    .Rd1(RD1_De),
    .Rd2(RD2_De)
);

Sign_Extend sign_ext(
    .In(InstrD),
    .ImmSrc(ImmSrcD), //for branch and store instructions
    .Imm_Ext(Imm_Ext_D)

);

//assign RS1De = InstrD[19:15];
//assign RS2De = InstrD[24:20];

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        RegWriteD_r <= 1'b0;
        ResultSrcD_r <= 1'b0;
        MemWriteD_r <= 1'b0;
        BranchD_r <= 1'b0;
        ALUControlD_r <= 3'b000;
        ALUSrcD_r <= 1'b0;
        //ImmSrcD_r <= 2'b00;
        RD1_D_r <= 32'h00000000;
        RD2_D_r <= 32'h00000000;
        PCD_r <= 32'h00000000;
        RdD_r <= 5'b00000;
        Imm_Ext_D_r <= 32'h00000000;
        PCPlus4D_r <= 32'h00000000;
        RS1_D_r <= 5'h00;
        RS2_D_r <= 5'h00;
        predict_D_r <= 1'b0;
        PC_D_r <= 32'h00000000;
    end else if (FlushE) begin
        RegWriteD_r <= 1'b0;
        ResultSrcD_r <= 1'b0;
        MemWriteD_r <= 1'b0;
        BranchD_r <= 1'b0;
        ALUControlD_r <= 3'b000;
        ALUSrcD_r <= 1'b0;
        RD1_D_r <= 32'h00000000;
        RD2_D_r <= 32'h00000000;
        PCD_r <= 32'h00000000;
        RdD_r <= 5'b00000;
        Imm_Ext_D_r <= 32'h00000000;
        PCPlus4D_r <= 32'h00000000;
        RS1_D_r <= 5'h00;
        RS2_D_r <= 5'h00;
        predict_D_r <= 1'b0;
        PC_D_r <= 32'h00000000;
    end else begin
        RegWriteD_r <= RegWriteD;
        ResultSrcD_r <= ResultSrcD;
        MemWriteD_r <= MemWriteD;
        BranchD_r <= BranchD;
        ALUControlD_r <= ALUControlD;
        ALUSrcD_r <= ALUSrcD;
        RD1_D_r <= RD1_De;
        RD2_D_r <= RD2_De;
        PCD_r <= PC_De;
        RdD_r <= InstrD[11:7];
        Imm_Ext_D_r <= Imm_Ext_D;
        PCPlus4D_r <= PCPlus4D;
        // RS1_D_r <= RS1De;
        // RS2_D_r <= RS2De;
        RS1_D_r <= InstrD[19:15];
        RS2_D_r <= InstrD[24:20];
        predict_D_r <= predict_D;
        PC_D_r <= PC_D;
    end
end

//output Execute state signals
assign RegWriteE = RegWriteD_r;
assign ResultSrcE = ResultSrcD_r;
assign MemWriteE = MemWriteD_r;
assign BranchE = BranchD_r;
assign ALUControlE = ALUControlD_r;
assign ALUSrcE = ALUSrcD_r;
assign RD1_Ex = RD1_D_r;
assign RD2_Ex = RD2_D_r;
assign PC_Ex = PCD_r;
assign RD_Ex = RdD_r;
assign Imm_Ext_E = Imm_Ext_D_r;
assign PCPlus4E = PCPlus4D_r;
assign RS1_Ex = RS1_D_r;
assign RS2_Ex = RS2_D_r;
assign predict_E = predict_D_r;
assign PC_E = PC_D_r;

endmodule
