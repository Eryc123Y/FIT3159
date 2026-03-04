`include "multiplexors/16bitMux.v"
// a 4-way 16-bit multiplexer using 2-way 16-bit multiplexers

module Mux16bit4way (
    input [15:0] a,     // 16-bit input A
    input [15:0] b,     // 16-bit input B
    input [15:0] c,     // 16-bit input C
    input [15:0] d,     // 16-bit input D
    input [1:0] sel,    // 2-bit select line (00=A, 01=B, 10=C, 11=D)
    output [15:0] out   // 16-bit output
);

    wire [15:0] mux01_out, mux23_out;
    
    // First level: select between a,b and c,d
    Mux16bit mux01(a, b, sel[0], mux01_out);
    Mux16bit mux23(c, d, sel[0], mux23_out);
    
    // Second level: select between the two first level outputs
    Mux16bit mux_final(mux01_out, mux23_out, sel[1], out);

endmodule
