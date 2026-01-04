// Horizon: testbench_comparator.sv
// (c) 2026 Connor J. Link. All rights reserved.

`timescale 1ns/1ps
`include "comparator.sv"

`define N 20000

module testbench_comparator;

    // DUT I/O
    logic [31:0] i_A;
    logic [31:0] i_B;
    logic [31:0] o_IsLess;
    logic [31:0] o_IsLessUnsigned;

    // Instantiate DUT
    comparator DUT
    (
        .i_A              (i_A),
        .i_B              (i_B),
        .o_IsLess         (o_IsLess),
        .o_IsLessUnsigned (o_IsLessUnsigned)
    );

    // Reference model
    function automatic logic [31:0] ref_less_signed(input logic [31:0] a, input logic [31:0] b);
        ref_less_signed = ($signed(a) < $signed(b)) ? 32'h0000_0001 : 32'h0000_0000;
    endfunction

    function automatic logic [31:0] ref_less_unsigned(input logic [31:0] a, input logic [31:0] b);
        ref_less_unsigned = (a < b) ? 32'h0000_0001 : 32'h0000_0000;
    endfunction

    // Single check
    task automatic apply_and_check(input logic [31:0] a, input logic [31:0] b, input string tag = "");
        logic [31:0] exp_s;
        logic [31:0] exp_u;
        string tag_suffix;
        begin
            i_A = a;
            i_B = b;

            // Allow combinational settle (safe for zero-delay assigns too)
            #1;

            exp_s = ref_less_signed(a, b);
            exp_u = ref_less_unsigned(a, b);

            // Build optional tag suffix as a proper string
            tag_suffix = (tag == "") ? "" : $sformatf(" [%s]", tag);

            // Autochecking assertions
            assert (o_IsLess === exp_s)
                else $fatal(1,
                    "FAIL signed%s: A=0x%08h (%0d) B=0x%08h (%0d) got=0x%08h exp=0x%08h",
                    tag_suffix,
                    a, $signed(a), b, $signed(b), o_IsLess, exp_s
                );

            assert (o_IsLessUnsigned === exp_u)
                else $fatal(1,
                    "FAIL unsigned%s: A=0x%08h (%0u) B=0x%08h (%0u) got=0x%08h exp=0x%08h",
                    tag_suffix,
                    a, a, b, b, o_IsLessUnsigned, exp_u
                );

            // Optional: ensure outputs are canonical 0/1 in bit0 only
            assert ((o_IsLess === 32'h0) || (o_IsLess === 32'h1))
                else $fatal(1, "FAIL canonical signed%s: o_IsLess=0x%08h", tag_suffix, o_IsLess);

            assert ((o_IsLessUnsigned === 32'h0) || (o_IsLessUnsigned === 32'h1))
                else $fatal(1, "FAIL canonical unsigned%s: o_IsLessUnsigned=0x%08h", tag_suffix, o_IsLessUnsigned);
        end
    endtask

    // Random helper (makes distribution a bit richer for signed edge cases)
    function automatic logic [31:0] rand32();
        rand32 = {$urandom(), $urandom()}; // 64 -> truncated to 32, still fine
    endfunction

    initial begin
        // Init
        i_A = '0;
        i_B = '0;
        #1;

        // Directed tests (basic)
        apply_and_check(32'h0000_0000, 32'h0000_0000, "eq_zero");
        apply_and_check(32'h0000_0000, 32'h0000_0001, "0<1");
        apply_and_check(32'h0000_0001, 32'h0000_0000, "1<0");

        // Signed vs unsigned difference cases
        // A = -1 (0xFFFF_FFFF), B = +1
        // unsigned: 0xFFFF_FFFF > 1 -> lessUnsigned=0
        // signed: -1 < 1 -> lessSigned=1
        apply_and_check(32'hFFFF_FFFF, 32'h0000_0001, "signed_vs_unsigned_1");

        // A = 0x8000_0000 (most negative), B = 0
        // signed: negative < 0 -> 1
        // unsigned: 0x8000_0000 > 0 -> 0
        apply_and_check(32'h8000_0000, 32'h0000_0000, "signed_vs_unsigned_2");

        // Extremes
        apply_and_check(32'h7FFF_FFFF, 32'h8000_0000, "maxpos_vs_minneg");
        apply_and_check(32'h8000_0000, 32'h7FFF_FFFF, "minneg_vs_maxpos");
        apply_and_check(32'hFFFF_FFFF, 32'hFFFF_FFFE, "neg1_vs_neg2");
        apply_and_check(32'hFFFF_FFFE, 32'hFFFF_FFFF, "neg2_vs_neg1");

        // Some boundary unsigned cases
        apply_and_check(32'h0000_0000, 32'hFFFF_FFFF, "u0_vs_umax");
        apply_and_check(32'hFFFF_FFFF, 32'h0000_0000, "umax_vs_u0");

        // Random tests
        for (int unsigned k = 0; k < `N; k++) begin
            logic [31:0] a;
            logic [31:0] b;
            a = rand32();
            b = rand32();
            apply_and_check(a, b, $sformatf("rand_%0d", k));
        end

        $display("PASS: testbench_comparator completed (%0d random + directed).", `N);
        $finish;
    end

endmodule
