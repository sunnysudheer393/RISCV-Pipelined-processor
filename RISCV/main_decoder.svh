module main_decoder(
    input logic[6:0] Op,
    input logic [2:0] funct3,

    output logic ResultSrc, MemWrite, ALUSrc,RegWrite, Branch,
    output logic [1:0] ALUOp, ImmSrc
    //output logic[2:0] ALUControl
);

//logic Branch;

assign RegWrite = (Op == 7'b0000011 | Op == 7'b0110011)? 1'b1: 1'b0;

assign ImmSrc = (Op == 7'b0100011) ? 2'b01 : 
                    (Op == 7'b1100011) ? 2'b10 :    
                                         2'b00 ;
                // (Op == 7'b0000011)? 2'b00:
                // (Op == 7'b0100011)? 2'b01:
                // (Op == 7'b1100011)? 2'b10: 2'bxx;

assign ALUSrc = (Op == 7'b0000011 | Op == 7'b0110011)? 1'b1: 1'b0;

assign MemWrite = (Op == 7'b0100011)? 1'b1: 1'b0;

assign ResultSrc = (Op == 7'b0000011) ? 1'b1: 1'b0;

assign Branch = (Op == 7'b1100011)? 1'b1: 1'b0;

assign ALUOp = (Op == 0110011)? 2'b10:
                (Op == 1100011)? 2'b01: 2'b00;

endmodule
