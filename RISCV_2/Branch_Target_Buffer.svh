`include "cpu_parameters.svh"
import cpu_parameters::*;

module Branch_Target_Buffer(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] PC_Fe,           // PC at Fetch stage (for read)
    input logic [DATA_WIDTH-1:0] PC_Ex,           // PC at Execute stage (for write/update)
    input logic [DATA_WIDTH-1:0] PCTargetE,       // Actual branch target from EX
    input logic update_en,                        // Update enable (BranchE)
    input logic actual_taken_E,                   // Actual branch outcome from EX

    output logic [DATA_WIDTH-1:0] predicted_target_F, // Predicted target at Fetch
    output logic btb_hit_F                        // BTB hit signal
);

    // localparam BTB_SIZE = 16;
    // localparam BTB_INDEX_WIDTH = 4;
    // localparam TAG_WIDTH = DATA_WIDTH - BTB_INDEX_WIDTH - 2;  // Upper PC bits (skip 2 LSBs)

    // BTB storage: tag + target + valid bit
    logic [BTB_TAG_WIDTH-1:0] tags [0:BTB_SIZE-1];
    logic [DATA_WIDTH-1:0] targets [0:BTB_SIZE-1];
    logic valid [0:BTB_SIZE-1];

    logic [BTB_INDEX_WIDTH-1:0] read_idx, write_idx;
    logic [BTB_TAG_WIDTH-1:0] read_tag, write_tag;

    assign read_idx  = PC_Fe[BTB_INDEX_WIDTH+1:2];   // PC[5:2]
    assign write_idx = PC_Ex[BTB_INDEX_WIDTH+1:2];   // PC[5:2]
    assign read_tag  = PC_Fe[DATA_WIDTH-1:DATA_WIDTH-BTB_TAG_WIDTH];  // PC[31:6]
    assign write_tag = PC_Ex[DATA_WIDTH-1:DATA_WIDTH-BTB_TAG_WIDTH];  // PC[31:6]

    // // Combinational read at Fetch stage
    // always_comb begin
    //     btb_hit_F = valid[read_idx] && (tags[read_idx] == read_tag);
    //     predicted_target_F = btb_hit_F ? targets[read_idx] : {DATA_WIDTH{1'b0}};
    // end

    // Combinational read at Fetch stage
    assign btb_hit_F = valid[read_idx] && (tags[read_idx] == read_tag);
    assign predicted_target_F = btb_hit_F ? targets[read_idx] : {DATA_WIDTH{1'b0}};


    // Synchronous write/update at Execute stage
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (int i = 0; i < BTB_SIZE; i++) begin
                valid[i] <= 1'b0;
                tags[i] <= {BTB_TAG_WIDTH{1'b0}};
                targets[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (update_en && actual_taken_E) begin
            // Only update BTB on taken branches
            valid[write_idx] <= 1'b1;
            tags[write_idx] <= write_tag;
            targets[write_idx] <= PCTargetE;
        end
    end

endmodule
