// ============================================
// LEVEL TO PULSE (Detector de Borda de Subida)
// ============================================

module leveltopulse (
    output PULSE,     // Pulso de 1 ciclo quando LEVEL sobe
    input CLOCK,      // Clock da lógica
    input RESET,      // Reset
    input LEVEL       // Entrada em nível que será monitorada
);

    reg level_anterior;  // Armazena LEVEL do ciclo anterior
    
    // -------------------------------------------------------
    // REGISTRADOR DO NÍVEL ANTERIOR

    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            level_anterior <= 1'b0;   // Estado inicial
        else
            level_anterior <= LEVEL;  // Atualiza histórico
    end

    assign PULSE = LEVEL && !level_anterior;

endmodule
