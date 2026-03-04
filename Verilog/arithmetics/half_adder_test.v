`include "arithmetics/half_adder.v"

module half_adder_test;
    reg a, b;
    wire sum, carry;
    integer i;
    
    // Instantiate the half adder
    HalfAdder ha(a, b, sum, carry);
    
    initial begin
        // Display header
        $display("Testing Half Adder");
        $display("a b | sum carry");
        $display("----+---------");
        
        // Test all input combinations (00, 01, 10, 11)
        for (i = 0; i < 4; i = i + 1) begin
            // Set inputs based on bits of i
            a = (i >> 1) & 1;
            b = i & 1;
            
            // Wait for propagation
            #10;
            
            // Display results
            $display("%b %b |  %b    %b", a, b, sum, carry);
        end
        
        $display("\nExpected behavior:");
        $display("0+0 = 0 (sum=0, carry=0)");
        $display("0+1 = 1 (sum=1, carry=0)");
        $display("1+0 = 1 (sum=1, carry=0)"); 
        $display("1+1 = 10 (sum=0, carry=1)");
        
        $finish;
    end
endmodule