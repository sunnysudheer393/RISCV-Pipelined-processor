//`include "cpu_parameters.svh"
import cpu_parameters::*;

module ALU(
    input logic [DATA_WIDTH-1:0] Aa,Bb,
    input logic [ALU_CONTROL_WIDTH-1:0] ALUControl,
    output logic [DATA_WIDTH-1:0] Result,
    output logic Carry, Overflow, Zero, Negative
);

logic Cout;
logic [DATA_WIDTH-1:0] Sum;


typedef enum logic [ALU_OPR_WIDTH-1:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_AND = 4'b0010,
    ALU_OR  = 4'b0011,
    ALU_SLT = 4'b0100,
    ALU_XOR = 4'b0101,

    BEQ     = 4'b0110,
    BNE     = 4'b0111,
    BLT     = 4'b1000, // Using SLT for BLT and BGE
    BGE     = 4'b1001,  // Using SLT for BLT and BGE will require additional logic to invert the result
    BLTU    = 4'b1010, // For unsigned comparisons, additional logic will be needed
    BGEU    = 4'b1011  // For unsigned comparisons, additional logic will be needed
} state_r;

assign {Cout, Sum} = (ALUControl[0] == 1'b0) ? Aa + Bb : (Aa + ((~Bb) + 1 ));

always_comb begin
    case (ALUControl)
        ALU_ADD: Result = Sum;
        ALU_SUB: Result = Sum;
        ALU_AND: Result = Aa & Bb;
        ALU_OR:  Result = Aa | Bb;
        ALU_SLT: Result = {{DATA_WIDTH-1{1'b0}}, (Sum[DATA_WIDTH-1])};
        ALU_XOR: Result = Aa ^ Bb;

        BEQ:     Result = {{DATA_WIDTH-1{1'b0}}, (Aa == Bb)};  // BEQ: Branch if Equal
        BNE:     Result = {{DATA_WIDTH-1{1'b0}}, (Aa != Bb)};  // BNE: Branch if Not Equal
        BLT:     Result = {{DATA_WIDTH-1{1'b0}}, ((Aa[DATA_WIDTH-1] & ~Bb[DATA_WIDTH-1]) | ((Aa[DATA_WIDTH-1] ~^ Bb[DATA_WIDTH-1]) & Sum[DATA_WIDTH-1]))}; // BLT: signed <
        BGE:     Result = {{DATA_WIDTH-1{1'b0}}, ~((Aa[DATA_WIDTH-1] & ~Bb[DATA_WIDTH-1]) | ((Aa[DATA_WIDTH-1] ~^ Bb[DATA_WIDTH-1]) & Sum[DATA_WIDTH-1]))}; // BGE: signed >=
        BLTU:    Result = {{DATA_WIDTH-1{1'b0}}, (Aa < Bb)};   // BLTU: unsigned <
        BGEU:    Result = {{DATA_WIDTH-1{1'b0}}, (Aa >= Bb)};  // BGEU: unsigned >=
        default: Result = {DATA_WIDTH{1'b0}};
    endcase
end

// assign Result = (ALUControl == ALU_OP_WIDTH{1'b0}) ? Sum :
//                 (ALUControl == ALU_OP_WIDTH{1'b1}) ? Sum :
//                 (ALUControl == ALU_OP_WIDTH{1'b10})? (Aa & Bb):
//                 (ALUControl == ALU_OP_WIDTH{1'b11})? (Aa | Bb):
//                 (ALUControl == ALU_OP_WIDTH{1'b101})? {{DATA_WIDTH-1{1'b0}}, (Sum[DATA_WIDTH-1])} : {DATA_WIDTH{1'b0}};

assign Overflow = ((Sum[DATA_WIDTH-1] ^ Aa[DATA_WIDTH-1]) & (~(ALUControl[0] ^ Aa[DATA_WIDTH-1] ^ Bb[DATA_WIDTH-1])) & (~ALUControl[1]));

assign Negative = Result[DATA_WIDTH-1];

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
