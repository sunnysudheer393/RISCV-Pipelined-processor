module ALU(
    input logic [31:0] Aa,Bb,
    input logic [2:0] ALUControl,
    output logic [31:0] Result,
    output logic Carry, Overflow, Zero, Negative
);

logic Cout;
logic [31:0] Sum;

assign {Cout, Sum} = (ALUControl[0] == 1'b0) ? Aa + Bb : (Aa + ((~Bb) + 1 ));

assign Result = (ALUControl == 3'b000)? Sum:
                (ALUControl == 3'b001)? Sum:
                (ALUControl == 3'b010)? (Aa & Bb):
                (ALUControl == 3'b011)? (Aa | Bb):
                (ALUControl == 3'b101)? {{31{1'b0}}, (Sum[31])} : {32{1'b0}};

assign Overflow = ((Sum[31] ^ Aa[31]) & (~(ALUControl[0] ^ Aa[31] ^ Bb[31])) & (~ALUControl[1]));

assign Negative = Result[31];

assign Carry = (~ALUControl[1] & Cout);

assign Zero = (&(~Result));

endmodule
// assign Result = (ALUControl == 3'b000) ? Sum :
//                     (ALUControl == 3'b001) ? Sum :
//                     (ALUControl == 3'b010) ? A & B :
//                     (ALUControl == 3'b011) ? A | B :
//                     (ALUControl == 3'b101) ? {{31{1'b0}},(Sum[31])} : {32{1'b0}};

// assign Result = (ALUControl == 3'b000) ? Sum :
//                ((ALUControl == 3'b001) ? Sum :
//                 ((ALUControl == 3'b010) ? A & B :
//                  ((ALUControl == 3'b011) ? A | B :
//                   ((ALUControl == 3'b101) ? {{31{1'b0}},(Sum[31])} : {32{1'b0}}))));

// always_comb begin
//   case (ALUControl)
//     3'b000: Result = Sum;
//     3'b001: Result = Sum;
//     3'b010: Result = A & B;
//     3'b011: Result = A | B;
//     3'b101: Result = {{31{1'b0}}, Sum[31]};
//     default: Result = 32'b0; // It's good practice to have a default case
//   endcase
// end
