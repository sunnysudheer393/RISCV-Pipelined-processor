module Decode_cycle(
    input logic clk, rst, RegWriteW, ZeroE,
    input logic [4:0] RdW,
    input logic [31:0] InstrD, PC_De, PCPlus4D, ResultW,

    output logic RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE,
    output logic [2:0] ALUControlE,
    output logic [31:0] RD1_Ex, RD2_Ex, PC_Ex, Imm_Ext_E, PCPlus4E,
    output logic [4:0] RD_Ex,
    output logic [4:0] RS1_Ex, RS2_Ex
);

logic ResultSrcD, PCSrcD, MemWriteD, ALUSrcD, RegWriteD, BranchD;
logic [1:0] ImmSrcD;
logic [2:0] ALUControlD;
logic [31:0] RD1_De, RD2_De, Imm_Ext_D;

logic RegWriteD_r, ResultSrcD_r, MemWriteD_r, BranchD_r, ALUSrcD_r;
logic [2:0] ALUControlD_r;
logic [31:0] RD1_D_r, RD2_D_r, PCD_r, Imm_Ext_D_r, PCPlus4D_r;
logic [4:0] RdD_r, RS1De, RS2De, RS1_D_r, RS2_D_r;



Control_Unit_Top control_unit(
    //.Zero(ZeroE),
    .Op(InstrD[6:0]), 
    .funct7(InstrD[31:25]),
    .funct3(InstrD[14:12]),
   // .PCSrc(PCSrcD), 
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD), 
    .ALUSrc(ALUSrcD), 
    .RegWrite(RegWriteD),
    .Branch(BranchD),
    .ImmSrc(ImmSrcD),
    .ALUControl(ALUControlD)
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
    .In(InstrD[31:0]),
    .ImmSrc(ImmSrcD[0]),
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

endmodule
