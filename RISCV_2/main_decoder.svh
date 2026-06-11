//`include "cpu_parameters.svh"
import cpu_parameters::*;

module main_decoder(
    input logic[OPCODE_WIDTH-1:0] Op,
    input logic[FUNCT3_WIDTH-1:0] funct3,

    output logic ResultSrc, MemWrite, ALUSrc,RegWrite, Branch,
    output logic [ALU_OP_WIDTH-1:0] ALUOp, 
    output logic [IMM_SRC_WIDTH-1:0] ImmSrc
   // output logic PCSrc
    //output logic[ALU_CONTROL_WIDTH-1:0] ALUControl
);

//logic Branch;

assign RegWrite = (Op == OPCODE_WIDTH'(7'b0000011) | 
                   Op == OPCODE_WIDTH'(7'b0010011) | 
                   Op == OPCODE_WIDTH'(7'b0110011))? 1'b1: 1'b0;

assign ImmSrc = (Op == OPCODE_WIDTH'(7'b0100011)) ? IMM_SRC_WIDTH'(2'b01) : 
                    (Op == OPCODE_WIDTH'(7'b1100011)) ? IMM_SRC_WIDTH'(2'b10) :    
                    (Op == OPCODE_WIDTH'(7'b0000011) | Op == OPCODE_WIDTH'(7'b0010011))?  IMM_SRC_WIDTH'(2'b00): IMM_SRC_WIDTH'(2'bxx);
                    
                // (Op == OPCODE_WIDTH'(7'b0000011))? IMM_SRC_WIDTH'(2'b00):
                // (Op == OPCODE_WIDTH'(7'b0100011))? IMM_SRC_WIDTH'(2'b01):
                // (Op == OPCODE_WIDTH'(7'b1100011))? IMM_SRC_WIDTH'(2'b10): IMM_SRC_WIDTH'(2'bxx);

assign ALUSrc = (Op == OPCODE_WIDTH'(7'b0000011) | 
                 Op == OPCODE_WIDTH'(7'b0010011) | 
                 Op == OPCODE_WIDTH'(7'b0100011))? 1'b1: 1'b0;

assign MemWrite = (Op == OPCODE_WIDTH'(7'b0100011))? 1'b1: 1'b0;

assign ResultSrc = (Op == OPCODE_WIDTH'(7'b0000011)) ? 1'b1: 1'b0;

assign Branch = (Op == OPCODE_WIDTH'(7'b1100011))? 1'b1: 1'b0;

assign ALUOp = (Op == OPCODE_WIDTH'(7'b0110011))? ALU_OP_WIDTH'(2'b10):
                (Op == OPCODE_WIDTH'(7'b0010011))? ALU_OP_WIDTH'(2'b01):
                (Op == OPCODE_WIDTH'(7'b1100011))? ALU_OP_WIDTH'(2'b11): ALU_OP_WIDTH'(2'b00);

endmodule
