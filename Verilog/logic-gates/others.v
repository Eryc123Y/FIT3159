`ifndef OTHERS_V
`define OTHERS_V

`include "logic-gates/nand.v"

module And(input a, b, output out);
    wire nand_out;
    Nand nand1(a, b, nand_out);
    Nand nand2(nand_out, nand_out, out);
endmodule
    
module Or(input a, b, output out);
    wire nand_out1, nand_out2;
    Nand nand1(a, a, nand_out1);
    Nand nand2(b, b, nand_out2);
    Nand nand3(nand_out1, nand_out2, out);
endmodule

module Not(input a, output out);
    Nand nand1(a, a, out);
endmodule

module Nor(input a, b, output out);
    wire or_out;
    Or or1(a, b, or_out);
    Not not1(or_out, out);
endmodule

module Xor(input a, b, output out);
    wire not_a, not_b, and1_out, and2_out;
    Not not1(a, not_a);
    Not not2(b, not_b);
    And and1(a, not_b, and1_out);
    And and2(not_a, b, and2_out);
    Or or1(and1_out, and2_out, out);
endmodule

`endif // OTHERS_V