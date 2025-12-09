// ============================================
// FLIP-FLOP D DE BORDA DE SUBIDA (RESET SÍNCRONO)
// Armazena 1 bit na borda de subida do clock.
// O reset só é aplicado durante o clock.
// ============================================

module flipflopbase (Q, D, CLOCK, RESET);

    input D;        // Entrada de dados
    input CLOCK;    // Clock de acionamento
    input RESET;    // Reset síncrono (ativo alto)
    output reg Q;   // Saída armazenada

    // Atualiza Q somente na borda de subida do clock
    always @(posedge CLOCK) begin
        if (RESET)
            Q <= 1'b0;   // Zera a saída durante o clock
        else
            Q <= D;      // Copia o valor de D
    end

endmodule
