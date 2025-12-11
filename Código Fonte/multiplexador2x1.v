// =================================================
// MULTIPLEXADOR 2x1 =

// Seleciona uma das duas entradas (A ou B) para
// a saída S, de acordo com o sinal de seleção Sel:

module multiplexador2x1(S, Sel, A, B); 

    input Sel;   // Sinal de seleção
    input A;     // Entrada 0
    input B;     // Entrada 1
    output S;    // Saída do mux

    wire nsel;   // Sel invertido
    wire and0;   // Seleção do caminho A
    wire and1;   // Seleção do caminho B

    // Sel = 0
    not Not0 (nsel, Sel);
    and And0 (and0, A, nsel);

    // Sel = 1
    and And1 (and1, B, Sel);

    // Saida
    or Or0 (S, and0, and1);

endmodule
