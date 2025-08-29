module Sign_Extend(
    input logic [31:0] In,
    input logic ImmSrc,
    output logic [31:0] Imm_Ext

);

assign Imm_Ext = (ImmSrc == 1'b1) ? ({{20{In[31]}}, In[31:25], In[11:7]}) : {{20{In[31]}}, In[31:20]}; 

endmodule
