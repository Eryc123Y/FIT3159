`include "logic-gates/others.v"


module gates_test;
    reg a, b;
    wire nand_out, and_out, or_out, not_out, nor_out, xor_out;
    integer i;
    
    // Instantiate all modules
    Nand nand_gate(a, b, nand_out);
    And and_gate(a, b, and_out);
    Or or_gate(a, b, or_out);
    Not not_gate(a, not_out);
    Nor nor_gate(a, b, nor_out);
    Xor xor_gate(a, b, xor_out);
    
    initial begin
        // Display header
        $display("Testing all logic gates");
        $display("a b | NAND AND OR  NOT NOR XOR");
        $display("----+---------------------");
        
        // Iterate through all test cases (00, 01, 10, 11)
        for (i = 0; i < 4; i = i + 1) begin
            // Set inputs based on bits of i
            a = (i >> 1) & 1;
            b = i & 1;
            
            // Wait for propagation
            #10;
            
            // Display results
            $display("%b %b |  %b    %b   %b   %b   %b   %b", a, b, 
                     nand_out, and_out, or_out, not_out, nor_out, xor_out);
        end
        
        // Exit simulation when done
        $finish;
    end
endmodule