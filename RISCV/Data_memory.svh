module Data_memory(
    input logic clk, rst,We,
    input logic [31:0] Aa, Wd,
    output logic [31:0] Rd
);

logic [31:0] data_memory [1023:0];

always_ff @(posedge clk) begin
    if(~rst) begin
        for(int i = 0; i< 1024; i++) data_memory[i] <= 32'h00000004;
    end else if (We) begin
        data_memory[Aa] <= Wd;
    end
    data_memory[28] <= 32'h00000020;
    data_memory[40] <= 32'h00000002;
end

assign Rd = (~rst)? {32{1'b0}}: data_memory[Aa];

// initial begin : data_memory_file
//     data_memory[28] = 32'h00000020;
//     data_memory[40] = 32'h00000002;
// end

endmodule
