// ====================================================================
// SISTEMA COMPLETO DE DISPLAYS
// Converte 3 valores binários para 6 displays de 7 segmentos
// - Garrafas (4 bits, 0-12) → HEX1-HEX0
// - Dúzias (4 bits, 0-10) → HEX3-HEX2
// - Rolhas (7 bits, 0-99) → HEX5-HEX4
// ====================================================================

module sistemadisplays (
    // Saídas para os 6 displays
    output [6:0] HEX0,    // Unidades de garrafas
    output [6:0] HEX1,    // Dezenas de garrafas
    output [6:0] HEX2,    // Unidades de dúzias
    output [6:0] HEX3,    // Dezenas de dúzias
    output [6:0] HEX4,    // Unidades de rolhas
    output [6:0] HEX5,    // Dezenas de rolhas
    
    // Entradas: valores binários dos contadores
    input [3:0] count_garrafas,   // 0-12
    input [3:0] count_duzias,     // 0-10
    input [6:0] count_rolhas      // 0-99
);

    // ========================================
    // SINAIS INTERMEDIÁRIOS BCD
    // ========================================
    
    wire [3:0] garrafas_dez_bcd, garrafas_unid_bcd;
    wire [3:0] duzias_dez_bcd, duzias_unid_bcd;
    wire [3:0] rolhas_dez_bcd, rolhas_unid_bcd;
    
    // ========================================
    // EXPANSÃO DE 4 BITS PARA 7 BITS
    // ========================================
    
    wire [6:0] garrafas_expandido;
    wire [6:0] duzias_expandido;
    wire GND;
    
    or OrGND(GND, 1'b0, 1'b0);
    
    // Garrafas: {000, count_garrafas[3:0]}
    or OrGarr0(garrafas_expandido[0], count_garrafas[0], GND);
    or OrGarr1(garrafas_expandido[1], count_garrafas[1], GND);
    or OrGarr2(garrafas_expandido[2], count_garrafas[2], GND);
    or OrGarr3(garrafas_expandido[3], count_garrafas[3], GND);
    or OrGarr4(garrafas_expandido[4], GND, GND);
    or OrGarr5(garrafas_expandido[5], GND, GND);
    or OrGarr6(garrafas_expandido[6], GND, GND);
    
    // Dúzias: {000, count_duzias[3:0]}
    or OrDuz0(duzias_expandido[0], count_duzias[0], GND);
    or OrDuz1(duzias_expandido[1], count_duzias[1], GND);
    or OrDuz2(duzias_expandido[2], count_duzias[2], GND);
    or OrDuz3(duzias_expandido[3], count_duzias[3], GND);
    or OrDuz4(duzias_expandido[4], GND, GND);
    or OrDuz5(duzias_expandido[5], GND, GND);
    or OrDuz6(duzias_expandido[6], GND, GND);
    
    // ========================================
    // CONVERSORES BINÁRIO → BCD
    // ========================================
    
    doubledabble7bits bcd_garrafas (
        .Dezenas(garrafas_dez_bcd),
        .Unidades(garrafas_unid_bcd),
        .Binario(garrafas_expandido)
    );
    
    doubledabble7bits bcd_duzias (
        .Dezenas(duzias_dez_bcd),
        .Unidades(duzias_unid_bcd),
        .Binario(duzias_expandido)
    );
    
    doubledabble7bits bcd_rolhas (
        .Dezenas(rolhas_dez_bcd),
        .Unidades(rolhas_unid_bcd),
        .Binario(count_rolhas)
    );
    
    // ========================================
    // DECODIFICADORES BCD → 7 SEGMENTOS
    // ========================================
    
    // Garrafas
    displaydecimal dec_garrafas_unid (
        .DECSEG(HEX0),
        .A(garrafas_unid_bcd[3]),
        .B(garrafas_unid_bcd[2]),
        .C(garrafas_unid_bcd[1]),
        .D(garrafas_unid_bcd[0])
    );
    
    displaydecimal dec_garrafas_dez (
        .DECSEG(HEX1),
        .A(garrafas_dez_bcd[3]),
        .B(garrafas_dez_bcd[2]),
        .C(garrafas_dez_bcd[1]),
        .D(garrafas_dez_bcd[0])
    );
    
    // Dúzias
    displaydecimal dec_duzias_unid (
        .DECSEG(HEX2),
        .A(duzias_unid_bcd[3]),
        .B(duzias_unid_bcd[2]),
        .C(duzias_unid_bcd[1]),
        .D(duzias_unid_bcd[0])
    );
    
    displaydecimal dec_duzias_dez (
        .DECSEG(HEX3),
        .A(duzias_dez_bcd[3]),
        .B(duzias_dez_bcd[2]),
        .C(duzias_dez_bcd[1]),
        .D(duzias_dez_bcd[0])
    );
    
    // Rolhas
    displaydecimal dec_rolhas_unid (
        .DECSEG(HEX4),
        .A(rolhas_unid_bcd[3]),
        .B(rolhas_unid_bcd[2]),
        .C(rolhas_unid_bcd[1]),
        .D(rolhas_unid_bcd[0])
    );
    
    displaydecimal dec_rolhas_dez (
        .DECSEG(HEX5),
        .A(rolhas_dez_bcd[3]),
        .B(rolhas_dez_bcd[2]),
        .C(rolhas_dez_bcd[1]),
        .D(rolhas_dez_bcd[0])
    );

endmodule