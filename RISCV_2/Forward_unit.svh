`include "cpu_parameters.sv"
import cpu_parameters::*;

module Forward_unit(
    input logic rst, RegWriteM, RegWriteW, 
    input logic [DATA_WIDTH-1:0] ALUResultM, ResultW,
    input logic [REG_ADDR_WIDTH-1:0] RdM, RdW,
    input logic [REG_ADDR_WIDTH-1:0] RS1_Ex, RS2_Ex,

    // //for branch prediciton
    // input logic is_branch_ID, // Signal indicating if the current instruction in Decode stage is a branch
    // input logic predicted_taken_ID, // Prediction for the branch instruction in Decode stage
    // input logic actual_taken_ID, // Actual outcome of the branch instruction in Decode stage

    // // output logic misprediction,
    // output logic flush_IF_ID, // Signal to flush the IF/ID pipeline register
    // output logic flush_ID_EX, // Signal to flush the ID/EX pipeline register

    output logic [FWD_MUX_WIDTH-1:0] ForwardAE, ForwardBE

);

// logic misprediction; // Signal indicating a branch misprediction

// assign misprediction = is_branch_ID && (predicted_taken_ID != actual_taken_ID);

// // Generate flush signals based on misprediction
// assign flush_IF_ID = misprediction || FlushE; // Flush IF/ID if there's a misprediction
// assign flush_ID_EX = misprediction || FlushE; // Flush ID/EX if there's a misprediction


assign ForwardAE = (rst == 1'b0) ? {FWD_MUX_WIDTH{1'b0}} :
                    ((RegWriteM == 1'b1) & (RdM != 5'b00000) & (RdM == RS1_Ex))? {FWD_MUX_WIDTH{1'b1}} : 
                    ((RegWriteW == 1'b1) & (RdW != 5'b00000) & (RdW == RS1_Ex)) ? {FWD_MUX_WIDTH{1'b1}} : {FWD_MUX_WIDTH{1'b0}};

assign ForwardBE = (rst == 1'b0) ? {FWD_MUX_WIDTH{1'b0}} :
                    ((RegWriteM == 1'b1) & (RdM != 5'b00000) & (RdM == RS2_Ex))? {FWD_MUX_WIDTH{1'b1}} : 
                    ((RegWriteW == 1'b1) & (RdW != 5'b00000) & (RdW == RS2_Ex)) ? {FWD_MUX_WIDTH{1'b1}} : {FWD_MUX_WIDTH{1'b0}};

endmodule
