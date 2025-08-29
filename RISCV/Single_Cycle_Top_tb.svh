`timescale 1ns/100ps

module Single_Cycle_Top_tb();
logic clk = 1'b0, rst;

initial begin : generate_clock
    forever #50 clk = ~clk;
end

Single_Cycle_Top RISCV( .clk(clk), .rst(rst));

initial begin : Stimulus_generation
    $timeformat(-9, 0,"ns");
    @(posedge clk);
    rst <= 1'b0;
    //repeat(3) @(posedge clk);
    #150;
    rst <= 1'b1;
    @(negedge clk);
    #1000;
    disable generate_clock;
end

endmodule
