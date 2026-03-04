`include "arithmetics/array_multiplier_4bit.v"

module ArrayMultiplier4BitTest;
    reg [3:0] a, b;
    wire [7:0] product;
    integer i, j;
    
    // Instantiate the multiplier
    ArrayMultiplier4Bit mult(a, b, product);
    
    initial begin
        $display("4-Bit Array Multiplier Test");
        $display("==========================");
        $display("a  * b  = product (hex) | product (dec) | expected");
        $display("-----------------------------------------------");
        
        // Test all combinations (16x16 = 256 tests)
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                #10; // Wait for propagation
                
                // Check if result matches expected value
                if (product == (i * j)) begin
                    if ((i * j) < 20) // Only display first 20 results to avoid clutter
                        $display("%2d * %2d = %8b (%3d) | %3d | PASS", i, j, product, product, i*j);
                end else begin
                    $display("%2d * %2d = %8b (%3d) | %3d | FAIL", i, j, product, product, i*j);
                end
            end
        end
        
        // Test some specific edge cases
        $display("\nEdge Case Tests:");
        $display("================");
        
        // Test maximum values
        a = 4'b1111; b = 4'b1111; // 15 * 15 = 225
        #10;
        $display("15 * 15 = %8b (%3d) | Expected: 225 | %s", 
                 product, product, (product == 225) ? "PASS" : "FAIL");
        
        // Test zero
        a = 4'b0000; b = 4'b1111; // 0 * 15 = 0
        #10;
        $display("0  * 15 = %8b (%3d) | Expected: 0   | %s", 
                 product, product, (product == 0) ? "PASS" : "FAIL");
        
        // Test one
        a = 4'b0001; b = 4'b1111; // 1 * 15 = 15
        #10;
        $display("1  * 15 = %8b (%3d) | Expected: 15  | %s", 
                 product, product, (product == 15) ? "PASS" : "FAIL");
        
        // Test powers of 2
        a = 4'b1000; b = 4'b1000; // 8 * 8 = 64
        #10;
        $display("8  * 8  = %8b (%3d) | Expected: 64  | %s", 
                 product, product, (product == 64) ? "PASS" : "FAIL");
        
        $display("\nTest completed!");
        $finish;
    end
    
endmodule
