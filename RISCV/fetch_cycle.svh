module fetch_cycle( 
    input logic [31:0] PCTargetE, 
    input logic clk, rst, PCSrcE = 1'b0,
    output logic [31:0] InstrD,PC_De,PCPlus4D
);

logic[31:0] PC_Fe, PCF_next, InstrF, PCPlus4F;
logic [31:0] InstrF_reg, PCF_reg, PCPlus4F_reg;

Mux PC_Mux(
    .a(PCPlus4F),
    .b(PCTargetE),
    .s(PCSrcE),
    .out(PCF_next)
);

PC PC_for_next(
    .clk(clk), 
    .rst(rst),
    .PC_next(PCF_next),
    .PC_p(PC_Fe)
);

Instruction_Memory Instr_mem(
    .rst(rst),
    .Aa(PC_Fe),
    .RDd(InstrF)
);

PC_adder PC_next_Addr(
    .a(PC_Fe), 
    .b(32'h00000004),
    .s(PCPlus4F)
);

always_ff @(posedge clk or negedge rst) begin
    if(rst == 1'b0) begin
        InstrF_reg <= 32'h00000000;
        PCF_reg <= 32'h00000000;
        PCPlus4F_reg <= 32'h00000000;
    end else begin
        InstrF_reg <= InstrF;
        PCF_reg <= PC_Fe;
        PCPlus4F_reg <= PCPlus4F;
    end
end

assign InstrD = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
assign PC_De = (rst == 1'b0) ? 32'h00000000 : PCF_reg;
assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;

endmodule
