`ifndef RIPPLE_CARRY_ADDER_16BIT_V
`define RIPPLE_CARRY_ADDER_16BIT_V

`include "arithmetics/full_adder.v"

module RippleCarryAdder16Bit(
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire [14:0] carry; // Internal carry signals between full adders
    
    // Bit 0 (LSB)
    FullAdder fa0(a[0], b[0], cin, sum[0], carry[0]);
    
    // Bits 1-14
    FullAdder fa1(a[1], b[1], carry[0], sum[1], carry[1]);
    FullAdder fa2(a[2], b[2], carry[1], sum[2], carry[2]);
    FullAdder fa3(a[3], b[3], carry[2], sum[3], carry[3]);
    FullAdder fa4(a[4], b[4], carry[3], sum[4], carry[4]);
    FullAdder fa5(a[5], b[5], carry[4], sum[5], carry[5]);
    FullAdder fa6(a[6], b[6], carry[5], sum[6], carry[6]);
    FullAdder fa7(a[7], b[7], carry[6], sum[7], carry[7]);
    FullAdder fa8(a[8], b[8], carry[7], sum[8], carry[8]);
    FullAdder fa9(a[9], b[9], carry[8], sum[9], carry[9]);
    FullAdder fa10(a[10], b[10], carry[9], sum[10], carry[10]);
    FullAdder fa11(a[11], b[11], carry[10], sum[11], carry[11]);
    FullAdder fa12(a[12], b[12], carry[11], sum[12], carry[12]);
    FullAdder fa13(a[13], b[13], carry[12], sum[13], carry[13]);
    FullAdder fa14(a[14], b[14], carry[13], sum[14], carry[14]);
    
    // Bit 15 (MSB)
    FullAdder fa15(a[15], b[15], carry[14], sum[15], cout);
    
endmodule

`endif // RIPPLE_CARRY_ADDER_16BIT_V