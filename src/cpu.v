`timescale 1ns / 1ps

module ARM_CPU (
    input wire clk,
    input wire reset_n,
    output wire [31:0] debug_out // Debugging output
);

    // Program Counter (PC)
    reg [31:0] pc;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            pc <= 0;
        else if (opcode == 7'b1100011 && ((instruction[14:12] == 3'b000 && reg_data1 == reg_data2) || 
                                         (instruction[14:12] == 3'b001 && reg_data1 != reg_data2)))
            pc <= pc + {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        else if (opcode == 7'b1101111) // Jump & Link
            pc <= pc + {{11{instruction[31]}}, instruction[30:20]};
        else if (opcode == 7'b1100111) // Jump & Link Register
            pc <= reg_data1 + {{20{instruction[31]}}, instruction[31:20]};
        else
            pc <= pc + 4; // Increment PC by 4 for each instruction
    end

    // Instruction Memory (Simple ROM for now)
    reg [31:0] instr_mem [0:255]; // 256 x 32-bit instructions
    initial begin
        instr_mem[0] = 32'b00000000000100001000000010110011; // ZID r1, r2, r3 (ADD)
        instr_mem[1] = 32'b00000000010000011000000110110011; // NAQS r3, r2, r4 (SUB)
        instr_mem[2] = 32'b00000000100000100000001010110011; // MULT r5, r4, r8 (MUL)
        instr_mem[3] = 32'b00000000000000000000000001101111; // NADHAB (JUMP to 0)
    end
    wire [31:0] instruction;
    assign instruction = instr_mem[pc[9:2]]; // Fetch instruction

    // Register File
    reg [31:0] reg_file [0:31]; // 32 x 32-bit registers
    integer initCount;
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];
    wire [31:0] reg_data1 = reg_file[rs1];
    wire [31:0] reg_data2 = reg_file[rs2];
    initial begin
    for (initCount = 0; initCount < 31; initCount = initCount + 1) begin
      reg_file[initCount] = initCount;
    end


    // Control Unit (Decodes opcode)
    wire [6:0] opcode = instruction[6:0];
    reg write_enable;
    always @(*) begin
        case (opcode)
            7'b0110011: write_enable = 1; // R-Type (ADD, SUB, MUL, etc.)
            7'b0000011: write_enable = 1; // Load
            7'b0100011: write_enable = 0; // Store
            7'b1100011: write_enable = 0; // Branch
            7'b1101111: write_enable = 1; // Jump & Link
            7'b1100111: write_enable = 1; // Jump & Link Register
            default:    write_enable = 0;
        endcase
    end

    // ALU
    reg [31:0] alu_result;
    always @(*) begin
        case (instruction[14:12])
            3'b000: alu_result = reg_data1 + reg_data2; // ZID (ADD)
            3'b001: alu_result = reg_data1 - reg_data2; // NAQS (SUB)
            3'b010: alu_result = reg_data1 * reg_data2; // MULT (MUL)
            3'b011: alu_result = (reg_data1 < reg_data2) ? 1 : 0; // WLA (SLT)
            3'b100: alu_result = reg_data1 ^ reg_data2; // XOR
            3'b101: alu_result = reg_data1 >> reg_data2; // SRL
            3'b110: alu_result = reg_data1 << reg_data2; // SLL
            default: alu_result = 0;
        endcase
    end

    // Load/Store Unit
    reg [31:0] data_memory [0:255]; // Simple Data Memory
    wire [31:0] mem_address = reg_data1 + {{20{instruction[31]}}, instruction[31:20]}; // Address calculation with sign-extension
    reg [31:0] mem_read_data;
    always @(posedge clk) begin
        if (opcode == 7'b0000011) // Load
            mem_read_data <= data_memory[mem_address[9:2]];
        else if (opcode == 7'b0100011) // Store
            data_memory[mem_address[9:2]] <= reg_data2;
    end

    // Write Back Stage
    always @(posedge clk) begin
        if (write_enable)
            reg_file[rd] <= (opcode == 7'b0000011) ? mem_read_data : alu_result; // Load or ALU result
    end

    // Debug Output (Shows current instruction)
    assign debug_out = instruction;

endmodule
