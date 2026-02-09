// imem.sv - Instruction Memory module (simple synthesized ROM for instructions)
// Provides instruction corresponding to the given address. Assumes word-aligned access.
// For simplicity, read is combinational (synchronous read logic can be used for actual block RAM).
module imem #(parameter MEM_DEPTH = 256) (
    input  logic [63:0] addr,         // Byte address for instruction fetch (assumes 64-bit address)
    output logic [31:0] instr        // 32-bit instruction output
);
    // Memory array (32-bit words)
    logic [31:0] memory [0:MEM_DEPTH-1];

    // Optionally, initialize memory from file (e.g., using $readmemh) 
    // initial $readmemh("program.hex", memory);
      integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 32'h00000013; // NOP
    end

    // Word index (assuming little-endian and word-aligned addresses)
    logic [63:0] word_index;
    always_comb begin
        word_index = addr >> 2;              // Divide address by 4 to get word index (ignores lower 2 bits)
        if (word_index < MEM_DEPTH) begin
            instr = memory[word_index];
        end else begin
            instr = 32'h00000013;            // NOP (ADDI x0,x0,0) if out-of-range address
        end
    end
endmodule

