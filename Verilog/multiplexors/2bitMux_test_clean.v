// Clean test bench for 2-bit multiplexer that uses proper include management

`include "multiplexors/2bitMux.v"

// Test bench
module Mux_test_clean;
    // Inputs
    reg a, b, sel;
    
    // Output
    wire out;
    
    // Instantiate the Unit Under Test (UUT)
    Mux uut (
        .a(a),
        .b(b),
        .sel(sel),
        .out(out)
    );
    
    // Test vectors: {a, b, sel, expected_out}
    reg [3:0] test_vectors [0:7];
    integer i;
    
    initial begin
        // Initialize test vectors
        test_vectors[0] = 4'b0000; // a=0, b=0, sel=0, expected=0
        test_vectors[1] = 4'b0010; // a=0, b=0, sel=1, expected=0  
        test_vectors[2] = 4'b0100; // a=0, b=1, sel=0, expected=0
        test_vectors[3] = 4'b0111; // a=0, b=1, sel=1, expected=1
        test_vectors[4] = 4'b1001; // a=1, b=0, sel=0, expected=1
        test_vectors[5] = 4'b1010; // a=1, b=0, sel=1, expected=0
        test_vectors[6] = 4'b1101; // a=1, b=1, sel=0, expected=1
        test_vectors[7] = 4'b1111; // a=1, b=1, sel=1, expected=1
        
        // Display header
        $display("Test\ta\tb\tsel\tout\tExp\tResult");
        $display("----\t-\t-\t---\t---\t---\t------");
        
        // Run all test cases
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, sel} = test_vectors[i][3:1];
            #5; // Small delay for propagation
            
            $display("%0d\t%b\t%b\t%b\t%b\t%b\t%s", 
                     i, a, b, sel, out, test_vectors[i][0],
                     (out == test_vectors[i][0]) ? "PASS" : "FAIL");
            #5;
        end
        
        $display("\nMux functionality test completed!");
        $display("Truth table verification:");
        $display("sel=0: out = a (select input a)");
        $display("sel=1: out = b (select input b)");
        
        $finish;
    end
    
endmodule
