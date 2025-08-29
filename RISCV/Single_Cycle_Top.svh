`include "main_decoder.svh"
`include "ALU_decoder.svh"
`include "ALU.svh"
`include "PC.svh"
`include "Control_Unit_Top.svh"
`include "PC_adder.svh"
`include "Instruction_Memory.svh"
`include "Register_file.svh"
`include "Data_memory.svh"
`include "Sign_Extend.svh"
`include "Mux.svh"


module Single_Cycle_Top(
    input logic clk, rst

);
logic [31:0] Imm_Ext, PC_p, RDd, SrcA, SrcB, ALUResult, ReadData, PCPlus4, WriteData, Result;
logic Zero, PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, Carry, Overflow, Negative;
logic [1:0] ImmSrc;
logic [2:0] ALUControl;
//logic [11:0] Sign_Ext, Imm_store;

Control_Unit_Top Control_Unit(
    .Zero(Zero),
    .Op(RDd[6:0]), 
    .funct7(RDd[31:25]),
    .funct3(RDd[14:12]),
    //.PCSrc(PCSrc), 
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl)
);

PC pc(
    .clk(clk), 
    .rst(rst),
    .PC_next(PCPlus4),
    .PC_p(PC_p)
);

PC_adder PC_address(
    .a(PC_p), 
    .b(32'h00000001),
    .s(PCPlus4)
);


Instruction_Memory Instr_mem(
    .rst(rst),
    .Aa(PC_p),
    .RDd(RDd)
);


Sign_Extend sign_extd(
    .In(RDd),
    .ImmSrc(ImmSrc[0]),
    .Imm_Ext(Imm_Ext)
);

Register_file Registers(
    .a1(RDd[19:15]),
    .a2(RDd[24:20]),
    .a3(RDd[11:7]),
    .Wd3(Result),
    .clk(clk),
    .rst(rst),
    .We3(RegWrite),
    .Rd1(SrcA),
    .Rd2(WriteData)
);

Mux ALU_mux(
    .a(WriteData),
    .b(Imm_Ext),
    .s(ALUSrc),
    .out(SrcB)
);

ALU ALU_Compute(
    .Aa(SrcA),
    .Bb(SrcB),
    .ALUControl(ALUControl),
    .Result(ALUResult),
    .Carry(Carry), 
    .Overflow(Overflow), 
    .Zero(Zero), 
    .Negative(Negative)
);

Data_memory Data_mem(
    .clk(clk), 
    .rst(rst),
    .We(MemWrite),
    .Aa(ALUResult), 
    .Wd(WriteData),
    .Rd(ReadData)
);

Mux data_mux(
    .a(ALUResult),
    .b(ReadData),
    .s(ResultSrc),
    .out(Result)
);


endmodule
