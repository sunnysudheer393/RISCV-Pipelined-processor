//`include "main_decoder.svh"
//`include "ALU_decoder.svh"
`include "ALU.svh"
`include "PC.svh"
`include "Control_Unit_Top.svh"
`include "PC_adder.svh"
`include "Instruction_Memory.svh"
`include "Register_file.svh"
`include "Data_memory.svh"
`include "Sign_Extend.svh"
`include "Mux.svh"
`include "cpu_parameters.svh"
import cpu_parameters::*;


module Single_Cycle_Top(
    input logic clk, rst

);
logic [DATA_WIDTH-1:0] Imm_Ext, PC_current, PC_next_mux, RDd, SrcA, SrcB, ALUResult, ReadData, PCPlus4, WriteData, Result;
logic Zero, PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, Carry, Overflow, Negative;
logic [IMM_SRC_WIDTH-1:0] ImmSrc;
logic [ALU_CONTROL_WIDTH-1:0] ALUControl;
logic [DATA_WIDTH-1:0] PCBranch;
logic Branch, stall = 1'b0; // Assuming no stalls for this single-cycle implementation
//logic [11:0] Sign_Ext, Imm_store;

Control_Unit_Top Control_Unit(
    .Zero(Zero),
    .Op(RDd[6:0]), 
    .funct7(RDd[31:25]),
    .funct3(RDd[14:12]),
    .PCSrc(PCSrc), 
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite),
    .Branch(Branch),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult)
);

Mux PC_mux(
    .a(PCPlus4),
    .b(PCBranch),
    .s(PCSrc),
    .out(PC_next_mux)
);

PC pc(
    .clk(clk), 
    .rst(rst),
    .stall(stall),
    .PC_next(PC_next_mux),
    .PC_p(PC_current)
);

PC_adder PC_address(
    .a(PC_current), 
    .b(32'd4),
    .s(PCPlus4)
);


Instruction_Memory Instr_mem(
    .clk(clk),
    .rst(rst),
    .Aa(PC_current),
    .RDd(RDd)
);


Sign_Extend sign_extd(
    .In(RDd),
    .ImmSrc(ImmSrc),
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


PC_adder Branch_address(
    .a(PC_current), 
    .b(Imm_Ext),
    .s(PCBranch)
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
