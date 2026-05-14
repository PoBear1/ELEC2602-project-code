`timescale 1ns/1ps
module tb_adc;
    parameter N = 8;

    reg [N-1:0] a, b;
    reg c;
    wire [N-1:0] x;
    wire cout, z, n, o;

    adc #(.N(N)) dut (.a(a), .b(b), .c(c), .x(x), .cout(cout), .z(z), .n(n), .o(o));

    integer pass, fail;

    task check;
        input [N-1:0] exp_x;
        input exp_cout, exp_z, exp_n, exp_o;
        input [63:0] test_id;
        begin
            #1;
            if (x === exp_x && cout === exp_cout && z === exp_z && n === exp_n && o === exp_o) begin
                pass = pass + 1;
            end else begin
                fail = fail + 1;
                $display("FAIL test %0d: a=%0d b=%0d c=%0d | got x=%0d cout=%b z=%b n=%b o=%b | exp x=%0d cout=%b z=%b n=%b o=%b",
                    test_id, a, b, c, x, cout, z, n, o, exp_x, exp_cout, exp_z, exp_n, exp_o);
            end
        end
    endtask

    initial begin
        pass = 0; fail = 0;

        // --- Basic addition, no carry-in ---
        // 0 + 0 + 0 = 0 (z=1)
        a=0;   b=0;   c=0; check(0,   0, 1, 0, 0, 1);
        // 1 + 0 = 1
        a=1;   b=0;   c=0; check(1,   0, 0, 0, 0, 2);
        // 0 + 1 = 1
        a=0;   b=1;   c=0; check(1,   0, 0, 0, 0, 3);
        // 3 + 5 = 8
        a=3;   b=5;   c=0; check(8,   0, 0, 0, 0, 4);
        // 14 + 16 = 30
        a=14;  b=16;  c=0; check(30,  0, 0, 0, 0, 5);

        // --- Carry-in ---
        // 0 + 0 + 1 = 1
        a=0;   b=0;   c=1; check(1,   0, 0, 0, 0, 6);
        // 3 + 5 + 1 = 9
        a=3;   b=5;   c=1; check(9,   0, 0, 0, 0, 7);
        // 255 + 0 + 1 = 256 → x=0, cout=1, z=1
        a=8'hFF; b=0; c=1; check(0,   1, 1, 0, 0, 8);

        // --- Carry-out (unsigned overflow) ---
        // 255 + 1 = 256 → x=0, cout=1, z=1
        a=8'hFF; b=1; c=0; check(0,   1, 1, 0, 0, 9);
        // 255 + 255 = 510 → x=254, cout=1
        a=8'hFF; b=8'hFF; c=0; check(8'hFE, 1, 0, 1, 0, 10);
        // -128 + -128 = -256 → x=0, cout=1, z=1, overflow (neg+neg=pos)
        a=8'h80; b=8'h80; c=0; check(0,   1, 1, 0, 1, 11);

        // --- Zero flag ---
        // Result = 0 with cout
        a=8'hFF; b=1; c=0; check(0,   1, 1, 0, 0, 12);
        // Explicit 0 result without cout (already tested as test 1)

        // --- Negative flag (MSB=1) ---
        // 127 + 1 = 128 (0x80), MSB=1
        a=127; b=1; c=0; check(128, 0, 0, 1, 1, 13);
        // 200 + 0 = 200 (MSB=1)
        a=200; b=0; c=0; check(200, 0, 0, 1, 0, 14);

        // --- Signed overflow ---
        // +127 + +1 = +128 (interpreted as -128): pos+pos=neg → overflow
        a=8'd127; b=8'd1;   c=0; check(8'd128, 0, 0, 1, 1, 15);
        // -128 + -1 = -129 (wraps to +127): neg+neg=pos → overflow
        a=8'h80; b=8'hFF; c=0; check(8'h7F, 1, 0, 0, 1, 16);
        // -1 + +1 = 0: no overflow
        a=8'hFF; b=8'h01; c=0; check(0,   1, 1, 0, 0, 17);
        // -64 + -64 = -128 (exactly representable): no overflow
        a=8'hC0; b=8'hC0; c=0; check(8'h80, 1, 0, 1, 0, 18);
        // +64 + +63 = +127: no overflow
        a=64; b=63; c=0; check(127, 0, 0, 0, 0, 19);

        // --- Carry-in affects overflow boundary ---
        // +126 + +1 + c=1 = +128 → overflow
        a=126; b=1; c=1; check(128, 0, 0, 1, 1, 20);

        $display("Results: %0d passed, %0d failed", pass, fail);
        $finish;
    end
endmodule
