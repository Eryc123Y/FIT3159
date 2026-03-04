// Test bench for 4-way 16-bit multiplexer

`include "multiplexors/16bitMux4way.v"

module Mux16bit4way_test;
    // Test inputs
    reg [15:0] a, b, c, d;
    reg [1:0] sel;
    
    // Test outputs
    wire [15:0] out;
    
    // Instantiate the Unit Under Test (UUT)
    Mux16bit4way uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .out(out)
    );
    
    // Test procedure
    initial begin
        // Display header
        $display("Testing 4-way 16-bit Multiplexer");
        $display("Time\ta\tb\tc\td\tsel\tout\tExpected");
        $display("----\t----\t----\t----\t----\t---\t----\t--------");
        
        // Monitor changes
        $monitor("%0t\t%h\t%h\t%h\t%h\t%b\t%h", $time, a, b, c, d, sel, out);
        
        // Initialize test values
        a = 16'h1111;
        b = 16'h2222;
        c = 16'h3333;
        d = 16'h4444;
        
        // Test Case 1: sel = 00 (should select input a)
        sel = 2'b00;
        #10;
        if (out !== a) begin
            $display("ERROR: sel=00, expected %h, got %h", a, out);
        end else begin
            $display("PASS: sel=00 correctly selects input a (%h)", a);
        end
        
        // Test Case 2: sel = 01 (should select input b)
        sel = 2'b01;
        #10;
        if (out !== b) begin
            $display("ERROR: sel=01, expected %h, got %h", b, out);
        end else begin
            $display("PASS: sel=01 correctly selects input b (%h)", b);
        end
        
        // Test Case 3: sel = 10 (should select input c)
        sel = 2'b10;
        #10;
        if (out !== c) begin
            $display("ERROR: sel=10, expected %h, got %h", c, out);
        end else begin
            $display("PASS: sel=10 correctly selects input c (%h)", c);
        end
        
        // Test Case 4: sel = 11 (should select input d)
        sel = 2'b11;
        #10;
        if (out !== d) begin
            $display("ERROR: sel=11, expected %h, got %h", d, out);
        end else begin
            $display("PASS: sel=11 correctly selects input d (%h)", d);
        end
        
        // Test Case 5: Different values
        a = 16'hAAAA; b = 16'hBBBB; c = 16'hCCCC; d = 16'hDDDD;
        
        sel = 2'b00; #10;
        if (out !== 16'hAAAA) begin
            $display("ERROR: Different values test (sel=00) failed");
        end else begin
            $display("PASS: Different values test (sel=00)");
        end
        
        sel = 2'b01; #10;
        if (out !== 16'hBBBB) begin
            $display("ERROR: Different values test (sel=01) failed");
        end else begin
            $display("PASS: Different values test (sel=01)");
        end
        
        sel = 2'b10; #10;
        if (out !== 16'hCCCC) begin
            $display("ERROR: Different values test (sel=10) failed");
        end else begin
            $display("PASS: Different values test (sel=10)");
        end
        
        sel = 2'b11; #10;
        if (out !== 16'hDDDD) begin
            $display("ERROR: Different values test (sel=11) failed");
        end else begin
            $display("PASS: Different values test (sel=11)");
        end
        
        // Test Case 6: Edge cases
        a = 16'h0000; b = 16'hFFFF; c = 16'h5555; d = 16'hAAAA;
        
        sel = 2'b00; #10;
        if (out !== 16'h0000) begin
            $display("ERROR: Edge case test (sel=00) failed");
        end else begin
            $display("PASS: Edge case test (sel=00) - all zeros");
        end
        
        sel = 2'b01; #10;
        if (out !== 16'hFFFF) begin
            $display("ERROR: Edge case test (sel=01) failed");
        end else begin
            $display("PASS: Edge case test (sel=01) - all ones");
        end
        
        // Test Case 7: Rapid switching
        $display("\nTesting rapid sel switching:");
        a = 16'hFACE; b = 16'hBEEF; c = 16'hDEAD; d = 16'hCAFE;
        sel = 2'b00; #5;
        sel = 2'b01; #5;
        sel = 2'b10; #5;
        sel = 2'b11; #5;
        sel = 2'b00; #5;
        
        $display("\nAll 4-way multiplexer tests completed!");
        $finish;
    end
    
endmodule
