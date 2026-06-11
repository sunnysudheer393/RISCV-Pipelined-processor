package cpu_parameters;

//CPU Parameters for a simple RISC-V processor implementation
localparam DATA_WIDTH = 32; // Data width for registers and memory
localparam ADDR_WIDTH = 32; // Address width for memory access


//memory & reg file parameters
localparam MEMORY_SIZE = 1024; // Size of memory in bytes
localparam REG_ADDR_WIDTH = 5; // Width of register address (5 bits for 32 registers)
//localparam NUM_REGS = 32; // Number of registers
localparam INSTRUCTION_WIDTH = 32; // Width of instructions

//ALU control signal parameters
localparam ALU_CONTROL_WIDTH = 4; // Width of ALU control signals
localparam OPCODE_WIDTH = 7; // Width of opcode field in instructions
localparam FUNCT3_WIDTH = 3; // Width of funct3 field in instructions
localparam FUNCT7_WIDTH = 7; // Width of funct7 field in instructions
localparam ALU_OP_WIDTH = 2; // Width of ALUOp control signal
localparam FWD_MUX_WIDTH = 2; // Width of forwarding mux control signals
localparam IMM_SRC_WIDTH = 2; // Width of immediate source control signal
localparam ALU_OPR_WIDTH = 4; // Width of ALU operand control signal(for diff operations like add, sub, and, or, slt, etc.)

//Program counter parameter
localparam PC_START_ADDR = 32'h0000_0000; // Starting address of the program counter

// Add these branch condition codes
localparam BEQ  = 3'b000;   // Branch if Equal
localparam BNE  = 3'b001;   // Branch if Not Equal
localparam BLT  = 3'b100;   // Branch if Less Than
localparam BGE  = 3'b101;   // Branch if Greater or Equal
localparam BLTU = 3'b110;   // Branch if Less Than Unsigned
localparam BGEU = 3'b111;   // Branch if Greater or Equal Unsigned


endpackage
