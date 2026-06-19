`include "cpu_parameters.svh"
import cpu_parameters::*;

module Branch_Predictor (
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] PC_Fe,           // PC at Fetch stage (for read)
    input logic [DATA_WIDTH-1:0] PC_Ex,           // PC at Execute stage (for write/update)
    input logic update_en,                        // Update enable (BranchE)
    input logic actual_taken_E,                   // Actual branch outcome from EX
    
    output logic predict_F                        // Prediction at Fetch: 1 = taken, 0 = not-taken
);

    // Branch History Table
    logic [PREDICTOR_BITS-1:0] bht [0:BHT_SIZE-1];
    logic [BHT_INDEX_WIDTH-1:0] read_idx, write_idx;

    assign read_idx  = PC_Fe[BHT_INDEX_WIDTH+1:2];  // PC[5:2] for 16-entry BHT
    assign write_idx = PC_Ex[BHT_INDEX_WIDTH+1:2];  // PC[5:2] for 16-entry BHT

    assign predict_F = (bht[read_idx] == W_T) || (bht[read_idx] == S_T); // Predict taken if WT or ST


    // Synchronous write/update at Execute stage
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (int i = 0; i < BHT_SIZE; i++) begin
                bht[i] <= W_NT;  // Initialize to Weakly Not Taken
            end
        end else if (update_en) begin
            // 2-bit Smith saturating counter
            case (bht[write_idx])
                S_NT: bht[write_idx] <= actual_taken_E ? W_NT : S_NT;
                W_NT: bht[write_idx] <= actual_taken_E ? W_T  : S_NT;
                W_T:  bht[write_idx] <= actual_taken_E ? S_T  : W_NT;
                S_T:  bht[write_idx] <= actual_taken_E ? S_T  : W_T;
                default: bht[write_idx] <= W_NT;
            endcase
        end
    end

endmodule
