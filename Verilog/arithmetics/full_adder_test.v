`include "arithmetics/full_adder.v"

module full_adder_test;
    reg a, b, cin;
    wire sum, cout;
    integer i;
    
    // Instantiate the full adder
    FullAdder fa(a, b, cin, sum, cout);
    
    initial begin
        // Display header
        $display("Testing Full Adder");
        $display("a b cin | sum cout | decimal");
        $display("--------+----------+--------");
        
        // Test all input combinations (000 to 111)
        for (i = 0; i < 8; i = i + 1) begin
            // Set inputs based on bits of i
            a = (i >> 2) & 1;
            b = (i >> 1) & 1;
            cin = i & 1;
            
            // Wait for propagation
            #10;
            
            // Display results with decimal equivalent
            $display("%b %b  %b  |  %b    %b   | %0d+%0d+%0d=%0d", 
                     a, b, cin, sum, cout, a, b, cin, {cout, sum});
        end
        
        $display("\nExpected behavior:");
        $display("Full Adder computes: sum = a ⊕ b ⊕ cin, cout = ab + cin(a ⊕ b)");
        $display("Output {cout,sum} represents the 2-bit binary result");
        
        // Additional verification with specific test cases
        $display("\nKey test cases:");
        
        // Test case: 0+0+0 = 0
        a = 0; b = 0; cin = 0; #10;
        $display("0+0+0 = %0d (expected 0) - %s", {cout, sum}, 
                 ({cout, sum} == 0) ? "PASS" : "FAIL");
        
        // Test case: 1+1+1 = 3
        a = 1; b = 1; cin = 1; #10;
        $display("1+1+1 = %0d (expected 3) - %s", {cout, sum}, 
                 ({cout, sum} == 3) ? "PASS" : "FAIL");
        
        // Test case: 1+0+1 = 2
        a = 1; b = 0; cin = 1; #10;
        $display("1+0+1 = %0d (expected 2) - %s", {cout, sum}, 
                 ({cout, sum} == 2) ? "PASS" : "FAIL");
        
        $finish;
    end
endmodule
