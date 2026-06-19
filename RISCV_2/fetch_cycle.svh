`include "cpu_parameters.svh"
`include "Branch_Predictor.svh"
`include "Branch_Target_Buffer.svh"
import cpu_parameters::*;

module fetch_cycle( 
    input logic [DATA_WIDTH-1:0] PCTargetE, 
    input logic clk, rst,
    input logic PCSrcE, FlushE,
    // Branch predictor update signals from Execute stage
    input logic BranchE,
    input logic [DATA_WIDTH-1:0] PC_Ex,
    input logic actual_taken_E,
    output logic [DATA_WIDTH-1:0] InstrD,PC_De,PCPlus4D,
    // Prediction info passed to Decode stage
    output logic predict_D,
    output logic [DATA_WIDTH-1:0] PC_D
);

logic[DATA_WIDTH-1:0] PC_Fe, PCF_next, InstrF, PCPlus4F;
logic [DATA_WIDTH-1:0] InstrF_reg, PCF_reg, PCPlus4F_reg;
logic stall; // You can use this signal to stall the PC update when necessary (e.g., during a hazard)

// Branch predictor signals
logic predict_F;
logic [DATA_WIDTH-1:0] predicted_target_F;
logic btb_hit_F;

// 3-way PC Mux selection:
// 00: PC+4 (sequential / predict not-taken)
// 01: predicted_target_F (predict taken + BTB hit)
// 10: PCTargetE (misprediction correction from EX - highest priority)
logic [1:0] pc_mux_sel;

Branch_Predictor bp (
    .clk(clk),
    .rst(rst),
    .PC_Fe(PC_Fe),
    .PC_Ex(PC_Ex),
    .update_en(BranchE),
    .actual_taken_E(actual_taken_E),
    .predict_F(predict_F)
);

Branch_Target_Buffer btb (
    .clk(clk),
    .rst(rst),
    .PC_Fe(PC_Fe),
    .PC_Ex(PC_Ex),
    .PCTargetE(PCTargetE),
    .update_en(BranchE),
    .actual_taken_E(actual_taken_E),
    .predicted_target_F(predicted_target_F),
    .btb_hit_F(btb_hit_F)
);

// PC Mux selection logic
always_comb begin
    if (PCSrcE) begin
        // Misprediction correction from EX stage - highest priority
        pc_mux_sel = 2'b10;
    end else if (predict_F && btb_hit_F) begin
        // Predict taken with valid BTB entry
        pc_mux_sel = 2'b01;
    end else begin
        // Predict not taken (or no BTB hit) - sequential
        pc_mux_sel = 2'b00;
    end
end

Mux3_by_1 PC_Mux3(
    .a(PCPlus4F),              // 00: PC+4
    .b(predicted_target_F),    // 01: predicted target
    .c(PCTargetE),             // 10: corrected target from EX
    .s(pc_mux_sel),
    .out(PCF_next)
);

PC PC_for_next(
    .clk(clk), 
    .rst(rst),
    .stall(stall),
    .PC_next(PCF_next),
    .PC_p(PC_Fe)
);

Instruction_Memory Instr_mem(
    .clk(clk),
    .rst(rst),
    .Aa(PC_Fe),
    .RDd(InstrF)
);

PC_adder PC_next_Addr(
    .a(PC_Fe), 
    .b(32'd4),
    .s(PCPlus4F)
);

always_ff @(posedge clk or negedge rst) begin
    if(rst == 1'b0) begin
        InstrF_reg <= {DATA_WIDTH{1'b0}};
        PCF_reg <= {DATA_WIDTH{1'b0}};
        PCPlus4F_reg <= {DATA_WIDTH{1'b0}};
        predict_D <= 1'b0;
        PC_D <= {DATA_WIDTH{1'b0}};
    end else if (FlushE) begin
        InstrF_reg <= {DATA_WIDTH{1'b0}}; // Flush the instruction in the Decode stage
        PCF_reg <= {DATA_WIDTH{1'b0}}; // Optionally, you can also reset the PC in the Decode stage
        PCPlus4F_reg <= {DATA_WIDTH{1'b0}}; // Optionally, you can also reset the PC+4 in the Decode stage
        predict_D <= 1'b0;
        PC_D <= {DATA_WIDTH{1'b0}};
    end else begin
        InstrF_reg <= InstrF;
        PCF_reg <= PC_Fe;
        PCPlus4F_reg <= PCPlus4F;
        predict_D <= predict_F;
        PC_D <= PC_Fe;
    end
end

assign InstrD = InstrF_reg;
assign PC_De = PCF_reg;
assign PCPlus4D = PCPlus4F_reg;

endmodule
