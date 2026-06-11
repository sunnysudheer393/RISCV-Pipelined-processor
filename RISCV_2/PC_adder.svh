//`include "cpu_parameters.svh"
import cpu_parameters::*;

module PC_adder(
    input logic [DATA_WIDTH-1:0] a, b,
    output logic [DATA_WIDTH-1:0] s
);

assign s = a + b;

endmodule
