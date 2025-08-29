module Mux3_by_1(
    input logic [31:0] a, b, c,
    input logic [1:0] s,

    output logic [31:0] out
);
//a = RD1_Ex,
//b = ResultW,
//c = ALUResultM
assign out = (s == 2'b00) ? a :  (s == 2'b01) ? b : (s == 2'b10) ? c : 32'h00000000;

endmodule
