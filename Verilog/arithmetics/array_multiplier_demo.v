`include "arithmetics/array_multiplier_4bit.v"

module ArrayMultiplierDemo;
    reg [3:0] a, b;
    wire [7:0] product;
    
    // Instantiate the multiplier
    ArrayMultiplier4Bit mult(a, b, product);
    
    initial begin
        $display("4-Bit Array Multiplier Demonstration");
        $display("===================================");
        $display("This multiplier uses only the basic modules you built:");
        $display("- And gates for partial products");
        $display("- HalfAdder modules (using Xor and And gates)");
        $display("- FullAdder modules (using HalfAdders and Or gates)");
        $display("");
        
        $display("Example multiplications:");
        $display("a    b   | product (binary)  | product (decimal)");
        $display("--------|-------------------|------------------");
        
        // Example calculations
        a = 4'd3; b = 4'd5;
        #10;
        $display("3  × 5   | %8b        | %3d", product, product);
        
        a = 4'd7; b = 4'd9;
        #10;
        $display("7  × 9   | %8b        | %3d", product, product);
        
        a = 4'd12; b = 4'd11;
        #10;
        $display("12 × 11  | %8b        | %3d", product, product);
        
        a = 4'd15; b = 4'd15;
        #10;
        $display("15 × 15  | %8b        | %3d (maximum)", product, product);
        
        $display("");
        $display("How it works:");
        $display("1. Generate 16 partial products using And gates (a[i] AND b[j])");
        $display("2. Arrange partial products in a grid pattern");
        $display("3. Use HalfAdders and FullAdders to sum columns");
        $display("4. Propagate carries between columns");
        $display("5. Output final 8-bit result");
        
        $finish;
    end
    
endmodule
