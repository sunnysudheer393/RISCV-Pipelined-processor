module Memory_cycle(
    input logic clk, rst, RegWriteM, ResultSrcM, MemWriteM,
    input logic [31:0] ALUResultM, WriteDataM, PCPlus4M,
    input logic [4:0] RdM,

    output logic RegWriteW, ResultSrcW,
    output logic [31:0] ALUResultW, ReadDataW, PCPlus4W,
    output logic [4:0] RdW
);

logic [31:0] ReadDataM;

logic RegWriteM_r, ResultSrcM_r;
logic [31:0] ALUResultM_r, ReadDataM_r, PCPlus4M_r;
logic [4:0] RdM_r;

Data_memory data_mem(
    .clk(clk), 
    .rst(rst),
    .We(MemWriteM),
    .Aa(ALUResultM), 
    .Wd(WriteDataM),
    .Rd(ReadDataM)
);

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        RegWriteM_r <= 1'b0;
        ResultSrcM_r <= 1'b0;
        ALUResultM_r <= 32'h00000000;
        ReadDataM_r <= 32'h00000000;
        RdM_r <= 5'b00000;
        PCPlus4M_r <= 32'h00000000;
    end else begin
        RegWriteM_r <= RegWriteM;
        ResultSrcM_r <= ResultSrcM;
        ALUResultM_r <= ALUResultM;
        ReadDataM_r <= ReadDataM;
        RdM_r <= RdM;
        PCPlus4M_r <= PCPlus4M;
    end
end

assign RegWriteW = RegWriteM_r;
assign ResultSrcW = ResultSrcM_r;
assign ALUResultW = ALUResultM_r;
assign ReadDataW = ReadDataM_r;
assign RdW = RdM_r;
assign PCPlus4W = PCPlus4M_r;

endmodule
