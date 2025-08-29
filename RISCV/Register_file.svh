module Register_file(
    input logic[4:0] a1, a2, a3,
    input logic [31:0] Wd3,
    input logic clk, rst, We3,
    output logic [31:0] Rd1, Rd2
);

logic [31:0] register_file [31:0];

assign Rd1 = (~rst)? {32{1'b0}}:register_file[a1];

assign Rd2 = (~rst)? {32{1'b0}}:register_file[a2];

always_ff @(posedge clk) begin
    if(~rst) begin
        for(int i = 0; i<1024; i++) register_file[i] <= i;
    end
    if (We3 & (a3 != 5'h00000)) begin
        register_file[a3] <= Wd3;
    end
    register_file[0] <= 32'h00000000;
    // register_file[5] <= 32'h00000005;
    // register_file[6] <= 32'h00000004;
    // register_file[9] <= 32'h00000007;
end

// initial begin : register_file_data
//     // register_file[5] = 32'h00000005;
//     // register_file[6] = 32'h00000004;
    
// end

endmodule
