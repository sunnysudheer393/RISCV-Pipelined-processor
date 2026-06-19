`timescale 1ns/100ps

`include "cpu_parameters.svh"
`include "Branch_Predictor.svh"
import cpu_parameters::*;

module branch_predictor_tb();

    logic clk = 1'b0;
    logic rst;
    logic [DATA_WIDTH-1:0] PC_Fe, PC_Ex;
    logic update_en, actual_taken_E;
    logic predict_F;

    // Test with 2-bit predictor (default)
    Branch_Predictor #(
        .PREDICTOR_BITS(2)
    ) bp (
        .clk(clk),
        .rst(rst),
        .PC_Fe(PC_Fe),
        .PC_Ex(PC_Ex),
        .update_en(update_en),
        .actual_taken_E(actual_taken_E),
        .predict_F(predict_F)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $timeformat(-9, 0, "ns");
        
        // Initialize
        rst = 1'b0;
        PC_Fe = 32'h00400000;
        PC_Ex = 32'h00400000;
        update_en = 1'b0;
        actual_taken_E = 1'b0;
        
        // Apply reset
        repeat(2) @(posedge clk);
        rst = 1'b1;
        @(posedge clk);
        
        $display("=== 2-bit Predictor Test ===");
        $display("Time\tPC_Fe\t\tPC_Ex\t\tUpdate\tTaken\tPredict");
        
        // Test 1: Initial prediction (should be not taken - SNT)
        PC_Fe = 32'h00400004;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 2: First branch taken - should update to WNT
        PC_Ex = 32'h00400004;
        update_en = 1'b1;
        actual_taken_E = 1'b1;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 3: Same branch taken again - should update to WT
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 4: Same branch taken again - should update to ST
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 5: Branch not taken - should go to WT
        actual_taken_E = 1'b0;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 6: Branch not taken - should go to WNT
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 7: Branch not taken - should go to SNT
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 8: Different PC (different index) - should be SNT initially
        update_en = 1'b0;
        PC_Fe = 32'h00400010;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 9: New branch taken
        PC_Ex = 32'h00400010;
        update_en = 1'b1;
        actual_taken_E = 1'b1;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Test 10: Loop pattern simulation - inner loop (repeated taken)
        $display("\n=== Loop Pattern Test ===");
        PC_Ex = 32'h00400020;
        PC_Fe = 32'h00400020;
        actual_taken_E = 1'b1;
        repeat(5) begin
            @(posedge clk);
            $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        end
        
        // Loop exit - not taken
        actual_taken_E = 1'b0;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        // Next iteration - taken again
        actual_taken_E = 1'b1;
        @(posedge clk);
        $display("%0t\t%h\t%h\t%d\t%d\t%d", $time, PC_Fe, PC_Ex, update_en, actual_taken_E, predict_F);
        
        $display("\n=== Test Complete ===");
        $finish;
    end

endmodule