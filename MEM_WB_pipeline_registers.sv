// mem_wb.sv - MEM/WB Pipeline Register
// Holds outputs of memory stage for use in write-back stage.
module mem_wb (
    input  logic         clk,
    input  logic         reset,
    // Inputs from MEM stage
    input  logic [63:0]  alu_result_in,
    input  logic [63:0]  mem_data_in,
    input  logic [4:0]   rd_idx_in,
    input  logic         reg_write_in,
    input  logic [1:0]   mem_to_reg_in,
    input  logic [63:0]  pc_plus4_in,
    // Outputs to WB stage
    output logic [63:0]  alu_result_out,
    output logic [63:0]  mem_data_out,
    output logic [4:0]   rd_idx_out,
    output logic         reg_write_out,
    output logic [1:0]   mem_to_reg_out,
    output logic [63:0]  pc_plus4_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 64'b0;
            mem_data_out   <= 64'b0;
            rd_idx_out     <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
            pc_plus4_out   <= 64'b0;
        end else begin
            alu_result_out <= alu_result_in;
            mem_data_out   <= mem_data_in;
            rd_idx_out     <= rd_idx_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            pc_plus4_out   <= pc_plus4_in;
        end
    end
endmodule

