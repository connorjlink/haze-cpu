// haze-cpu: testbench_instruction_pointer.sv
// (c) 2026 Connor J. Link. All rights reserved.

`timescale 1ns/1ps
`include "../source/instruction_pointer.sv"

module testbench_instruction_pointer;

    time ClockPeriod = 10ns;

    // DUT I/O
    logic        Clock = 1'b0;
    logic        Reset = 1'b0;

    logic        s_iLoad        = 1'b0;
    logic [31:0] s_iLoadAddress = 32'h0000_0000;
    logic        s_iStride      = 1'b0; // 0: increment 2 bytes, 1: increment 4 bytes
    logic        s_iStall       = 1'b0;
    logic [31:0] s_oMemoryAddress;
    logic [31:0] s_oLinkAddress;

    localparam logic [31:0] ResetAddress = 32'h0040_0000;

    instruction_pointer DUT
    (
        .i_Clock         (Clock),
        .i_Reset         (Reset),
        .i_Load          (s_iLoad),
        .i_LoadAddress   (s_iLoadAddress),
        .i_Stride        (s_iStride),
        .i_Stall         (s_iStall),
        .o_MemoryAddress (s_oMemoryAddress),
        .o_LinkAddress   (s_oLinkAddress)
    );

    // Clock generation
    always begin
        Clock = 1'b1;
        #ClockPeriod;
        Clock = 1'b0;
        #ClockPeriod;
    end

    // Reset sequence
    initial begin
        Reset = 1'b0;
        #(ClockPeriod/2);
        Reset = 1'b1;
        #(ClockPeriod*2);
        Reset = 1'b0;
    end

    // VCD dump
    initial begin
        $dumpfile("instruction_pointer.vcd");
        $dumpvars(0, testbench_instruction_pointer);
    end

    // Monitor outputs on each rising edge
    always @(posedge Clock) begin
        $display("[%0t] o_Addr=%08h o_LinkAddr=%08h (Load=%0b Addr=%08h Stride=%0b Stall=%0b)",
                 $time, s_oMemoryAddress, s_oLinkAddress, s_iLoad, s_iLoadAddress, s_iStride, s_iStall);
    end

    // Test cases (inputs change away from clock edges)
    initial begin
        // Wait for Reset deassertion and settle
        wait (Reset == 1'b0);
        @(negedge Clock);
        @(negedge Clock);

        // Test case 1: counting up by 4
        @(negedge Clock);
        s_iLoad        = 1'b0;
        s_iLoadAddress = 32'h0000_0000;
        s_iStride      = 1'b1; // +4
        s_iStall       = 1'b0;

        // Expect: R+8, +C, +10, +14, +18 (link = mem + 4)
        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0008)) else $fatal(1, "TC1 c1 mem exp=%08h got=%08h", ResetAddress+32'h8, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_000C)) else $fatal(1, "TC1 c1 link exp=%08h got=%08h", ResetAddress+32'hC, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_000C)) else $fatal(1, "TC1 c2 mem exp=%08h got=%08h", ResetAddress+32'hC, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0010)) else $fatal(1, "TC1 c2 link exp=%08h got=%08h", ResetAddress+32'h10, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0010)) else $fatal(1, "TC1 c3 mem exp=%08h got=%08h", ResetAddress+32'h10, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0014)) else $fatal(1, "TC1 c3 link exp=%08h got=%08h", ResetAddress+32'h14, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0014)) else $fatal(1, "TC1 c4 mem exp=%08h got=%08h", ResetAddress+32'h14, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0018)) else $fatal(1, "TC1 c4 link exp=%08h got=%08h", ResetAddress+32'h18, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0018)) else $fatal(1, "TC1 c5 mem exp=%08h got=%08h", ResetAddress+32'h18, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_001C)) else $fatal(1, "TC1 c5 link exp=%08h got=%08h", ResetAddress+32'h1C, s_oLinkAddress);

        // Test case 2: counting up by 2
        @(negedge Clock);
        s_iLoad        = 1'b0;
        s_iLoadAddress = 32'h0000_0000;
        s_iStride      = 1'b0; // +2
        s_iStall       = 1'b0;

        // Expect: R+1A, +1C, +1E, +20, +22 (link = mem + 2)
        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_001A)) else $fatal(1, "TC2 c1 mem exp=%08h got=%08h", ResetAddress+32'h1A, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_001C)) else $fatal(1, "TC2 c1 link exp=%08h got=%08h", ResetAddress+32'h1C, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_001C)) else $fatal(1, "TC2 c2 mem exp=%08h got=%08h", ResetAddress+32'h1C, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_001E)) else $fatal(1, "TC2 c2 link exp=%08h got=%08h", ResetAddress+32'h1E, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_001E)) else $fatal(1, "TC2 c3 mem exp=%08h got=%08h", ResetAddress+32'h1E, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0020)) else $fatal(1, "TC2 c3 link exp=%08h got=%08h", ResetAddress+32'h20, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0020)) else $fatal(1, "TC2 c4 mem exp=%08h got=%08h", ResetAddress+32'h20, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC2 c4 link exp=%08h got=%08h", ResetAddress+32'h22, s_oLinkAddress);

        @(posedge Clock);
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC2 c5 mem exp=%08h got=%08h", ResetAddress+32'h22, s_oMemoryAddress);
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0024)) else $fatal(1, "TC2 c5 link exp=%08h got=%08h", ResetAddress+32'h24, s_oLinkAddress);

        // Test case 3: stall counting for both counting modes
        @(negedge Clock);
        s_iLoad        = 1'b0;
        s_iLoadAddress = 32'h0000_0000;
        s_iStride      = 1'b1; // stride=4 but stalled
        s_iStall       = 1'b1;

        // Expect: mem holds R+22, link = mem + 4 (3 cycles)
        repeat (1) @(posedge Clock); // c1
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c1 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0026)) else $fatal(1, "TC3 c1 link");

        repeat (1) @(posedge Clock); // c2
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c2 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0026)) else $fatal(1, "TC3 c2 link");

        repeat (1) @(posedge Clock); // c3
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c3 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0026)) else $fatal(1, "TC3 c3 link");

        // Change stride to 2 while still stalled; mem holds, link updates
        @(negedge Clock);
        s_iStride = 1'b0;

        // Expect: mem holds R+22, link = mem + 2 (3 cycles)
        repeat (1) @(posedge Clock); // c4
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c4 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0024)) else $fatal(1, "TC3 c4 link");

        repeat (1) @(posedge Clock); // c5
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c5 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0024)) else $fatal(1, "TC3 c5 link");

        repeat (1) @(posedge Clock); // c6
        assert (s_oMemoryAddress == (ResetAddress + 32'h0000_0022)) else $fatal(1, "TC3 c6 mem");
        assert (s_oLinkAddress   == (ResetAddress + 32'h0000_0024)) else $fatal(1, "TC3 c6 link");

        // Test case 4: loading a custom address
        @(negedge Clock);
        s_iLoad        = 1'b1;
        s_iLoadAddress = 32'hFEED_FACE;
        s_iStride      = 1'b0; // +2
        s_iStall       = 1'b0;

        // Load cycle
        @(posedge Clock);
        assert (s_oMemoryAddress == 32'hFEED_FACE) else $fatal(1, "TC4 load mem");
        assert (s_oLinkAddress   == 32'hFEED_FAD0) else $fatal(1, "TC4 load link");

        @(negedge Clock);
        s_iLoad        = 1'b0;

        // Then +2 for four cycles: FACE+2, +4, +6, +8
        @(posedge Clock);
        assert (s_oMemoryAddress == 32'hFEED_FAD0) else $fatal(1, "TC4 c1 mem");
        assert (s_oLinkAddress   == 32'hFEED_FAD2) else $fatal(1, "TC4 c1 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'hFEED_FAD2) else $fatal(1, "TC4 c2 mem");
        assert (s_oLinkAddress   == 32'hFEED_FAD4) else $fatal(1, "TC4 c2 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'hFEED_FAD4) else $fatal(1, "TC4 c3 mem");
        assert (s_oLinkAddress   == 32'hFEED_FAD6) else $fatal(1, "TC4 c3 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'hFEED_FAD6) else $fatal(1, "TC4 c4 mem");
        assert (s_oLinkAddress   == 32'hFEED_FAD8) else $fatal(1, "TC4 c4 link");

        // Test case 5: loading zero address then count
        @(negedge Clock);
        s_iLoad        = 1'b1;
        s_iLoadAddress = 32'h0000_0000;
        s_iStride      = 1'b0;
        s_iStall       = 1'b0;

        // Load cycle
        @(posedge Clock);
        assert (s_oMemoryAddress == 32'h0000_0000) else $fatal(1, "TC5 load mem");
        assert (s_oLinkAddress   == 32'h0000_0002) else $fatal(1, "TC5 load link");

        @(negedge Clock);
        s_iLoad        = 1'b0;

        // Then +2 for four cycles: 2, 4, 6, 8
        @(posedge Clock);
        assert (s_oMemoryAddress == 32'h0000_0002) else $fatal(1, "TC5 c1 mem");
        assert (s_oLinkAddress   == 32'h0000_0004) else $fatal(1, "TC5 c1 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'h0000_0004) else $fatal(1, "TC5 c2 mem");
        assert (s_oLinkAddress   == 32'h0000_0006) else $fatal(1, "TC5 c2 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'h0000_0006) else $fatal(1, "TC5 c3 mem");
        assert (s_oLinkAddress   == 32'h0000_0008) else $fatal(1, "TC5 c3 link");

        @(posedge Clock);
        assert (s_oMemoryAddress == 32'h0000_0008) else $fatal(1, "TC5 c4 mem");
        assert (s_oLinkAddress   == 32'h0000_000A) else $fatal(1, "TC5 c4 link");

        $finish;
    end

endmodule