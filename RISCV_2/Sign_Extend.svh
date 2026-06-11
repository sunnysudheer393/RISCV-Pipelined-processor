//`include "cpu_parameters.svh"
import cpu_parameters::*;

module Sign_Extend(
    input logic [DATA_WIDTH-1:0] In,
    input logic [IMM_SRC_WIDTH-1:0] ImmSrc, //2-bit control signal to select the type of immediate
    output logic [DATA_WIDTH-1:0] Imm_Ext

);

//ImmSrc: 00 for I-type, 01 for S-type, 10 for B-type

logic [DATA_WIDTH-1:0] Branch_Imm_Ext;
assign Branch_Imm_Ext = {{20{In[DATA_WIDTH-1]}}, In[7], In[DATA_WIDTH-2:DATA_WIDTH-7], In[11:8], 1'b0}; // Construct the B-type immediate by concatenating the relevant bits from the instruction


assign Imm_Ext = (ImmSrc == 2'b00) ? {{20{In[DATA_WIDTH-1]}}, In[DATA_WIDTH-1:20]} :
                  (ImmSrc == 2'b01) ? ({{20{In[DATA_WIDTH-1]}}, In[DATA_WIDTH-1:25], In[11:7]}) :
                  (ImmSrc == 2'b10) ? (Branch_Imm_Ext) : {DATA_WIDTH{1'bx}}; // Default case for undefined ImmSrc values

//ImmSrc : 0 = I type, 1 = S type, 2 = B type

endmodule
