`include "multiplexors/16bitMux4way.v"
// an 8-way 16-bit multiplexer using 4-way 16-bit multiplexers

module Mux16bit8way (
    input [15:0] a,     // 16-bit input A
    input [15:0] b,     // 16-bit input B
    input [15:0] c,     // 16-bit input C
    input [15:0] d,     // 16-bit input D
    input [15:0] e,     // 16-bit input E
    input [15:0] f,     // 16-bit input F
    input [15:0] g,     // 16-bit input G
    input [15:0] h,     // 16-bit input H
    input [2:0] sel,    // 3-bit select line (000=A, 001=B, 010=C, 011=D, 100=E, 101=F, 110=G, 111=H)
    output [15:0] out   // 16-bit output
);

    wire [15:0] mux0123_out, mux4567_out;
    
    // First level: select between inputs 0-3 and 4-7
    Mux16bit4way mux0123(a, b, c, d, sel[1:0], mux0123_out);
    Mux16bit4way mux4567(e, f, g, h, sel[1:0], mux4567_out);
    
    // Second level: select between the two first level outputs
    Mux16bit mux_final(mux0123_out, mux4567_out, sel[2], out);

endmodule
