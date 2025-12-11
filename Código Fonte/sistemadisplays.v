// ====================================================================
// SISTEMA COMPLETO DE DISPLAYS
// ====================================================================

module sistemadisplays (
    // Saídas para os 6 displays
    output [6:0] HEX0,    // Unidades de rolhas
    output [6:0] HEX1,    // Dezenas de rolhas
    output [6:0] HEX2,    // Unidades de dúzias
    output [6:0] HEX3,    // Dezenas de dúzias
    output [6:0] HEX4,    // Unidades de garrafas
    output [6:0] HEX5,    // Dezenas de garrafas
    
    // Entradas: valores binários dos contadores
    input [3:0] COUNT_GARRAFAS,   // 0-12
    input [3:0] COUNT_DUZIAS,     // 0-10
    input [6:0] COUNT_ROLHAS      // 0-99
);

    // ========================================
    // SINAIS INTERMEDIÁRIOS BCD
    // ========================================
    
    wire [3:0] DezenaGA, UnidadeGA;
    wire [3:0] DezenaDUZ, UnidadeDUZ;
    wire [3:0] DezenaROL, UnidadeROL;
    
    // ========================================
    // CONVERSORES BINÁRIO → BCD
    // ========================================
    
    doubledabble7bits BCDGARRAFAS (
        .Dezenas(DezenaGA),
        .Unidades(UnidadeGA),
        .Binario({3'b000, COUNT_GARRAFAS})
    );
    
    doubledabble7bits BCDDUZIAS (
        .Dezenas(DezenaDUZ),
        .Unidades(UnidadeDUZ),
        .Binario({3'b000, COUNT_DUZIAS})
    );
    
    doubledabble7bits BCDROLHAS (
        .Dezenas(DezenaROL),
        .Unidades(UnidadeROL),
        .Binario(COUNT_ROLHAS)
    );
    
    // ========================================
    // DECODIFICADORES BCD → 7 SEGMENTOS
    // ========================================
    
    // Garrafas
    displaydecimal UNIGA (
        .DECSEG(HEX4),
        .A(UnidadeGA[3]),
        .B(UnidadeGA[2]),
        .C(UnidadeGA[1]),
        .D(UnidadeGA[0])
    );
    
    displaydecimal DECGA (
        .DECSEG(HEX5),
        .A(DezenaGA[3]),
        .B(DezenaGA[2]),
        .C(DezenaGA[1]),
        .D(DezenaGA[0])
    );
    
    // Dúzias
    displaydecimal UNIDU (
        .DECSEG(HEX2),
        .A(UnidadeDUZ[3]),
        .B(UnidadeDUZ[2]),
        .C(UnidadeDUZ[1]),
        .D(UnidadeDUZ[0])
    );
    
    displaydecimal DECDU (
        .DECSEG(HEX3),
        .A(DezenaDUZ[3]),
        .B(DezenaDUZ[2]),
        .C(DezenaDUZ[1]),
        .D(DezenaDUZ[0])
    );
    
    // Rolhas
    displaydecimal UNIRO (
        .DECSEG(HEX0),
        .A(UnidadeROL[3]),
        .B(UnidadeROL[2]),
        .C(UnidadeROL[1]),
        .D(UnidadeROL[0])
    );
    
    displaydecimal DECRO (
        .DECSEG(HEX1),
        .A(DezenaROL[3]),
        .B(DezenaROL[2]),
        .C(DezenaROL[1]),
        .D(DezenaROL[0])
    );

endmodule