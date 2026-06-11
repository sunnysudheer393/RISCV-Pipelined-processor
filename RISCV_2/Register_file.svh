//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Register_file(
    input logic[REG_ADDR_WIDTH-1:0] a1, a2, a3,
    input logic [DATA_WIDTH-1:0] Wd3,
    input logic clk, rst, We3,
    output logic [DATA_WIDTH-1:0] Rd1, Rd2
);

logic [DATA_WIDTH-1:0] register_file [2**REG_ADDR_WIDTH-1:0];

assign Rd1 = (rst)? register_file[a1] : {DATA_WIDTH{1'b0}};

assign Rd2 = (rst)? register_file[a2] : {DATA_WIDTH{1'b0}};

always_ff @(posedge clk or negedge rst) begin
    if(~rst) begin
        for(int i = 1; i<2**REG_ADDR_WIDTH; i++) register_file[i] <= '0;
    end
    else begin
        if (We3 & (a3 != REG_ADDR_WIDTH'(5'h00000))) begin
            register_file[a3] <= Wd3;
        end
    end
    register_file[0] <= DATA_WIDTH'(32'h00000000);
    // register_file[5] <= DATA_WIDTH'(32'h00000005);
    // register_file[6] <= DATA_WIDTH'(32'h00000004);
    // register_file[9] <= DATA_WIDTH'(32'h00000007);
end

// initial begin : register_file_data
//     // register_file[5] = 32'h00000005;
//     // register_file[6] = 32'h00000004;
    
// end

endmodule
