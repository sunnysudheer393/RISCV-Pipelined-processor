// Main module for single-cycle RISC-V processor (RV32I)
module riscv_single_cycle (
    input clk,            // Clock signal
    input reset,          // Reset signal
    output [31:0] pc_out  // Program counter output for debugging
);
    // Internal signals
    reg [31:0] PC;                    // Program Counter
    wire [31:0] instruction;          // Fetched instruction
    wire [31:0] alu_result, read_data, write_data;
    wire [31:0] reg_data1, reg_data2; // Register file read data
    wire [31:0] imm_ext;              // Sign-extended immediate
    wire [31:0] branch_target;        // Branch/jump target address
    wire RegWrite, MemRead, MemWrite, ALUSrc, PCSrc;
    wire [3:0] ALUOp;

    // Program Counter update
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'h00000000;
        else
            PC <= PCSrc ? branch_target : PC + 4;
    end
    assign pc_out = PC;

    // Instruction Memory
    instruction_memory imem (
        .addr(PC),
        .instr(instruction)
    );

    // Control Unit
    control_unit ctrl (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp)
    );

    // Register File
    register_file regs (
        .clk(clk),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(write_data),
        .RegWrite(RegWrite),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // Immediate Generator
    imm_generator imm_gen (
        .instr(instruction),
        .imm_ext(imm_ext)
    );

    // ALU
    alu alu_inst (
        .a(reg_data1),
        .b(ALUSrc ? imm_ext : reg_data2),
        .op(ALUOp),
        .result(alu_result),
        .zero()  // Zero flag not used in single-cycle (handled by PCSrc)
    );

    // Data Memory
    data_memory dmem (
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_data2),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(read_data)
    );

    // Writeback Mux (ALU result, memory data, or PC+4 for JAL)
    assign write_data = (instruction[6:0] == 7'b1101111) ? PC + 4 : 
                       MemRead ? read_data : alu_result;

    // Branch/Jump Target
    assign branch_target = PC + (imm_ext << 1);
endmodule

// Instruction Memory (ROM)
module instruction_memory (
    input [31:0] addr,
    output reg [31:0] instr
);
    // Simplified memory (256 words for demo)
    reg [31:0] mem [0:255];
    initial begin
        // Load sample instructions (replace with actual program)
        mem[0] = 32'h00500093; // ADDI x1, x0, 5
        mem[1] = 32'h00300113; // ADDI x2, x0, 3
        mem[2] = 32'h002081b3; // ADD x3, x1, x2
        mem[3] = 32'h00000000; // NOP
    end
    always @(*) begin
        instr = mem[addr[9:2]]; // Word-aligned access
    end
endmodule

// Register File
module register_file (
    input clk,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    input RegWrite,
    output [31:0] read_data1, read_data2
);
    reg [31:0] registers [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0; // Initialize registers to 0
    end
    // Write on clock edge
    always @(posedge clk) begin
        if (RegWrite && rd != 0)
            registers[rd] = write_data; // x0 is hardwired to 0
    end
    // Read combinational
    assign read_data1 = (rs1 == 0) ? 32'b0 : registers[rs1];
    assign read_data2 = (rs2 == 0) ? 32'b0 : registers[rs2];
endmodule

// ALU
module alu (
    input [31:0] a, b,
    input [3:0] op,
    output reg [31:0] result,
    output reg zero
);
    always @(*) begin
        case (op)
            4'b0000: result = a + b;       // ADD, ADDI
            4'b0001: result = a - b;       // SUB
            4'b0010: result = a & b;       // AND
            4'b0011: result = a | b;       // OR
            4'b0100: result = a ^ b;       // XOR
            4'b0101: result = a << b[4:0]; // SLL
            4'b0110: result = a >> b[4:0]; // SRL
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA
            4'b1000: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1001: result = (a < b) ? 1 : 0; // SLTU
            default: result = 32'b0;
        endcase
        zero = (result == 0);
    end
endmodule

// Data Memory
module data_memory (
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input MemRead, MemWrite,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:255];
    initial begin
        mem[0] = 32'h00000000; // Initialize memory
    end
    always @(posedge clk) begin
        if (MemWrite)
            mem[addr[9:2]] = write_data; // Word-aligned write
    end
    always @(*) begin
        if (MemRead)
            read_data = mem[addr[9:2]]; // Word-aligned read
        else
            read_data = 32'b0;
    end
endmodule

// Immediate Generator
module imm_generator (
    input [31:0] instr,
    output reg [31:0] imm_ext
);
    wire [6:0] opcode = instr[6:0];
    always @(*) begin
        case (opcode)
            7'b0010011: // I-type (ADDI, SLTI, etc.)
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            7'b0100011: // S-type (SW)
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: // B-type (BEQ, BNE)
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b1101111: // J-type (JAL)
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            7'b0110111: // U-type (LUI)
                imm_ext = {instr[31:12], 12'b0};
            default: imm_ext = 32'b0;
        endcase
    end
endmodule

// Control Unit
module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg PCSrc,
    output reg [3:0] ALUOp
);
    always @(*) begin
        // Default values
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        ALUSrc = 0;
        PCSrc = 0;
        ALUOp = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, etc.)
                RegWrite = 1;
                ALUSrc = 0;
                case (funct3)
                    3'b000: ALUOp = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b111: ALUOp = 4'b0010; // AND
                    3'b110: ALUOp = 4'b0011; // OR
                    3'b100: ALUOp = 4'b0100; // XOR
                    3'b001: ALUOp = 4'b0101; // SLL
                    3'b101: ALUOp = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRA or SRL
                    3'b010: ALUOp = 4'b1000; // SLT
                    3'b011: ALUOp = 4'b1001; // SLTU
                endcase
            end
            7'b0010011: begin // I-type (ADDI, SLTI, etc.)
                RegWrite = 1;
                ALUSrc = 1;
                case (funct3)
                    3'b000: ALUOp = 4'b0000; // ADDI
                    3'b010: ALUOp = 4'b1000; // SLTI
                    3'b011: ALUOp = 4'b1001; // SLTIU
                    3'b111: ALUOp = 4'b0010; // ANDI
                    3'b110: ALUOp = 4'b0011; // ORI
                    3'b100: ALUOp = 4'b0100; // XORI
                    3'b001: ALUOp = 4'b0101; // SLLI
                    3'b101: ALUOp = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // SRAI or SRLI
                endcase
            end
            7'b0000011: begin // I-type (LW)
                RegWrite = 1;
                MemRead = 1;
                ALUSrc = 1;
                ALUOp = 4'b0000; // ADD for address calculation
            end
            7'b0100011: begin // S-type (SW)
                MemWrite = 1;
                ALUSrc = 1;
                ALUOp = 4'b0000; // ADD for address calculation
            end
            7'b1100011: begin // B-type (BEQ, BNE)
                ALUSrc = 0;
                ALUOp = 4'b0001; // SUB for comparison
                case (funct3)
                    3'b000: PCSrc = (alu_result == 0); // BEQ
                    3'b001: PCSrc = (alu_result != 0); // BNE
                endcase
            end
            7'b1101111: begin // J-type (JAL)
                RegWrite = 1; // Write PC+4 to rd
                PCSrc = 1;
            end
            7'b0110111: begin // U-type (LUI)
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 4'b0000; // Pass immediate directly
            end
        endcase
    end
endmodule