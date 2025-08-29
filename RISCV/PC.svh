module PC(
    input logic clk, rst,
    input logic [31:0] PC_next,
    output logic [31:0] PC_p
);

always_ff @(posedge clk) begin
    if(~rst) PC_p <= {32{1'b0}};//replicattion operator
    else PC_p <= PC_next;
end

endmodule
