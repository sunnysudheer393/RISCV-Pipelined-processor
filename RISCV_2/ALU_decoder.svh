//`include "cpu_parameters.svh"
import cpu_parameters::*;

module ALU_decoder(
    input logic[ALU_OP_WIDTH-1:0] ALUOp,
    input logic[OPCODE_WIDTH-1:0] Op,
    input logic[FUNCT7_WIDTH-1:0] funct7,
    input logic [FUNCT3_WIDTH-1:0] funct3,
    output logic [ALU_OPR_WIDTH-1:0] ALUControl

);

localparam ALU_ADD = 4'b0000;
localparam ALU_SUB = 4'b0001;
localparam ALU_AND = 4'b0010;
localparam ALU_OR  = 4'b0011;
localparam ALU_SLT = 4'b0100;
localparam ALU_XOR = 4'b0101;

localparam BEQ     = 4'b0110;
localparam BNE     = 4'b0111;
localparam BLT     = 4'b1000; // Using SLT for BLT and BGE
localparam BGE     = 4'b1001;  // Using SLT for BLT and BGE will require additional logic to invert the result
localparam BLTU    = 4'b1010; // For unsigned comparisons, additional logic will be needed
localparam BGEU    = 4'b1011;  // For unsigned comparisons, additional logic will be needed

always_comb begin
    case (ALUOp)
        2'b00: ALUControl = ALU_ADD; // For load/store, use ADD
        2'b01: begin // I-type immediate arithmetic
            case (funct3)
                3'b000: ALUControl = ALU_ADD;  // ADDI: Add Immediate
                3'b010: ALUControl = ALU_SLT;  // SLTI: Set Less Than Immediate
                3'b110: ALUControl = ALU_OR;   // ORI: Or Immediate
                3'b111: ALUControl = ALU_AND;  // ANDI: And Immediate
                default: ALUControl = ALU_ADD;
            endcase
        end
        2'b10: begin // R-type instructions
            case (funct3)
                3'b000: ALUControl = ({funct7[5], Op[5]} == 2'b11) ? ALU_SUB : ALU_ADD; // SUB if funct7[5] is 1, else ADD
                3'b010: ALUControl = ALU_SLT; // SLT
                3'b110: ALUControl = ALU_OR; // OR
                3'b111: ALUControl = ALU_AND; // AND
                default: ALUControl = ALU_ADD; // Default to ADD for undefined funct3
            endcase
        end
        2'b11: begin // Branch instructions
            case (funct3)
                3'b000: ALUControl = BEQ; // BEQ uses SUB to compare
                3'b001: ALUControl = BNE; // BNE uses SUB to compare
                3'b100: ALUControl = BLT; // BLT uses SLT
                3'b101: ALUControl = BGE; // BGE uses SLT (with inverted result)
                3'b110: ALUControl = BLTU; // BLTU uses SLT
                3'b111: ALUControl = BGEU; // BGEU uses SLT (with additional logic for unsigned)
                default: ALUControl = ALU_ADD; // Default to ADD for undefined funct3
            endcase
        end
        default: ALUControl = ALU_ADD; // Default to ADD for undefined ALUOp
    endcase
end

// assign ALUControl = (ALUOp == ALU_OP_WIDTH'(2'b00))? ALU_OPR_WIDTH'(4'b0000):
//                     (ALUOp == ALU_OP_WIDTH'(2'b01))? ALU_OPR_WIDTH'(4'b0001):
//                     ((ALUOp == ALU_OP_WIDTH'(2'b10) & (funct3 == FUNC3_WIDTH'(3'b000)) & ({Op[5],funct7[5]} == 2'b11))? ALU_OPR_WIDTH'(4'b001):
//                     ((ALUOp == ALU_OP_WIDTH'(2'b10) & (funct3 == FUNC3_WIDTH'(3'b000)) & ({Op[5],funct7[5]} != 2'b11))? ALU_OPR_WIDTH'(4'b000):
//                     ((ALUOp == ALU_OP_WIDTH'(2'b10) & (funct3 == FUNC3_WIDTH'(3'b010)))? ALU_OPR_WIDTH'(4'b101):
//                     ((ALUOp == ALU_OP_WIDTH'(2'b10) & (funct3 == FUNC3_WIDTH'(3'b110)))? ALU_OPR_WIDTH'(4'b011):
//                     ((ALUOp == ALU_OP_WIDTH'(2'b10) & (funct3 == FUNC3_WIDTH'(3'b111)))? ALU_OPR_WIDTH'(4'b010): ALU_OPR_WIDTH'(4'b000))))))
//                     (ALUOp == ALU_OP_WIDTH'(2'b11))? ((funct3 == FUNC3_WIDTH'(3'b000))? ALU_OPR_WIDTH'(4'b000):
//                     (funct3 == FUNC3_WIDTH'(3'b001))? ALU_OPR_WIDTH'(4'b001): 
//                     (funct3 == FUNC3_WIDTH'(3'b010))? ALU_OPR_WIDTH'(4'b010): 
//                     (funct3 == FUNC3_WIDTH'(3'b011))? ALU_OPR_WIDTH'(4'b011):
//                     (funct3 == FUNC3_WIDTH'(3'b100))? ALU_OPR_WIDTH'(4'b100): ALU_OPR_WIDTH'(4'b000)): ALU_OPR_width'(4'b00０);


endmodule
