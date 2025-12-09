// ==================================================
// FLIP-FLOP D COM RESET ASSÍNCRONO 
// Armazena o valor de D na borda de subida do clock.
// Quando RESET=1, força Q para 0 imediatamente.
// ==================================================

module flipflopassincrono (Q, D, CLOCK, RESET);

    input D;        // Entrada de dados
    input CLOCK;    // Clock 
    input RESET;    // Reset assíncrono (ativo alto)
    output reg Q;   // Saída armazenada

    // Atualiza Q no clock ou limpa no reset
    always @(posedge CLOCK or posedge RESET) 
        if (RESET) 
            Q <= 1'b0;
        else 
            Q <= D;

endmodule
