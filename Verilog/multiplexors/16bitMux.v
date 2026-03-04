`ifndef MUX_16BIT_V
`define MUX_16BIT_V
`include "multiplexors/2bitMux.v"
// a 16-bit multiplexer using 2-bit multiplexers

module Mux16bit (
    input [15:0] a,     // 16-bit input A
    input [15:0] b,     // 16-bit input B
    input sel,          // Select line (0 = select A, 1 = select B)
    output [15:0] out   // 16-bit output
);

    // Instantiate 16 2-bit multiplexers
    Mux mux00(a[0], b[0], sel, out[0]);
    Mux mux01(a[1], b[1], sel, out[1]);
    Mux mux02(a[2], b[2], sel, out[2]);
    Mux mux03(a[3], b[3], sel, out[3]);
    Mux mux04(a[4], b[4], sel, out[4]);
    Mux mux05(a[5], b[5], sel, out[5]);
    Mux mux06(a[6], b[6], sel, out[6]);
    Mux mux07(a[7], b[7], sel, out[7]);
    Mux mux08(a[8], b[8], sel, out[8]);
    Mux mux09(a[9], b[9], sel, out[9]);
    Mux mux10(a[10], b[10], sel, out[10]);
    Mux mux11(a[11], b[11], sel, out[11]);
    Mux mux12(a[12], b[12], sel, out[12]);
    Mux mux13(a[13], b[13], sel, out[13]);
    Mux mux14(a[14], b[14], sel, out[14]);
    Mux mux15(a[15], b[15], sel, out[15]);

endmodule

`endif // MUX_16BIT_V
