`ifndef FULL_ADDER_V
`define FULL_ADDER_V

`include "arithmetics/half_adder.v"

module FullAdder(input a, b, cin, output sum, cout);
    wire sum1, carry1, carry2;
    HalfAdder ha1(a, b, sum1, carry1);
    HalfAdder ha2(sum1, cin, sum, carry2);
    Or or_gate(carry1, carry2, cout);
endmodule

`endif // FULL_ADDER_V