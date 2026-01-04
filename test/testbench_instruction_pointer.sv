// Horizon: instruction_pointer.sv
// (c) 2026 Connor J. Link. All rights reserved.

`timescale 1ns/1ps
`include "instruction_pointer.sv"

module instruction_pointer_tb;

    // Parameters
    localparam logic [31:0] RESET_ADDRESS = 32'h0040_0000;

    // DUT I/O
    logic        i_Clock;
    logic        i_Reset;
    logic        i_Load;
    logic [31:0] i_Address;
    logic        i_Stride; // 0: +2 bytes, 1: +4 bytes
    logic        i_Stall;
    logic [31:0] o_Address;
    logic [31:0] o_LinkAddress;

    // Instantiate DUT
    instruction_pointer #(.p_ResetAddress(RESET_ADDRESS)) DUT
    (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .i_Load        (i_Load),
        .i_Address     (i_Address),
        .i_Stride      (i_Stride),
        .i_Stall       (i_Stall),
        .o_Address     (o_Address),
        .o_LinkAddress (o_LinkAddress)
    );

    // Clock generation (100 MHz)
    initial i_Clock = 0;
    always #5 i_Clock = ~i_Clock;

    // Reference model state
    logic [31:0] ref_ip;
    logic [31:0] ref_link;

    // Helper: compute stride value
    function automatic int stride_val(input logic stride_bit);
        return stride_bit ? 4 : 2;
    endfunction

    // Helper: update reference model (matches DUT semantics)
    task automatic update_ref;
        int sv;
        logic we;
        sv = stride_val(i_Stride);
        we = (i_Load ? 1'b1 : (i_Stall ? 1'b0 : 1'b1));

        if (we) begin
            if (i_Reset)
                ref_ip = RESET_ADDRESS;                    // reset has priority over load in data mux
            else if (i_Load)
                ref_ip = i_Address;
            else
                ref_ip = ref_ip + sv;                 // normal increment
        end
        // Link is combinational from current IP and this cycle's stride
        ref_link = ref_ip + sv;
    endtask

    // Drive, tick, check
    task automatic tick_and_check(
            input logic             t_reset,
            input logic             t_load,
            input logic [31:0] t_addr,
            input logic             t_stride,
            input logic             t_stall,
            input string            tag
    );
        // Drive inputs before clock edge
        i_Reset     = t_reset;
        i_Load      = t_load;
        i_Address   = t_addr;
        i_Stride    = t_stride;
        i_Stall     = t_stall;

        // Tick
        @(posedge i_Clock);
        update_ref();
        #1;

        // Assertions
        assert (o_Address == ref_ip)
            else begin
                $error("[%s] o_Address mismatch exp=%08h got=%08h", tag, ref_ip, o_Address);
                $fatal;
            end
        assert (o_LinkAddress == ref_link)
            else begin
                $error("[%s] o_LinkAddress mismatch exp=%08h got=%08h", tag, ref_link, o_LinkAddress);
                $fatal;
            end
        $display("[%0t] PASS %s IP=%08h LINK=%08h stride=%0d load=%0b stall=%0b reset=%0b",
                         $time, tag, o_Address, o_LinkAddress, stride_val(i_Stride), i_Load, i_Stall, i_Reset);
    endtask

    // Test sequence
    initial begin
        // Initialize
        i_Reset     = 0;
        i_Load        = 0;
        i_Address = 32'h0000_0000;
        i_Stride    = 0;
        i_Stall     = 0;
        ref_ip        = 32'h0000_0000; // will be set by reset
        ref_link    = 32'h0;

        // Sync to clock
        @(posedge i_Clock);

        // 1) Reset (no stall), stride=2
        tick_and_check(1'b1, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "reset_no_stall_stride2");

        // 2) Increment by 2 for several cycles (no stall, no load)
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "inc2_cycle1");
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "inc2_cycle2");
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "inc2_cycle3");

        // 3) Stall for two cycles (no load), IP holds; link reflects current stride
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b1, "stall_hold_cycle1");
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b1, "stall_hold_cycle2");

        // 4) Change stride while stalled: IP holds, link updates with new stride
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b1, 1'b1, "stall_stride_change_link_updates");

        // 5) Load while stalled: load overrides stall; IP loads i_Address
        tick_and_check(1'b0, 1'b1, 32'h1000_0000, 1'b1, 1'b1, "load_overrides_stall");
        // Stall without load after load: IP holds at loaded address; link tracks stride
        tick_and_check(1'b0, 1'b0, 32'hDEAD_BEEF, 1'b1, 1'b1, "stall_after_load_holds");

        // 6) Change stride to 4 (if not already), no stall, increment by 4
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b1, 1'b0, "inc4_cycle1");
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b1, 1'b0, "inc4_cycle2");

        // 7) Reset while stalled: write disabled; IP holds; link recomputed from held IP
        tick_and_check(1'b1, 1'b0, 32'h0000_0000, 1'b1, 1'b1, "reset_while_stalled_holds");

        // 8) Reset with load asserted: write enabled via load; reset wins in data mux
        tick_and_check(1'b1, 1'b1, 32'h2000_0000, 1'b0, 1'b1, "reset_with_load_sets_reset_addr");

        // 9) Post-reset increment by 2 with no stall/load
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "post_reset_inc2_cycle1");
        tick_and_check(1'b0, 1'b0, 32'h0000_0000, 1'b0, 1'b0, "post_reset_inc2_cycle2");

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule