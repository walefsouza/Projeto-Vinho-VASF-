// ============================================================================
// CONTADOR DE ROLHAS DECRESCENTE (99-0) COM CARGA PARARELA
// ============================================================================

module contadorrolhas (
    output [6:0] COUNT,
    output ZERO,
    input CLOCK,
    input RESET,
    input LOAD,
    input ENABLE,
    input [6:0] DADOS
);
    wire [6:0] Xor;
    reg [6:0] Qcount;
    wire [6:0] Qbar;
    wire [6:0] And;
    wire [6:0] Mux;
    wire EnableReal;

    assign COUNT = Qcount;

    // -------------------------------------------------------
    // 1. FLIP-FLOPS COMPORTAMENTAIS COM VALOR INICIAL
    // -------------------------------------------------------
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            Qcount <= 7'd20;  // ← Carrega 99 no reset!
        else begin
            Qcount[0] <= Mux[0];
            Qcount[1] <= Mux[1];
            Qcount[2] <= Mux[2];
            Qcount[3] <= Mux[3];
            Qcount[4] <= Mux[4];
            Qcount[5] <= Mux[5];
            Qcount[6] <= Mux[6];
        end
    end

    // -------------------------------------------------------
    // 2. INVERSORES
    // -------------------------------------------------------
    not Not0 (Qbar[0], Qcount[0]);
    not Not1 (Qbar[1], Qcount[1]);
    not Not2 (Qbar[2], Qcount[2]);
    not Not3 (Qbar[3], Qcount[3]);
    not Not4 (Qbar[4], Qcount[4]);
    not Not5 (Qbar[5], Qcount[5]);
    not Not6 (Qbar[6], Qcount[6]);

    // -------------------------------------------------------
    // 3. DETECÇÃO DE ZERO
    // -------------------------------------------------------
    and AndZeroDetect (ZERO, Qbar[0], Qbar[1], Qbar[2], Qbar[3], Qbar[4], Qbar[5], Qbar[6]);

    // -------------------------------------------------------
    // 4. LÓGICA DE BLOQUEIO
    // -------------------------------------------------------
    wire notZERO;
    not NotZERO (notZERO, ZERO);
    and AndEnableBlock (EnableReal, ENABLE, notZERO);

    // -------------------------------------------------------
    // 5. CADEIA DE EMPRÉSTIMO
    // -------------------------------------------------------
    and And0 (And[0], EnableReal, Qbar[0]);
    and And1 (And[1], And[0], Qbar[1]);
    and And2 (And[2], And[1], Qbar[2]);
    and And3 (And[3], And[2], Qbar[3]);
    and And4 (And[4], And[3], Qbar[4]);
    and And5 (And[5], And[4], Qbar[5]);

    // -------------------------------------------------------
    // 6. LÓGICA XOR
    // -------------------------------------------------------
    xor Xor0 (Xor[0], Qcount[0], EnableReal);
    xor Xor1 (Xor[1], Qcount[1], And[0]);
    xor Xor2 (Xor[2], Qcount[2], And[1]);
    xor Xor3 (Xor[3], Qcount[3], And[2]);
    xor Xor4 (Xor[4], Qcount[4], And[3]);
    xor Xor5 (Xor[5], Qcount[5], And[4]);
    xor Xor6 (Xor[6], Qcount[6], And[5]);

    // -------------------------------------------------------
    // 7. MULTIPLEXADORES (LOAD vs DECREMENTO)
    // -------------------------------------------------------
    multiplexador2x1 MUX0 (.S(Mux[0]), .Sel(LOAD), .A(Xor[0]), .B(DADOS[0])); 
    multiplexador2x1 MUX1 (.S(Mux[1]), .Sel(LOAD), .A(Xor[1]), .B(DADOS[1])); 
    multiplexador2x1 MUX2 (.S(Mux[2]), .Sel(LOAD), .A(Xor[2]), .B(DADOS[2])); 
    multiplexador2x1 MUX3 (.S(Mux[3]), .Sel(LOAD), .A(Xor[3]), .B(DADOS[3])); 
    multiplexador2x1 MUX4 (.S(Mux[4]), .Sel(LOAD), .A(Xor[4]), .B(DADOS[4])); 
    multiplexador2x1 MUX5 (.S(Mux[5]), .Sel(LOAD), .A(Xor[5]), .B(DADOS[5])); 
    multiplexador2x1 MUX6 (.S(Mux[6]), .Sel(LOAD), .A(Xor[6]), .B(DADOS[6])); 


    endmodule
