`ifndef SRFF_V
`define SRFF_V
`include "logic-gates/others.v"
// SR Flip-Flop (Set-Reset Flip-Flop)

module SRFF (input R, clock, S, output Q, Q_bar);
  wire Rout, Sout;
  
  And and1(S, clock, Sout);  // Set input gated by clock
  And and2(R, clock, Rout);  // Reset input gated by clock
  
  // Cross-coupled NOR gates forming the SR latch
  Nor nor1(Rout, Q_bar, Q);     // Q = NOR(R, Q_bar)
  Nor nor2(Sout, Q, Q_bar);     // Q_bar = NOR(S, Q)
  
endmodule

`endif // SRFF_V