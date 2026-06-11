//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Mux(
    input logic [DATA_WIDTH-1:0] a,b,
    input logic s,
    output logic [DATA_WIDTH-1:0] out
);

assign out = (~s) ? a : b ;

endmodule
