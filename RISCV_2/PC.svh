//`include "cpu_parameters.svh"
import cpu_parameters::*;

module PC(
    input logic clk, rst,
    input logic stall,
    input logic [DATA_WIDTH-1:0] PC_next,
    output logic [DATA_WIDTH-1:0] PC_p
);

always_ff @(posedge clk or negedge rst) begin
    if(~rst) PC_p <= {DATA_WIDTH{1'b0}};//replication operator
    else PC_p <= PC_next;
end

endmodule
