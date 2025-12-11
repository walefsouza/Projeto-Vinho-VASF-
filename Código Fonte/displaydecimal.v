
// ====================================================================
// DECODIFICADOR BCD → DISPLAY DE 7 SEGMENTOS (DECIMAL)
// ====================================================================

module DECA(DA, A, B, C, D);
    input A, B, C, D;
    output DA;
    
    wire nota, notb, notc, notd;
    wire and0, and1;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DA = ~A ~B ~C D + B ~C ~D
    and And0(and0, nota, notb, notc, D);
    and And1(and1, B, notc, notd);
    
    or OrFinalDA(DA, and0, and1);
endmodule


module DECB(DB, A, B, C, D);
    input A, B, C, D;
    output DB;
    
    wire nota, notb, notc, notd;
    wire and0, and1;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DB = B ~C D + B C ~D
    and And0(and0, B, notc, D);
    and And1(and1, B, C, notd);
    
    or OrFinalDB(DB, and0, and1);
endmodule


module DECC(DC, A, B, C, D);
    input A, B, C, D;
    output DC;
    
    wire nota, notb, notc, notd;
    wire and0;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DC = ~B C ~D
    and And0(and0, notb, C, notd);
    
    or OrFinalDC(DC, and0, 1'b0);
endmodule


module DECD(DD, A, B, C, D);
    input A, B, C, D;
    output DD;
    
    wire nota, notb, notc, notd;
    wire and0, and1, and2;
    wire or0;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DD = ~A ~B ~C D + B ~C ~D + B C D
    and And0(and0, nota, notb, notc, D);
    and And1(and1, B, notc, notd);
    and And2(and2, B, C, D);
    
    or Or0(or0, and0, and1);
    or OrFinalDD(DD, or0, and2);
endmodule


module DECE(DE, A, B, C, D);
    input A, B, C, D;
    output DE;
    
    wire nota, notb, notc, notd;
    wire and0, and1;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DE = D + B ~C
    and And0(and0, B, notc);
    
    or OrFinalDE(DE, D, and0);
endmodule


module DECF(DF, A, B, C, D);
    input A, B, C, D;
    output DF;
    
    wire nota, notb, notc, notd;
    wire and0, and1, and2;
    wire or0;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DF = ~A ~B D + ~B C + C D
    and And0(and0, nota, notb, D);
    and And1(and1, notb, C);
    and And2(and2, C, D);
    
    or Or0(or0, and0, and1);
    or OrFinalDF(DF, or0, and2);
endmodule


module DECG(DG, A, B, C, D);
    input A, B, C, D;
    output DG;
    
    wire nota, notb, notc, notd;
    wire and0, and1;
    
    not NotA(nota, A);
    not NotB(notb, B);
    not NotC(notc, C);
    not NotD(notd, D);
    
    // DG = ~A ~B ~C + B C D
    and And0(and0, nota, notb, notc);
    and And1(and1, B, C, D);
    
    or OrFinalDG(DG, and0, and1);
endmodule


// ====================================================================
// MÓDULO PRINCIPAL: displayDEC (Display Decimal)
// ====================================================================

module displaydecimal (DECSEG, A, B, C, D);

    input A, B, C, D;
    output [6:0] DECSEG;

    DECA SegA (DECSEG[0], A, B, C, D);
    DECB SegB (DECSEG[1], A, B, C, D);
    DECC SegC (DECSEG[2], A, B, C, D);
    DECD SegD (DECSEG[3], A, B, C, D);
    DECE SegE (DECSEG[4], A, B, C, D);
    DECF SegF (DECSEG[5], A, B, C, D);
    DECG SegG (DECSEG[6], A, B, C, D);

endmodule