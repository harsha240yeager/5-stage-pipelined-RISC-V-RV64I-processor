module dmem #(parameter int MEM_BYTES = 1024) (
    input  logic         clk,
    input  logic [63:0]  addr,       // Byte address for data memory
    input  logic [63:0]  wdata,      // Data to write (for store instructions)
    input  logic         mem_read,   // Load enable
    input  logic         mem_write,  // Store enable
    input  logic [2:0]   funct3,     // Type of access (from instruction funct3)
    output logic [63:0]  rdata       // Data read (for load instructions)
);
    // Memory array as bytes
    logic [7:0] memory [0:MEM_BYTES-1];

    // ------------------------------
    // Initialize memory (important!!)
    // ------------------------------
    integer i;
    initial begin
        for (i = 0; i < MEM_BYTES; i = i + 1) begin
            memory[i] = 8'd0;
        end
    end

    // ------------------------------
    // Combinational read (safe)
    // ------------------------------
    always_comb begin
        // default
        rdata = 64'b0;

        if (mem_read) begin
            automatic int unsigned idx;
            automatic logic [7:0] b0, b1, b2, b3, b4, b5, b6, b7;

            // compute byte index safely (wrap/truncate to memory size)
            // Use the low bits of the address but modulo ensures safe access.
            idx = addr % MEM_BYTES; // safer than slicing; works even if MEM_BYTES isn't power of 2

            // Read bytes (little-endian)
            b0 = memory[idx];
            b1 = memory[(idx + 1) % MEM_BYTES];
            b2 = memory[(idx + 2) % MEM_BYTES];
            b3 = memory[(idx + 3) % MEM_BYTES];
            b4 = memory[(idx + 4) % MEM_BYTES];
            b5 = memory[(idx + 5) % MEM_BYTES];
            b6 = memory[(idx + 6) % MEM_BYTES];
            b7 = memory[(idx + 7) % MEM_BYTES];

            case (funct3)
                3'b000: rdata = {{56{b0[7]}}, b0};                             // LB (sign-extend byte)
                3'b001: rdata = {{48{b1[7]}}, b1, b0};                         // LH (sign-extend 16)
                3'b010: rdata = {{32{b3[7]}}, b3, b2, b1, b0};                 // LW (sign-extend 32)
                3'b011: rdata = {b7, b6, b5, b4, b3, b2, b1, b0};              // LD (64-bit)
                3'b100: rdata = {56'b0, b0};                                   // LBU
                3'b101: rdata = {48'b0, b1, b0};                               // LHU
                3'b110: rdata = {32'b0, b3, b2, b1, b0};                       // LWU
                default: rdata = 64'b0;
            endcase
        end
    end

    // ------------------------------
    // Synchronous write (safe)
    // ------------------------------
    always_ff @(posedge clk) begin
        if (mem_write) begin
            automatic int unsigned idx;
            idx = addr % MEM_BYTES;

            case (funct3)
                3'b000: memory[idx]     <= wdata[7:0];                // SB
                3'b001: begin                                         // SH
                    memory[idx]     <= wdata[7:0];
                    memory[(idx+1) % MEM_BYTES] <= wdata[15:8];
                end
                3'b010: begin                                         // SW
                    memory[idx]     <= wdata[7:0];
                    memory[(idx+1) % MEM_BYTES] <= wdata[15:8];
                    memory[(idx+2) % MEM_BYTES] <= wdata[23:16];
                    memory[(idx+3) % MEM_BYTES] <= wdata[31:24];
                end
                3'b011: begin                                         // SD
                    memory[idx]     <= wdata[7:0];
                    memory[(idx+1) % MEM_BYTES] <= wdata[15:8];
                    memory[(idx+2) % MEM_BYTES] <= wdata[23:16];
                    memory[(idx+3) % MEM_BYTES] <= wdata[31:24];
                    memory[(idx+4) % MEM_BYTES] <= wdata[39:32];
                    memory[(idx+5) % MEM_BYTES] <= wdata[47:40];
                    memory[(idx+6) % MEM_BYTES] <= wdata[55:48];
                    memory[(idx+7) % MEM_BYTES] <= wdata[63:56];
                end
                default: ;
            endcase
        end
    end

endmodule

