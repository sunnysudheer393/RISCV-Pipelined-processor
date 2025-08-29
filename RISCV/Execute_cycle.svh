module Execute_cycle(
    input logic clk, rst, RegWriteE, ResultSrcE, MemWriteE, BranchE, ALUSrcE,
    input logic [2:0] ALUControlE,
    input logic [31:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E, ResultW,
    input logic [4:0] RD_Ex, RS1_Ex, RS2_Ex,
    input logic [1:0] ForwardAE, ForwardBE,

    output logic RegWriteM, ResultSrcM, MemWriteM, PCSrcE, //ZeroE,
    output logic [31:0] ALUResultM, WriteDataM, PCPlus4M, PCTargetE,
    output logic [4:0] RdM
);

logic Carry, Overflow, Negative, Zero;
logic [31:0] SrcAE, SrcBE, ALUResultE, WriteDataE;

logic RegWriteE_r, ResultSrcE_r, MemWriteE_r;
logic [31:0] WriteDataE_r, ALUResultE_r, PCPlus4E_r, SrcBE_wire;
logic [4:0] RdE_r;

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

PC_adder pc_next(
    .a(PC_Ex), 
    .b(Imm_Ext_E),
    .s(PCTargetE)
);

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        RegWriteE_r <= 1'b0;
        ResultSrcE_r <= 1'b0;
        MemWriteE_r <= 1'b0;
        ALUResultE_r <= 32'h00000000;
        WriteDataE_r <= 32'h00000000;
        RdE_r <= 5'b0000;
        PCPlus4E_r <= 32'h00000000;
    end else begin
        RegWriteE_r <= RegWriteE;
        ResultSrcE_r <= ResultSrcE;
        MemWriteE_r <= MemWriteE;
        ALUResultE_r <= ALUResultE;
        WriteDataE_r <= SrcBE_wire;
        RdE_r <= RD_Ex;
        PCPlus4E_r <= PCPlus4E;
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

assign PCSrcE = Zero & BranchE;

endmodule
