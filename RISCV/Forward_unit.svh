module Forward_unit(
    input logic rst, RegWriteM, RegWriteW, 
    input logic [31:0] ALUResultM, ResultW,
    input logic [4:0] RdM, RdW,
    input logic [4:0] RS1_Ex, RS2_Ex,

    output logic [1:0] ForwardAE, ForwardBE

);

assign ForwardAE = (rst == 1'b0) ? 2'b00 :
                    ((RegWriteM == 1'b1) & (RdM != 5'b00000) & (RdM == RS1_Ex))? 2'b10 : 
                    ((RegWriteW == 1'b1) & (RdW != 5'b00000) & (RdW == RS1_Ex)) ? 2'b01 : 2'b00;

assign ForwardBE = (rst == 1'b0) ? 2'b00 :
                    ((RegWriteM == 1'b1) & (RdM != 5'b00000) & (RdM == RS2_Ex))? 2'b10 : 
                    ((RegWriteW == 1'b1) & (RdW != 5'b00000) & (RdW == RS2_Ex)) ? 2'b01 : 2'b00;

endmodule
