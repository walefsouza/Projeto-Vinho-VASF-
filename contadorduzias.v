// ============================================================================
// CONTADOR DE DÚZIAS (0–10) COM CARGA PARALELA
// ============================================================================

module contadorduzias (
    output [3:0] COUNT, // Contagem atual (0–10)
    input CLOCK,        // Clock do sistema
    input RESET,        // Reset assíncrono
    input ENABLE        // Pulso de incremento
);

    // Sinais internos
    wire [3:0] Qbar;
    wire [3:0] And;
    wire [3:0] Xor;
    wire [3:0] Mux;
    wire LIMITE;
    wire LOAD;
    wire EnableReal;

    // -------------------------------------------------------------------------
    // DETECÇÃO DO VALOR LIMITE (10 = 1010)
    // LIMITE = 1 quando COUNT = 1010

    wire notQ2, notQ1;
    not NotQ2 (notQ2, COUNT[2]);
    not NotQ1 (notQ1, COUNT[1]);
    and AndLimite (LIMITE, COUNT[3], notQ2, notQ1, COUNT[0]);

    // LOAD = 1 no ciclo que COUNT alcança 10 e ENABLE = 1
    and AndLoad (LOAD, LIMITE, ENABLE);

    // Evita incrementar após LOAD
    wire notLOAD;
    not NotLOAD (notLOAD, LOAD);
    and AndEnableParar (EnableReal, ENABLE, notLOAD);

    // -------------------------------------------------------------------------
    // FLIP-FLOPS DO CONTADOR 

    flipflopassincrono FF0 (.Q(COUNT[0]), .D(Mux[0]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF1 (.Q(COUNT[1]), .D(Mux[1]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF2 (.Q(COUNT[2]), .D(Mux[2]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopassincrono FF3 (.Q(COUNT[3]), .D(Mux[3]), .CLOCK(CLOCK), .RESET(RESET));

    // -------------------------------------------------------------------------
    // LÓGICA DE INCREMENTO 

    not Not0 (Qbar[0], COUNT[0]);
    not Not1 (Qbar[1], COUNT[1]);
    not Not2 (Qbar[2], COUNT[2]);
    not Not3 (Qbar[3], COUNT[3]);

    and And0 (And[0], EnableReal, COUNT[0]);
    and And1 (And[1], And[0], COUNT[1]);
    and And2 (And[2], And[1], COUNT[2]);

    xor Xor0 (Xor[0], COUNT[0], EnableReal);
    xor Xor1 (Xor[1], COUNT[1], And[0]);
    xor Xor2 (Xor[2], COUNT[2], And[1]);
    xor Xor3 (Xor[3], COUNT[3], And[2]);

    // -------------------------------------------------------------------------
    // CARGA PARALELA
    // LOAD = 1 → COUNT = 0
    // LOAD = 0 → COUNT = valor incrementado

    multiplexador2x1 MUX0 (.S(Mux[0]), .Sel(LOAD), .A(Xor[0]), .B(1'b0)); 
    multiplexador2x1 MUX1 (.S(Mux[1]), .Sel(LOAD), .A(Xor[1]), .B(1'b0)); 
    multiplexador2x1 MUX2 (.S(Mux[2]), .Sel(LOAD), .A(Xor[2]), .B(1'b0)); 
    multiplexador2x1 MUX3 (.S(Mux[3]), .Sel(LOAD), .A(Xor[3]), .B(1'b0));

endmodule
