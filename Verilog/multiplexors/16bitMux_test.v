// filepath: /Users/eric/Documents/GitHub/verilog-lab/multiplexors/16bitMux_test.v
// Test bench for 16-bit multiplexer

`include "multiplexors/16bitMux.v"

module Mux16bit_test;
    // Test inputs
    reg [15:0] a, b;
    reg sel;
    
    // Test outputs
    wire [15:0] out;
    
    // Instantiate the Unit Under Test (UUT)
    Mux16bit uut (
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );
    
    // Test procedure
    initial begin
        // Display header
        $display("Testing 16-bit Multiplexer");
        $display("Time\ta\t\tb\t\tsel\tout");
        $display("----\t----\t\t----\t\t---\t----");
        
        // Monitor changes
        $monitor("%0t\t%h\t%h\t%b\t%h", $time, a, b, sel, out);
        
        // Test Case 1: Basic functionality with sel = 0 (should select input a)
        a = 16'h1234; b = 16'h5678; sel = 0;
        #10;
        if (out !== a) begin
            $display("ERROR: sel=0, expected %h, got %h", a, out);
        end else begin
            $display("PASS: sel=0 correctly selects input a");
        end
        
        // Test Case 2: Basic functionality with sel = 1 (should select input b)
        sel = 1;
        #10;
        if (out !== b) begin
            $display("ERROR: sel=1, expected %h, got %h", b, out);
        end else begin
            $display("PASS: sel=1 correctly selects input b");
        end
        
        // Test Case 3: All zeros
        a = 16'h0000; b = 16'hFFFF; sel = 0;
        #10;
        if (out !== 16'h0000) begin
            $display("ERROR: All zeros test failed");
        end else begin
            $display("PASS: All zeros test");
        end
        
        // Test Case 4: All ones
        a = 16'hFFFF; b = 16'h0000; sel = 0;
        #10;
        if (out !== 16'hFFFF) begin
            $display("ERROR: All ones test failed");
        end else begin
            $display("PASS: All ones test");
        end
        
        // Test Case 5: Alternating pattern
        a = 16'hAAAA; b = 16'h5555; sel = 0;
        #10;
        if (out !== 16'hAAAA) begin
            $display("ERROR: Alternating pattern test (sel=0) failed");
        end else begin
            $display("PASS: Alternating pattern test (sel=0)");
        end
        
        sel = 1;
        #10;
        if (out !== 16'h5555) begin
            $display("ERROR: Alternating pattern test (sel=1) failed");
        end else begin
            $display("PASS: Alternating pattern test (sel=1)");
        end
        
        // Test Case 6: Random values
        a = 16'hDEAD; b = 16'hBEEF; sel = 0;
        #10;
        if (out !== 16'hDEAD) begin
            $display("ERROR: Random values test (sel=0) failed");
        end else begin
            $display("PASS: Random values test (sel=0)");
        end
        
        sel = 1;
        #10;
        if (out !== 16'hBEEF) begin
            $display("ERROR: Random values test (sel=1) failed");
        end else begin
            $display("PASS: Random values test (sel=1)");
        end
        
        // Test Case 7: Edge case - maximum values
        a = 16'hFFFF; b = 16'h0001; sel = 1;
        #10;
        if (out !== 16'h0001) begin
            $display("ERROR: Edge case test failed");
        end else begin
            $display("PASS: Edge case test");
        end
        
        // Test Case 8: Rapid switching
        $display("\nTesting rapid sel switching:");
        a = 16'h1111; b = 16'h2222;
        sel = 0; #5;
        sel = 1; #5;
        sel = 0; #5;
        sel = 1; #5;
        
        $display("\nAll tests completed!");
        $finish;
    end
    
endmodule