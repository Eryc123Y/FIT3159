`ifndef HALF_ADDER_V
`define HALF_ADDER_V

`include "logic-gates/others.v"

module HalfAdder(input a, b, output sum, carry);
    // Instantiate XOR and AND gates
    Xor xor_gate(a, b, sum);
    And and_gate(a, b, carry);
endmodule

`endif // HALF_ADDER_V