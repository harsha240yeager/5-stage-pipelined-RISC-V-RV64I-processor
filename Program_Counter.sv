// pc.sv - Program Counter module
// This module holds the current program counter (PC) value and updates it on each clock cycle.
// It supports enabling/disabling updates (for stalling) and resets PC to 0 on reset.
// The next PC value is provided externally (either PC+4 for sequential flow or a branch/jump target).
module pc #(parameter XLEN = 64) (
    input  logic             clk,
    input  logic             reset,
    input  logic             enable,      // PCWrite: when low, PC will not update (stall)
    input  logic [XLEN-1:0]  next_pc,
    output logic [XLEN-1:0]  pc_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 0;  // start at 0 (could be a parameter for start address)
        end else if (enable) begin
            pc_out <= next_pc;
        end
        // If not reset and enable is low (stall), PC holds its value
    end
endmodule

