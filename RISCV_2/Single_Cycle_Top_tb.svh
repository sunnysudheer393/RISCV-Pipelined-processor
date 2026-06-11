`timescale 1ns/100ps
//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Single_Cycle_Top_tb();
    logic clk = 1'b0;
    logic rst;

    Single_Cycle_Top RISCV(.clk(clk), .rst(rst));

    initial begin : generate_clock
        forever #25 clk = ~clk;
    end

    initial begin : stimulus_generation
        integer i;

        $timeformat(-9, 0, "ns");
        $display("============================================================");
        $display("Starting RISC-V single-cycle simulation");
        $display("============================================================");

        // Active-low reset: assert reset for a few clock edges before start.
        rst = 1'b0;
        repeat (3) @(posedge clk);
        rst = 1'b1;

        // Run the program for a reasonable number of cycles and dump key state.
        repeat (25) begin
            @(posedge clk);
            #1;
            $display("t=%0t pc=%0h instr=%h x5=%0d x6=%0d x7=%0d x8=%0d",
                     $time,
                     RISCV.pc.PC_p,
                     RISCV.RDd,
                     RISCV.Registers.register_file[5],
                     RISCV.Registers.register_file[6],
                     RISCV.Registers.register_file[7],
                     RISCV.Registers.register_file[8]);
        end

        // Basic sanity checks against the current program in memfile.hex.
        // if (RISCV.Registers.register_file[5] !== 32'd5) $error("x5 mismatch, expected 5");
        // if (RISCV.Registers.register_file[6] !== 32'd3) $error("x6 mismatch, expected 3");
        // if (RISCV.Registers.register_file[7] !== 32'd8) $error("x7 mismatch, expected 8");

        $display("============================================================");
        $display("Simulation finished");
        $display("============================================================");
       // $finish;
       disable generate_clock;
    end
endmodule
