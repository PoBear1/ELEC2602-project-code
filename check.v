module advanced_processor (
    input clk,
    input reset,

    output [15:0] R0_out,
    output [15:0] R1_out,
    output [15:0] R2_out,
    output [15:0] R3_out,
    output [7:0] PC_out,
    output zero_flag_out
);

    // ----------------------------------------------------
    // Instruction format:
    //
    // [15:12] = opcode
    // [11:10] = Rx / destination register
    // [9:8]   = Ry / source register
    // [7:0]   = immediate / address
    //
    // Example:
    // LDI R0, 5
    // instruction = {LDI, R0, 2'b00, 8'd5}
    // ----------------------------------------------------

    // ----------------------------------------------------
    // Opcode definitions
    // ----------------------------------------------------

    parameter NOP       = 4'b0000;
    parameter LDI       = 4'b0001;
    parameter MOV       = 4'b0010;
    parameter ADD       = 4'b0011;
    parameter SUB       = 4'b0100;
    parameter MUL       = 4'b0101;
    parameter AND_OP    = 4'b0110;
    parameter OR_OP     = 4'b0111;
    parameter XOR_OP    = 4'b1000;
    parameter INC       = 4'b1001;
    parameter DEC       = 4'b1010;
    parameter LOAD      = 4'b1011;
    parameter STORE     = 4'b1100;
    parameter JMP       = 4'b1101;
    parameter JZ        = 4'b1110;
    parameter SIMD_ADD8 = 4'b1111;

    // ----------------------------------------------------
    // FSM state definitions
    // ----------------------------------------------------

    parameter FETCH     = 3'd0;
    parameter DECODE    = 3'd1;
    parameter EXECUTE   = 3'd2;
    parameter MEMORY    = 3'd3;
    parameter WRITEBACK = 3'd4;

    reg [2:0] state;

    // ----------------------------------------------------
    // Processor registers
    // ----------------------------------------------------

    reg [15:0] R0;
    reg [15:0] R1;
    reg [15:0] R2;
    reg [15:0] R3;

    reg [7:0] PC;
    reg [15:0] IR;

    reg zero_flag;

    // ----------------------------------------------------
    // Instruction fields
    // ----------------------------------------------------

    wire [3:0] opcode;
    wire [1:0] Rx;
    wire [1:0] Ry;
    wire [7:0] immediate;

    assign opcode = IR[15:12];
    assign Rx = IR[11:10];
    assign Ry = IR[9:8];
    assign immediate = IR[7:0];

    // ----------------------------------------------------
    // Internal memories
    // ----------------------------------------------------

    reg [15:0] instruction_memory [0:255];
    reg [15:0] data_memory [0:255];

    // ----------------------------------------------------
    // Internal temporary registers
    // ----------------------------------------------------

    reg [15:0] Rx_value;
    reg [15:0] Ry_value;
    reg [15:0] alu_result;
    reg [15:0] memory_data;

    // ----------------------------------------------------
    // Outputs for simulation / FPGA display
    // ----------------------------------------------------

    assign R0_out = R0;
    assign R1_out = R1;
    assign R2_out = R2;
    assign R3_out = R3;
    assign PC_out = PC;
    assign zero_flag_out = zero_flag;

    // ----------------------------------------------------
    // Read Rx value
    // ----------------------------------------------------

    always @(*) begin
        case (Rx)
            2'b00: Rx_value = R0;
            2'b01: Rx_value = R1;
            2'b10: Rx_value = R2;
            2'b11: Rx_value = R3;
            default: Rx_value = 16'd0;
        endcase
    end

    // ----------------------------------------------------
    // Read Ry value
    // ----------------------------------------------------

    always @(*) begin
        case (Ry)
            2'b00: Ry_value = R0;
            2'b01: Ry_value = R1;
            2'b10: Ry_value = R2;
            2'b11: Ry_value = R3;
            default: Ry_value = 16'd0;
        endcase
    end

    // ----------------------------------------------------
    // Instruction memory program
    //
    // This is the program stored inside the processor.
    // On FPGA, the processor runs this automatically.
    // ----------------------------------------------------

    initial begin
        // Clear instruction memory
        instruction_memory[0]  = {LDI,       2'b00, 2'b00, 8'd5};     // R0 = 5
        instruction_memory[1]  = {LDI,       2'b01, 2'b00, 8'd3};     // R1 = 3
        instruction_memory[2]  = {ADD,       2'b00, 2'b01, 8'd0};     // R0 = R0 + R1 = 8
        instruction_memory[3]  = {MOV,       2'b10, 2'b00, 8'd0};     // R2 = R0 = 8
        instruction_memory[4]  = {SUB,       2'b10, 2'b01, 8'd0};     // R2 = R2 - R1 = 5

        // Extra arithmetic instructions
        instruction_memory[5]  = {MUL,       2'b11, 2'b10, 8'd0};     // R3 = R3 * R2, currently 0 * 5 = 0
        instruction_memory[6]  = {LDI,       2'b11, 2'b00, 8'd10};    // R3 = 10
        instruction_memory[7]  = {INC,       2'b11, 2'b00, 8'd0};     // R3 = 11
        instruction_memory[8]  = {DEC,       2'b11, 2'b00, 8'd0};     // R3 = 10
        instruction_memory[9]  = {AND_OP,    2'b00, 2'b11, 8'd0};     // R0 = R0 AND R3
        instruction_memory[10] = {OR_OP,     2'b00, 2'b01, 8'd0};     // R0 = R0 OR R1
        instruction_memory[11] = {XOR_OP,    2'b00, 2'b01, 8'd0};     // R0 = R0 XOR R1

        // Load and store memory
        instruction_memory[12] = {STORE,     2'b10, 2'b00, 8'd20};    // MEM[20] = R2
        instruction_memory[13] = {LOAD,      2'b01, 2'b00, 8'd20};    // R1 = MEM[20]

        // SIMD parallel instruction
        instruction_memory[14] = {LDI,       2'b00, 2'b00, 8'h11};    // R0 = 0000000000010001
        instruction_memory[15] = {LDI,       2'b01, 2'b00, 8'h22};    // R1 = 0000000000100010
        instruction_memory[16] = {SIMD_ADD8, 2'b00, 2'b01, 8'd0};     // R0[7:0] + R1[7:0], R0[15:8] + R1[15:8]

        // Conditional branch test
        instruction_memory[17] = {LDI,       2'b10, 2'b00, 8'd1};     // R2 = 1
        instruction_memory[18] = {DEC,       2'b10, 2'b00, 8'd0};     // R2 = 0, zero flag becomes 1
        instruction_memory[19] = {JZ,        2'b10, 2'b00, 8'd22};    // If R2 == 0, jump to address 22

        // This instruction should be skipped if JZ works
        instruction_memory[20] = {LDI,       2'b11, 2'b00, 8'd99};    // R3 = 99, should be skipped
        instruction_memory[21] = {JMP,       2'b00, 2'b00, 8'd23};    // Jump to 23

        // This instruction should run after JZ
        instruction_memory[22] = {LDI,       2'b11, 2'b00, 8'd55};    // R3 = 55

        // Stop here by jumping to itself forever
        instruction_memory[23] = {JMP,       2'b00, 2'b00, 8'd23};    // infinite loop

        // Fill remaining memory with NOPs
        instruction_memory[24] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[25] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[26] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[27] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[28] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[29] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[30] = {NOP, 2'b00, 2'b00, 8'd0};
        instruction_memory[31] = {NOP, 2'b00, 2'b00, 8'd0};
    end

    // ----------------------------------------------------
    // Main FSM
    // ----------------------------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            R0 <= 16'd0;
            R1 <= 16'd0;
            R2 <= 16'd0;
            R3 <= 16'd0;

            PC <= 8'd0;
            IR <= 16'd0;

            zero_flag <= 1'b0;
            alu_result <= 16'd0;
            memory_data <= 16'd0;

            state <= FETCH;
        end

        else begin

            case (state)

                // ----------------------------------------
                // FETCH:
                // Get instruction from instruction memory
                // using the PC.
                // ----------------------------------------

                FETCH: begin
                    IR <= instruction_memory[PC];
                    PC <= PC + 8'd1;
                    state <= DECODE;
                end

                // ----------------------------------------
                // DECODE:
                // The instruction fields are automatically
                // available through opcode, Rx, Ry, immediate.
                // ----------------------------------------

                DECODE: begin
                    state <= EXECUTE;
                end

                // ----------------------------------------
                // EXECUTE:
                // Perform ALU operation or prepare memory/jump.
                // ----------------------------------------

                EXECUTE: begin

                    case (opcode)

                        NOP: begin
                            alu_result <= Rx_value;
                            state <= FETCH;
                        end

                        LDI: begin
                            alu_result <= {8'd0, immediate};
                            state <= WRITEBACK;
                        end

                        MOV: begin
                            alu_result <= Ry_value;
                            state <= WRITEBACK;
                        end

                        ADD: begin
                            alu_result <= Rx_value + Ry_value;
                            state <= WRITEBACK;
                        end

                        SUB: begin
                            alu_result <= Rx_value - Ry_value;
                            state <= WRITEBACK;
                        end

                        MUL: begin
                            alu_result <= Rx_value * Ry_value;
                            state <= WRITEBACK;
                        end

                        AND_OP: begin
                            alu_result <= Rx_value & Ry_value;
                            state <= WRITEBACK;
                        end

                        OR_OP: begin
                            alu_result <= Rx_value | Ry_value;
                            state <= WRITEBACK;
                        end

                        XOR_OP: begin
                            alu_result <= Rx_value ^ Ry_value;
                            state <= WRITEBACK;
                        end

                        INC: begin
                            alu_result <= Rx_value + 16'd1;
                            state <= WRITEBACK;
                        end

                        DEC: begin
                            alu_result <= Rx_value - 16'd1;
                            state <= WRITEBACK;
                        end

                        LOAD: begin
                            state <= MEMORY;
                        end

                        STORE: begin
                            state <= MEMORY;
                        end

                        JMP: begin
                            PC <= immediate;
                            state <= FETCH;
                        end

                        JZ: begin
                            if (Rx_value == 16'd0) begin
                                PC <= immediate;
                            end
                            state <= FETCH;
                        end

                        SIMD_ADD8: begin
                            // ------------------------------------------------
                            // Advanced instruction:
                            //
                            // Treat one 16-bit register as two 8-bit values:
                            //
                            // Rx[15:8] = Rx[15:8] + Ry[15:8]
                            // Rx[7:0]  = Rx[7:0]  + Ry[7:0]
                            //
                            // This is a simple SIMD-style parallel operation.
                            // ------------------------------------------------

                            alu_result[7:0]  <= Rx_value[7:0]  + Ry_value[7:0];
                            alu_result[15:8] <= Rx_value[15:8] + Ry_value[15:8];

                            state <= WRITEBACK;
                        end

                        default: begin
                            state <= FETCH;
                        end

                    endcase
                end

                // ----------------------------------------
                // MEMORY:
                // Handles LOAD and STORE.
                // ----------------------------------------

                MEMORY: begin

                    case (opcode)

                        LOAD: begin
                            memory_data <= data_memory[immediate];
                            state <= WRITEBACK;
                        end

                        STORE: begin
                            data_memory[immediate] <= Rx_value;
                            state <= FETCH;
                        end

                        default: begin
                            state <= FETCH;
                        end

                    endcase
                end

                // ----------------------------------------
                // WRITEBACK:
                // Write ALU result or memory data back into Rx.
                // ----------------------------------------

                WRITEBACK: begin

                    case (Rx)

                        2'b00: begin
                            if (opcode == LOAD)
                                R0 <= memory_data;
                            else
                                R0 <= alu_result;
                        end

                        2'b01: begin
                            if (opcode == LOAD)
                                R1 <= memory_data;
                            else
                                R1 <= alu_result;
                        end

                        2'b10: begin
                            if (opcode == LOAD)
                                R2 <= memory_data;
                            else
                                R2 <= alu_result;
                        end

                        2'b11: begin
                            if (opcode == LOAD)
                                R3 <= memory_data;
                            else
                                R3 <= alu_result;
                        end

                    endcase

                    if (opcode == LOAD) begin
                        zero_flag <= (memory_data == 16'd0);
                    end
                    else begin
                        zero_flag <= (alu_result == 16'd0);
                    end

                    state <= FETCH;
                end

                default: begin
                    state <= FETCH;
                end

            endcase
        end
    end

endmodule