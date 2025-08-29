//`timescale 1ns/100ps
module Instruction_Memory(
    input logic rst,
    input logic [31:0] Aa,
    output logic [31:0] RDd
);
logic[31:0] mem[1023:0]; //this can store 1024 instructions of 32 bit each

assign RDd = (~rst)? ({32{1'b0}}): mem[Aa[31:2]];

initial begin : read_hex_file
    // $readmemh("memfile.hex",mem);
    // $display("Memory Contents:");
    // for (int i = 0; i < 7; i++) begin // Assuming you want to see the first 7 entries
    //     $display("mem[%0d] = %h", i, mem[i]);
    // end
    //mem[0] = 32'h0;
    mem[0] = 32'hFFC4A303;
    //#20;
    mem[1] = 32'h00832383;
    mem[2] = 32'h0062E3B3;
    mem[3] = 32'h0064A423;
    mem[4] = 32'h0064E3B2;
    mem[5] = 32'h003256A5;
    mem[6] = 32'hFFCA3054;
    mem[7] = 32'hE432FFCC;

end

endmodule
