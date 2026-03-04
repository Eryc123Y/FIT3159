`include "arithmetics/adder_subtractor_16bit_overflow.v"

/**
 * Comprehensive Test Suite for 16-bit Adder-Subtractor with Overflow Detection
 * 
 * This test thoroughly verifies:
 * 1. Basic addition and subtraction operations
 * 2. Signed overflow detection (2's complement arithmetic)
 * 3. Unsigned overflow detection
 * 4. Flag generation (zero, negative, carry)
 * 5. Edge cases and boundary conditions
 */
module adder_subtractor_16bit_overflow_test;
    
    // Test signals
    reg [15:0] a, b;
    reg sub;
    wire [15:0] result;
    wire carry_out, signed_overflow, unsigned_overflow;
    wire zero_flag, negative_flag;
    
    // Test statistics
    integer test_count, pass_count;
    
    // Instantiate the unit under test
    AdderSubtractor16BitOverflow alu(
        .a(a), .b(b), .sub(sub),
        .result(result), .carry_out(carry_out),
        .signed_overflow(signed_overflow), .unsigned_overflow(unsigned_overflow),
        .zero_flag(zero_flag), .negative_flag(negative_flag)
    );
    
    initial begin
        test_count = 0;
        pass_count = 0;
        
        $display("Testing 16-bit Adder-Subtractor with Overflow Detection");
        $display("==========================================================");
        
        // Test Category 1: Basic Addition
        $display("\n--- Testing Basic Addition ---");
        test_operation(16'd100, 16'd200, 1'b0, 16'd300, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, "100 + 200");
        test_operation(16'd0, 16'd0, 1'b0, 16'd0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, "0 + 0");
        test_operation(16'd1, 16'd1, 1'b0, 16'd2, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, "1 + 1");
        
        // Test Category 2: Basic Subtraction
        $display("\n--- Testing Basic Subtraction ---");
        test_operation(16'd300, 16'd100, 1'b1, 16'd200, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, "300 - 100");
        test_operation(16'd100, 16'd100, 1'b1, 16'd0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, "100 - 100");
        test_operation(16'd0, 16'd1, 1'b1, 16'd65535, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, "0 - 1 (underflow)");
        
        // Test Category 3: Unsigned Overflow
        $display("\n--- Testing Unsigned Overflow ---");
        test_operation(16'd65535, 16'd1, 1'b0, 16'd0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, "65535 + 1 (unsigned overflow)");
        test_operation(16'd32768, 16'd32768, 1'b0, 16'd0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, "32768 + 32768 (both signed and unsigned overflow)");
        
        // Test Category 4: Signed Overflow (Positive + Positive → Negative)
        $display("\n--- Testing Signed Overflow: Positive + Positive → Negative ---");
        test_operation(16'd32767, 16'd1, 1'b0, 16'd32768, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, "32767 + 1 (max positive + 1)");
        test_operation(16'd20000, 16'd20000, 1'b0, 16'd40000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, "20000 + 20000");
        
        // Test Category 5: Signed Overflow (Negative + Negative → Positive)
        $display("\n--- Testing Signed Overflow: Negative + Negative → Positive ---");
        // Using 16-bit 2's complement: -32768 = 0x8000, -1 = 0xFFFF
        test_operation(16'h8000, 16'hFFFF, 1'b0, 16'h7FFF, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, "-32768 + (-1)");
        test_operation(16'hE000, 16'hE000, 1'b0, 16'hC000, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, "-8192 + (-8192) (no signed overflow)");
        
        // Test Category 6: Signed Overflow in Subtraction
        $display("\n--- Testing Signed Overflow in Subtraction ---");
        // Positive - Negative → should be positive, but if overflow → negative
        test_operation(16'd32767, 16'hFFFF, 1'b1, 16'h8000, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, "32767 - (-1)");
        // Negative - Positive → should be negative, but if overflow → positive  
        test_operation(16'h8000, 16'd1, 1'b1, 16'h7FFF, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, "-32768 - 1");
        
        // Test Category 7: No Overflow Cases
        $display("\n--- Testing No Overflow Cases ---");
        test_operation(16'd30000, 16'd1000, 1'b0, 16'd31000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, "30000 + 1000 (no overflow)");
        test_operation(16'hF000, 16'd100, 1'b0, 16'hF064, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, "-4096 + 100 (no overflow)");
        test_operation(16'd1000, 16'd500, 1'b1, 16'd500, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, "1000 - 500 (no overflow)");
        
        // Test Category 8: Flag Testing
        $display("\n--- Testing Flag Generation ---");
        test_operation(16'h7FFF, 16'h0001, 1'b1, 16'h7FFE, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, "Zero flag test");
        test_operation(16'h0001, 16'h0001, 1'b1, 16'h0000, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, "Zero flag positive");
        
        // Test Summary
        $display("\n==========================================================");
        $display("Test Summary: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("✓ ALL TESTS PASSED!");
            $display("The 16-bit Adder-Subtractor with Overflow Detection works correctly.");
        end else begin
            $display("✗ SOME TESTS FAILED!");
            $display("Please check the implementation.");
        end
        
        // Demonstration of different number representations
        $display("\n--- Number Representation Examples ---");
        $display("16-bit Signed Range: -32768 to +32767");
        $display("16-bit Unsigned Range: 0 to 65535");
        $display("0x8000 = %0d (signed) = %0d (unsigned)", $signed(16'h8000), 16'h8000);
        $display("0x7FFF = %0d (signed) = %0d (unsigned)", $signed(16'h7FFF), 16'h7FFF);
        $display("0xFFFF = %0d (signed) = %0d (unsigned)", $signed(16'hFFFF), 16'hFFFF);
        
        $finish;
    end
    
    /**
     * Test Task: Verify operation and all flags
     */
    task test_operation;
        input [15:0] val_a, val_b;
        input val_sub;
        input [15:0] expected_result;
        input expected_carry, expected_signed_ovf, expected_unsigned_ovf;
        input expected_zero, expected_negative;
        input [200*8:1] test_name;
        
        reg test_passed;
        
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            a = val_a;
            b = val_b;
            sub = val_sub;
            
            // Wait for propagation
            #10;
            
            // Check all outputs
            test_passed = (result == expected_result) &&
                         (carry_out == expected_carry) &&
                         (signed_overflow == expected_signed_ovf) &&
                         (unsigned_overflow == expected_unsigned_ovf) &&
                         (zero_flag == expected_zero) &&
                         (negative_flag == expected_negative);
            
            if (test_passed) begin
                pass_count = pass_count + 1;
                $display("✓ PASS: %s", test_name);
                $display("   %0d %s %0d = %0d", 
                    $signed(val_a), val_sub ? "-" : "+", $signed(val_b), $signed(result));
                $display("   Flags: C=%b SO=%b UO=%b Z=%b N=%b", 
                    carry_out, signed_overflow, unsigned_overflow, zero_flag, negative_flag);
            end else begin
                $display("✗ FAIL: %s", test_name);
                $display("   Input: %0d %s %0d", $signed(val_a), val_sub ? "-" : "+", $signed(val_b));
                $display("   Expected: result=%0d, flags=C%b SO%b UO%b Z%b N%b", 
                    $signed(expected_result), expected_carry, expected_signed_ovf, 
                    expected_unsigned_ovf, expected_zero, expected_negative);
                $display("   Got:      result=%0d, flags=C%b SO%b UO%b Z%b N%b", 
                    $signed(result), carry_out, signed_overflow, 
                    unsigned_overflow, zero_flag, negative_flag);
            end
            $display("");
        end
    endtask
    
endmodule
