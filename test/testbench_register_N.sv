// Horizon: testbench_register_N.sv
// (c) 2026 Connor J. Link. All rights reserved.

`timescale 1ns/1ps
`include "register_N.sv"

module testbench_register_N;

    // Parameters
    localparam time ClockPeriod  = 10;  // ns
    localparam int  DATA_WIDTH = 32;

    // DUT signals
    logic                   i_Clock;
    logic                   i_Reset;
    logic                   i_WriteEnable;
    logic [DATA_WIDTH-1:0]  i_D;
    logic [DATA_WIDTH-1:0]  o_Q;

    // Reference model signal
    logic [DATA_WIDTH-1:0]  ref_Q;

    // Instantiate DUT
    register_N #(.N(DATA_WIDTH)) DUT
    (
      .i_Clock       (i_Clock),
      .i_Reset       (i_Reset),
      .i_WriteEnable (i_WriteEnable),
      .i_D           (i_D),
      .o_Q           (o_Q)
    );

    // Clock generation (toggle every half-period)
    initial begin
        i_Clock = 0;
        forever #(ClockPeriod) i_Clock = ~i_Clock;
    end

    // Asynchronous reset sequence (assert for 2 half-cycles)
    initial begin
        i_Reset = 0;
        #(ClockPeriod/2);
        i_Reset = 1;
        #(2 * ClockPeriod);
        i_Reset = 0;
    end

    // Test stimulus (aligned to non-clock edges)
    initial begin
        // Defaults
        i_WriteEnable = 0;
        i_D           = '0;

        // Avoid changing inputs on clock edges
        #(ClockPeriod);
        #(ClockPeriod/2);

        // Test Case 1: WE=0, D=0000_FFFF -> expect Q=0000_0000
        i_WriteEnable = 0;
        i_D           = 32'h0000_FFFF;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'h0000_0000)
            else $fatal(1, "TC1 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'h0000_0000);

        // Test Case 2: WE=1, D=0000_FFFF -> expect Q=0000_FFFF
        i_WriteEnable = 1;
        i_D           = 32'h0000_FFFF;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'h0000_FFFF)
            else $fatal(1, "TC2 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'h0000_FFFF);

        // Test Case 3: WE=0, D=0000_0000 -> expect Q=0000_FFFF
        i_WriteEnable = 0;
        i_D           = 32'h0000_0000;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'h0000_FFFF)
            else $fatal(1, "TC3 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'h0000_FFFF);

        // Test Case 4: WE=0, D=AAAA_0000 -> expect Q=0000_FFFF
        i_WriteEnable = 0;
        i_D           = 32'hAAAA_0000;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'h0000_FFFF)
            else $fatal(1, "TC4 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'h0000_FFFF);

        // Test Case 5: WE=1, D=AAAA_0000 -> expect Q=AAAA_0000
        i_WriteEnable = 1;
        i_D           = 32'hAAAA_0000;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'hAAAA_0000)
            else $fatal(1, "TC5 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'hAAAA_0000);

        // Test Case 6: WE=1, D=FEED_FACE -> expect Q=FEED_FACE
        i_WriteEnable = 1;
        i_D           = 32'hFEED_FACE;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'hFEED_FACE)
            else $fatal(1, "TC6 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'hFEED_FACE);

        // Test Case 7: WE=0, D=DEAD_BEEF -> expect Q=FEED_FACE
        i_WriteEnable = 0;
        i_D           = 32'hDEAD_BEEF;
        @(posedge i_Clock); #1;
        assert (o_Q == 32'hFEED_FACE)
            else $fatal(1, "TC7 FAIL @%0t: o_Q=%h expected=%h", $time, o_Q, 32'hFEED_FACE);

        $display("tb_register_N: PASS");
        $finish;
    end

endmodule