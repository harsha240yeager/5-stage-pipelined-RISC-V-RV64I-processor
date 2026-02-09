// if_id.sv - IF/ID Pipeline Register
// Holds instruction fetch stage outputs for use in decode stage (ID).
module if_id (
    input  logic         clk,
    input  logic         reset,
    input  logic         enable,       // Enable (freeze if low)
    input  logic         flush,        // Flush (insert NOP) if high
    input  logic [63:0]  pc_in,
    input  logic [31:0]  instr_in,
    output logic [63:0]  pc_out,
    output logic [31:0]  instr_out
);
    // We define a constant for NOP instruction (ADDI x0,x0,0)
    localparam [31:0] NOP_INSTR = 32'h00000013;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out    <= 64'b0;
            instr_out <= NOP_INSTR;
        end else if (flush) begin
            // On flush, output a NOP to effectively cancel the instruction in ID stage
            pc_out    <= 64'b0;
            instr_out <= NOP_INSTR;
        end else if (enable) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end // if enable is low (stall), retain previous values (hold state)
    end
endmodule

