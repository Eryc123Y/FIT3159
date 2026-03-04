`include "arithmetics/ripple_carry_adder_16bit.v"

module ripple_carry_adder_16bit_test;
    reg [15:0] a, b;
    reg cin;
    wire [15:0] sum;
    wire cout;
    reg [16:0] expected;
    integer test_count, pass_count;
    
    // Instantiate the 16-bit adder
    RippleCarryAdder16Bit rca16(a, b, cin, sum, cout);
    
    initial begin
        test_count = 0;
        pass_count = 0;
        
        $display("Testing 16-bit Ripple Carry Adder");
        $display("===================================");
        
        // Test 1: Basic addition without carry
        test_addition(16'h0000, 16'h0000, 1'b0, "Zero + Zero");
        test_addition(16'h0001, 16'h0001, 1'b0, "1 + 1");
        test_addition(16'h00FF, 16'h0001, 1'b0, "255 + 1");
        
        // Test 2: Addition with carry propagation
        test_addition(16'hFFFF, 16'h0001, 1'b0, "FFFF + 1 (max + 1)");
        test_addition(16'h8000, 16'h8000, 1'b0, "8000 + 8000");
        test_addition(16'h7FFF, 16'h0001, 1'b0, "7FFF + 1");
        
        // Test 3: Addition with carry input
        test_addition(16'h0000, 16'h0000, 1'b1, "0 + 0 + carry");
        test_addition(16'hFFFF, 16'h0000, 1'b1, "FFFF + 0 + carry");
        test_addition(16'hFFFF, 16'hFFFF, 1'b1, "FFFF + FFFF + carry");
        
        // Test 4: Random large numbers
        test_addition(16'h1234, 16'h5678, 1'b0, "1234 + 5678");
        test_addition(16'hABCD, 16'h1234, 1'b0, "ABCD + 1234");
        test_addition(16'hDEAD, 16'hBEEF, 1'b0, "DEAD + BEEF");
        
        // Test 5: Powers of 2
        test_addition(16'h0001, 16'h0001, 1'b0, "2^0 + 2^0");
        test_addition(16'h0100, 16'h0100, 1'b0, "2^8 + 2^8");
        test_addition(16'h4000, 16'h4000, 1'b0, "2^14 + 2^14");
        
        // Summary
        $display("\n===================================");
        $display("Test Summary: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("✓ All tests PASSED!");
        else
            $display("✗ Some tests FAILED!");
        
        // Demonstrate overflow behavior
        $display("\nOverflow Examples:");
        $display("Note: 16-bit adder can only represent 0-65535");
        
        a = 16'h8000; b = 16'h8000; cin = 1'b0; #10;
        $display("32768 + 32768 = %0d (actual: %0d, carry: %b)", 
                 32768 + 32768, {cout, sum}, cout);
        
        a = 16'hFFFF; b = 16'hFFFF; cin = 1'b0; #10;
        $display("65535 + 65535 = %0d (actual: %0d, carry: %b)", 
                 65535 + 65535, {cout, sum}, cout);
        
        $finish;
    end
    
    // Task to test addition and verify results
    task test_addition;
        input [15:0] val_a, val_b;
        input val_cin;
        input [200*8:1] test_name; // String description
        begin
            test_count = test_count + 1;
            a = val_a;
            b = val_b;
            cin = val_cin;
            
            // Calculate expected result
            expected = val_a + val_b + val_cin;
            
            #10; // Wait for propagation
            
            // Check if result matches expected
            if ({cout, sum} == expected) begin
                pass_count = pass_count + 1;
                $display("✓ PASS: %s", test_name);
                $display("   %d + %d + %d = %d (hex: %04X + %04X + %X = %05X)", 
                         val_a, val_b, val_cin, expected, val_a, val_b, val_cin, expected);
            end else begin
                $display("✗ FAIL: %s", test_name);
                $display("   Expected: %d (hex: %05X)", expected, expected);
                $display("   Got:      %d (hex: %05X)", {cout, sum}, {cout, sum});
                $display("   Inputs:   %d + %d + %d", val_a, val_b, val_cin);
            end
            $display("");
        end
    endtask
    
endmodule