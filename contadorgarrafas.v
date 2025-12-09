// ============================================================================
// CONTADOR DE GARRAFAS (0–12) COM PULSO DE DÚZIA COMPLETA
// ============================================================================

module contadorgarrafas (
    output DUZIA_COMPLETA, // Pulso de 1 ciclo indicando que completou 12 garrafas
    output [3:0] COUNT,    // Valor atual do contador (0–11)
    input CLOCK,           // Clock do sistema
    input RESET,           // Reset assíncrono
    input ENABLE           // Pulso que habilita incremento
);

    // =========================================================================
    //   WIRES INTERNOS

    wire [3:0] Qbar;          // Inversões de COUNT 
    wire [3:0] And;           // Sinais intermediários 
    wire [3:0] Xor;           // Bits incrementados
    wire [3:0] Mux;           // Saída dos multiplexadores (para carregar 0)
    
    wire LIMITE;              // Identifica quando COUNT está em 11 (1011)
    wire LOAD;                // Pulso para zerar contador e ativar DUZIA_COMPLETA
    wire EnableReal;          // ENABLE bloqueado quando LOAD=1

    // =========================================================================
    //   DETECÇÃO DO LIMITE (VALOR 11 = 1011)
    //   LIMITE = 1 quando COUNT == 1011

    wire notQ2;
    not NotQ2 (notQ2, COUNT[2]);
    and AndLimit (LIMITE, COUNT[3], notQ2, COUNT[1], COUNT[0]);

    // =========================================================================
    //   PULSO DE DÚZIA COMPLETA
    //   LOAD = 1 por 1 ciclo quando está em 11 E ENABLE = 1

    and AndLoad (LOAD, LIMITE, ENABLE);
    assign DUZIA_COMPLETA = LOAD;

    // =========================================================================
    //   CONTROLE DE ENABLE PARA EVITAR CONTAGEM APÓS LIMITE
    //   EnableReal = ENABLE enquanto não estiver carregando LOAD
    // =========================================================================

    wire notLOAD;
    not NotLOAD (notLOAD, LOAD);
    and AndEnableBlock (EnableReal, ENABLE, notLOAD);

    // =========================================================================
    //   FLIP-FLOPS ASSÍNCRONOS PARA ARMAZENAR O CONTADOR

    flipflopassincrono FF0 (.Q(COUNT[0]), .D(Mux[0]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF1 (.Q(COUNT[1]), .D(Mux[1]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF2 (.Q(COUNT[2]), .D(Mux[2]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF3 (.Q(COUNT[3]), .D(Mux[3]), .CLOCK(CLOCK), .RESET(RESET));

    // =========================================================================
    //   INVERSORES PARA AUXILIAR A LÓGICA DE INCREMENTO

    not Not0 (Qbar[0], COUNT[0]);
    not Not1 (Qbar[1], COUNT[1]);
    not Not2 (Qbar[2], COUNT[2]);
    not Not3 (Qbar[3], COUNT[3]);

    // =========================================================================
    //   LÓGICA DE CARRY PARA INCREMENTO BINÁRIO

    and And0 (And[0], EnableReal, COUNT[0]);
    and And1 (And[1], And[0], COUNT[1]);
    and And2 (And[2], And[1], COUNT[2]);

    // =========================================================================
    //   XOR PARA GERAR OS BITS INCREMENTADOS

    xor Xor0 (Xor[0], COUNT[0], EnableReal);
    xor Xor1 (Xor[1], COUNT[1], And[0]);
    xor Xor2 (Xor[2], COUNT[2], And[1]);
    xor Xor3 (Xor[3], COUNT[3], And[2]);

    // =========================================================================
    //   MUXES PARA ZERAR O CONTADOR QUANDO LOAD = 1
    //   LOAD = 1 → saída = 0
    //   LOAD = 0 → saída = valor incrementado

    multiplexador2x1 MUX0 (.S(Mux[0]), .Sel(LOAD), .A(Xor[0]), .B(1'b0)); 
    multiplexador2x1 MUX1 (.S(Mux[1]), .Sel(LOAD), .A(Xor[1]), .B(1'b0)); 
    multiplexador2x1 MUX2 (.S(Mux[2]), .Sel(LOAD), .A(Xor[2]), .B(1'b0)); 
    multiplexador2x1 MUX3 (.S(Mux[3]), .Sel(LOAD), .A(Xor[3]), .B(1'b0)); 

endmodule
