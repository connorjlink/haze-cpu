// Horizon: testbench_registerfile.sv
// (c) 2026 Connor J. Link. All rights reserved.

`timescale 1ns/1ps
`include "registerfile.sv"

module testbench_registerfile;

    // Clocking
    localparam time ClockPeriod = 10; // ns
    logic i_Clock = 1'b0;
    always #(ClockPeriod) i_Clock = ~i_Clock;
    
    // Reset and DUT I/O
    logic        i_Reset        = 1'b0;
    logic [4:0]  i_RS1          = 5'd0;
    logic [4:0]  i_RS2          = 5'd0;
    logic [4:0]  i_RD           = 5'd0;
    logic        i_WriteEnable  = 1'b0;
    logic [31:0] i_D            = 32'h0000_0000;
    logic [31:0] o_DS1;
    logic [31:0] o_DS2;
    
    // DUT
    registerfile DUT
    (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .i_RS1         (i_RS1),
        .i_RS2         (i_RS2),
        .i_RD          (i_RD),
        .i_WriteEnable (i_WriteEnable),
        .i_D           (i_D),
        .o_DS1         (o_DS1),
        .o_DS2         (o_DS2)
    );
    
    // Simple checker
    task automatic check_outputs(string tag, logic [31:0] exp1, logic [31:0] exp2);
        // small settle for comb paths
        #1;
        assert (o_DS1 === exp1)
            else $fatal(1, "FAIL %s: o_DS1 got=0x%08h exp=0x%08h", tag, o_DS1, exp1);
        assert (o_DS2 === exp2)
            else $fatal(1, "FAIL %s: o_DS2 got=0x%08h exp=0x%08h", tag, o_DS2, exp2);
    endtask
    
    // Reset sequence
    initial begin
        i_Reset = 1'b0;
        #(ClockPeriod/2);
        i_Reset = 1'b1;
        #(ClockPeriod*2);
        i_Reset = 1'b0;
    end
    
    // Test cases
    initial begin
       // Initial settle
       #(ClockPeriod);
       #(ClockPeriod/2);
       #(ClockPeriod*2);
       
       // Test Case 1:
       // Write x1 = 0xFEEDFACE; expect read ports still 0 (RS1=RS2=x0)
       @(negedge i_Clock);
       i_RD <= 5'd1;
       i_WriteEnable <= 1'b1;
       i_D <= 32'hFEED_FACE;
       @(posedge i_Clock);
       check_outputs("TC1", 32'h0000_0000, 32'h0000_0000);
       
       // Test Case 2:
       // Write x5 = 0xDEADBEEF; expect read ports still 0 (RS1=RS2=x0)
       @(negedge i_Clock);
       i_RD <= 5'd5;
       i_WriteEnable <= 1'b1;
       i_D <= 32'hDEAD_BEEF;
       @(posedge i_Clock);
       check_outputs("TC2", 32'h0000_0000, 32'h0000_0000);
       
       // Test Case 3:
       // Attempt write with WE=0 (no-op)
       @(negedge i_Clock);
       i_RD <= 5'd4;
       i_WriteEnable <= 1'b0;
       i_D <= 32'hDEAD_BEEF;
       @(posedge i_Clock);
       check_outputs("TC3", 32'h0000_0000, 32'h0000_0000);
       
       // Test Case 4:
       // Write x16 = 0xC0FFEEEE; set RS1=x5; expect DS1=DEADBEEF, DS2=0
       @(negedge i_Clock);
       i_RD <= 5'd16;
       i_WriteEnable <= 1'b1;
       i_D <= 32'hC0FF_EEEE;
       i_RS1 <= 5'd5;
       i_RS2 <= 5'd0;
       @(posedge i_Clock);
       check_outputs("TC4", 32'hDEAD_BEEF, 32'h0000_0000);
       
       // Test Case 5:
       // No write; RS1=x1, RS2=x5; expect DS1=FEEDFACE, DS2=DEADBEEF
       @(negedge i_Clock);
       i_RD <= 5'd0;
       i_WriteEnable <= 1'b0;
       i_D <= 32'h0000_0000;
       i_RS1 <= 5'd1;
       i_RS2 <= 5'd5;
       @(posedge i_Clock);
       check_outputs("TC5", 32'hFEED_FACE, 32'hDEAD_BEEF);
       
       // Test Case 6:
       // RS1=x0, RS2=x5; expect 0 and DEADBEEF
       @(negedge i_Clock);
       i_RS1 <= 5'd0;
       i_RS2 <= 5'd5;
       @(posedge i_Clock);
       check_outputs("TC6", 32'h0000_0000, 32'hDEAD_BEEF);
       
       // Test Case 7:
       // RS1=x16, RS2=x16; expect both C0FFEEEE
       @(negedge i_Clock);
       i_RS1 <= 5'd16;
       i_RS2 <= 5'd16;
       @(posedge i_Clock);
       check_outputs("TC7", 32'hC0FF_EEEE, 32'hC0FF_EEEE);
       
       // Test Case 8:
       // RS1=x0, RS2=x0; expect both 0
       @(negedge i_Clock);
       i_RS1 <= 5'd0;
       i_RS2 <= 5'd0;
       @(posedge i_Clock);
       check_outputs("TC8", 32'h0000_0000, 32'h0000_0000);
       
       $display("All testbench_registerfile tests PASSED.");
       $finish;
    end

endmodule