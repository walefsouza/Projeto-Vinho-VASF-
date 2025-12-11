// ============================================================================
// CONTADOR TOGGLE (MEMÓRIA START/STOP)
// ============================================================================

// Armazena um estado que alterna entre 0 e 1 sempre que um pulso é recebido.
// Usado para alternar modos de iniciar/parar o motor

module contadortoggle (
    output reg Q,    // Estado armazenado 
    input PULSO,     // Pulso de alternância
    input CLOCK,     // Clock do sistema
    input RESET      // Reset assíncrono
);

    // Alternância síncrona do estado
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            Q <= 1'b0;    
        else if (PULSO)
            Q <= !Q;      
    end

endmodule
