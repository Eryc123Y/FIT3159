`ifndef ARRAY_MULTIPLIER_4BIT_V
`define ARRAY_MULTIPLIER_4BIT_V

`include "arithmetics/full_adder.v"

module ArrayMultiplier4Bit(
    input [3:0] a, b,
    output [7:0] product
);
    
    // Partial products (16 bits total: a[i] AND b[j])
    wire p00, p01, p02, p03;
    wire p10, p11, p12, p13;
    wire p20, p21, p22, p23;
    wire p30, p31, p32, p33;
    
    // Generate partial products using AND gates
    And and00(a[0], b[0], p00);
    And and01(a[0], b[1], p01);
    And and02(a[0], b[2], p02);
    And and03(a[0], b[3], p03);
    
    And and10(a[1], b[0], p10);
    And and11(a[1], b[1], p11);
    And and12(a[1], b[2], p12);
    And and13(a[1], b[3], p13);
    
    And and20(a[2], b[0], p20);
    And and21(a[2], b[1], p21);
    And and22(a[2], b[2], p22);
    And and23(a[2], b[3], p23);
    
    And and30(a[3], b[0], p30);
    And and31(a[3], b[1], p31);
    And and32(a[3], b[2], p32);
    And and33(a[3], b[3], p33);
    
    // Intermediate carry and sum signals
    wire c11, c12, c13;
    wire c21, c22, c23, c24;
    wire c31, c32, c33, c34;
    
    wire s11, s12, s13;
    wire s21, s22, s23;
    wire s31, s32, s33;
    
    // First row: product[0] = p00 (direct assignment)
    assign product[0] = p00;
    
    // Second row: Add partial products for bit 1
    HalfAdder ha11(p01, p10, s11, c11);
    assign product[1] = s11;
    
    // Third row: Add partial products for bit 2
    FullAdder fa21(p02, p11, c11, s21, c21);
    HalfAdder ha22(s21, p20, s12, c12);
    assign product[2] = s12;
    
    // Fourth row: Add partial products for bit 3
    FullAdder fa31(p03, p12, c21, s31, c31);
    FullAdder fa32(s31, p21, c12, s22, c22);
    HalfAdder ha33(s22, p30, s13, c13);
    assign product[3] = s13;
    
    // Fifth row: Add partial products for bit 4
    FullAdder fa41(p13, p22, c31, s32, c32);
    FullAdder fa42(s32, p31, c22, s23, c23);
    FullAdder fa43(s23, c13, 1'b0, product[4], c24);
    
    // Sixth row: Add partial products for bit 5
    FullAdder fa51(p23, p32, c32, s33, c33);
    FullAdder fa52(s33, c23, c24, product[5], c34);
    
    // Seventh row: Add partial products for bit 6
    FullAdder fa61(p33, c33, c34, product[6], product[7]);
    
endmodule

`endif // ARRAY_MULTIPLIER_4BIT_V
