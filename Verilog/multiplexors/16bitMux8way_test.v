// Test bench for 8-way 16-bit multiplexer

`include "multiplexors/16bitMux8way.v"

module Mux16bit8way_test;
    // Test inputs
    reg [15:0] a, b, c, d, e, f, g, h;
    reg [2:0] sel;
    
    // Test outputs
    wire [15:0] out;
    
    // Instantiate the Unit Under Test (UUT)
    Mux16bit8way uut (
        .a(a), .b(b), .c(c), .d(d),
        .e(e), .f(f), .g(g), .h(h),
        .sel(sel),
        .out(out)
    );
    
    // Test procedure
    initial begin
        // Display header
        $display("Testing 8-way 16-bit Multiplexer");
        $display("Time\tsel\tout");
        $display("----\t---\t----");
        
        // Monitor changes
        $monitor("%0t\t%b\t%h", $time, sel, out);
        
        // Initialize test values with distinct patterns
        a = 16'h1111;
        b = 16'h2222;
        c = 16'h3333;
        d = 16'h4444;
        e = 16'h5555;
        f = 16'h6666;
        g = 16'h7777;
        h = 16'h8888;
        
        // Test all 8 select combinations
        sel = 3'b000; #10;
        if (out !== a) begin
            $display("ERROR: sel=000, expected %h, got %h", a, out);
        end else begin
            $display("PASS: sel=000 correctly selects input a (%h)", a);
        end
        
        sel = 3'b001; #10;
        if (out !== b) begin
            $display("ERROR: sel=001, expected %h, got %h", b, out);
        end else begin
            $display("PASS: sel=001 correctly selects input b (%h)", b);
        end
        
        sel = 3'b010; #10;
        if (out !== c) begin
            $display("ERROR: sel=010, expected %h, got %h", c, out);
        end else begin
            $display("PASS: sel=010 correctly selects input c (%h)", c);
        end
        
        sel = 3'b011; #10;
        if (out !== d) begin
            $display("ERROR: sel=011, expected %h, got %h", d, out);
        end else begin
            $display("PASS: sel=011 correctly selects input d (%h)", d);
        end
        
        sel = 3'b100; #10;
        if (out !== e) begin
            $display("ERROR: sel=100, expected %h, got %h", e, out);
        end else begin
            $display("PASS: sel=100 correctly selects input e (%h)", e);
        end
        
        sel = 3'b101; #10;
        if (out !== f) begin
            $display("ERROR: sel=101, expected %h, got %h", f, out);
        end else begin
            $display("PASS: sel=101 correctly selects input f (%h)", f);
        end
        
        sel = 3'b110; #10;
        if (out !== g) begin
            $display("ERROR: sel=110, expected %h, got %h", g, out);
        end else begin
            $display("PASS: sel=110 correctly selects input g (%h)", g);
        end
        
        sel = 3'b111; #10;
        if (out !== h) begin
            $display("ERROR: sel=111, expected %h, got %h", h, out);
        end else begin
            $display("PASS: sel=111 correctly selects input h (%h)", h);
        end
        
        // Test with different patterns
        $display("\nTesting with different bit patterns:");
        a = 16'hAAAA; b = 16'h5555; c = 16'hFFFF; d = 16'h0000;
        e = 16'hF0F0; f = 16'h0F0F; g = 16'hCCCC; h = 16'h3333;
        
        // Quick test of all inputs with new patterns
        sel = 3'b000; #10;
        if (out !== 16'hAAAA) $display("ERROR: Pattern test failed for input a");
        else $display("PASS: Pattern test for input a");
        
        sel = 3'b001; #10;
        if (out !== 16'h5555) $display("ERROR: Pattern test failed for input b");
        else $display("PASS: Pattern test for input b");
        
        sel = 3'b010; #10;
        if (out !== 16'hFFFF) $display("ERROR: Pattern test failed for input c");
        else $display("PASS: Pattern test for input c");
        
        sel = 3'b011; #10;
        if (out !== 16'h0000) $display("ERROR: Pattern test failed for input d");
        else $display("PASS: Pattern test for input d");
        
        sel = 3'b100; #10;
        if (out !== 16'hF0F0) $display("ERROR: Pattern test failed for input e");
        else $display("PASS: Pattern test for input e");
        
        sel = 3'b101; #10;
        if (out !== 16'h0F0F) $display("ERROR: Pattern test failed for input f");
        else $display("PASS: Pattern test for input f");
        
        sel = 3'b110; #10;
        if (out !== 16'hCCCC) $display("ERROR: Pattern test failed for input g");
        else $display("PASS: Pattern test for input g");
        
        sel = 3'b111; #10;
        if (out !== 16'h3333) $display("ERROR: Pattern test failed for input h");
        else $display("PASS: Pattern test for input h");
        
        // Test rapid switching through all inputs
        $display("\nTesting rapid switching through all 8 inputs:");
        a = 16'h0001; b = 16'h0002; c = 16'h0004; d = 16'h0008;
        e = 16'h0010; f = 16'h0020; g = 16'h0040; h = 16'h0080;
        
        sel = 3'b000; #5;
        sel = 3'b001; #5;
        sel = 3'b010; #5;
        sel = 3'b011; #5;
        sel = 3'b100; #5;
        sel = 3'b101; #5;
        sel = 3'b110; #5;
        sel = 3'b111; #5;
        
        $display("\nAll 8-way multiplexer tests completed!");
        $finish;
    end
    
endmodule
