// register_file.sv - Register File module
// 32 × XLEN-bit registers, 2 read ports, 1 write port
// x0 is hardwired to zero (RISC-V compliant)

module register_file #(
    parameter XLEN = 64,
    parameter REG_COUNT = 32
) (
    input  logic               clk,
    input  logic [4:0]         rs1_idx,
    input  logic [4:0]         rs2_idx,
    input  logic [4:0]         rd_idx,
    input  logic [XLEN-1:0]    rd_data,
    input  logic               reg_write,
    output logic [XLEN-1:0]    rs1_data,
    output logic [XLEN-1:0]    rs2_data
);

    // Register storage
    logic [XLEN-1:0] regs [0:REG_COUNT-1];

    // --------------------------------------------------
    // Initialization (SIMULATION FRIENDLY)
    // --------------------------------------------------
    integer i;
    initial begin
        for (i = 0; i < REG_COUNT; i = i + 1) begin
            regs[i] = {XLEN{1'b0}};
        end
    end

    // --------------------------------------------------
    // Write port (x0 is read-only zero)
    // --------------------------------------------------
    always_ff @(posedge clk) begin
        if (reg_write && (rd_idx != 5'd0)) begin
            regs[rd_idx] <= rd_data;
        end
        // Optional: force x0 to zero every cycle (extra safety)
        regs[5'd0] <= {XLEN{1'b0}};
    end

    // --------------------------------------------------
    // Read ports (combinational)
    // --------------------------------------------------
    assign rs1_data = (rs1_idx == 5'd0) ? {XLEN{1'b0}} : regs[rs1_idx];
    assign rs2_data = (rs2_idx == 5'd0) ? {XLEN{1'b0}} : regs[rs2_idx];

endmodule

