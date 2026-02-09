// ex_mem.sv - EX/MEM Pipeline Register
// Holds outputs of execute stage for use in memory stage.
module ex_mem (
    input  logic         clk,
    input  logic         reset,
    // Inputs from EX stage
    input  logic [63:0]  alu_result_in,
    input  logic [63:0]  rs2_val_in,      // value to store (from rs2) for store instructions
    input  logic [4:0]   rd_idx_in,
    input  logic         reg_write_in,
    input  logic         mem_read_in,
    input  logic         mem_write_in,
    input  logic [2:0]   funct3_in,       // passes the size/type info to memory stage
    input  logic [1:0]   mem_to_reg_in,
    input  logic [63:0]  pc_plus4_in,     // pass along PC+4 for jumps to WB stage
    // Outputs to MEM stage
    output logic [63:0]  alu_result_out,
    output logic [63:0]  rs2_val_out,
    output logic [4:0]   rd_idx_out,
    output logic         reg_write_out,
    output logic         mem_read_out,
    output logic         mem_write_out,
    output logic [2:0]   funct3_out,
    output logic [1:0]   mem_to_reg_out,
    output logic [63:0]  pc_plus4_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 64'b0;
            rs2_val_out    <= 64'b0;
            rd_idx_out     <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            funct3_out     <= 3'b0;
            mem_to_reg_out <= 2'b0;
            pc_plus4_out   <= 64'b0;
        end else begin
            alu_result_out <= alu_result_in;
            rs2_val_out    <= rs2_val_in;
            rd_idx_out     <= rd_idx_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            funct3_out     <= funct3_in;
            mem_to_reg_out <= mem_to_reg_in;
            pc_plus4_out   <= pc_plus4_in;
        end
    end
endmodule

