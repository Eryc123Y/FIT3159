module NOT(input a, output out);
    pmos p1(out, 1, a);    
    nmos n1(out, 0, a);    
endmodule


module NAND(input a, b, output out);
    pmos p1(out, 1, a);    
    pmos p2(out, 1, b);
    
    nmos n1(o1, 0, b);     
    nmos n2(out, o1, a);
endmodule


module NOR(input a, b, output out);
    pmos p1(o1, 1, a);     
    pmos p2(out, o1, b);
    
    nmos n1(out, 0, a);    
    nmos n2(out, 0, b);
endmodule

module AND(input a, b, output out);
    wire nand_out;
    
    // NAND
    pmos p1(nand_out, 1, a);
    pmos p2(nand_out, 1, b);
    nmos n1(o1, 0, b);
    nmos n2(nand_out, o1, a);
    
    // NOT
    pmos p3(out, 1, nand_out);
    nmos n3(out, 0, nand_out);
endmodule


module OR(input a, b, output out);
    wire nor_out;
    
    // NOR
    pmos p1(o1, 1, a);
    pmos p2(nor_out, o1, b);
    nmos n1(nor_out, 0, a);
    nmos n2(nor_out, 0, b);
    
    // NOT
    pmos p3(out, 1, nor_out);
    nmos n3(out, 0, nor_out);
endmodule

module XOR(input a, b, output out);
    wire a_not, b_not, w1, w2;
    
    // NOT a
    pmos p1(a_not, 1, a);
    nmos n1(a_not, 0, a);
    
    // NOT b
    pmos p2(b_not, 1, b);
    nmos n2(b_not, 0, b);
    
    // a·b'
    pmos p3(w1, 1, a_not);
    pmos p4(w1, 1, b);
    nmos n3(t1, 0, b);
    nmos n4(w1, t1, a_not);
    
    // a'·b
    pmos p5(w2, 1, a);
    pmos p6(w2, 1, b_not);
    nmos n5(t2, 0, b_not);
    nmos n6(w2, t2, a);
    
    // OR
    pmos p7(o1, 1, w1);
    pmos p8(out, o1, w2);
    nmos n7(out, 0, w1);
    nmos n8(out, 0, w2);
endmodule

