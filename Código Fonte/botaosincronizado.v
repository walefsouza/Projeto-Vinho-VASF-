// ====================================================================
// Sincronizador de Botão (Ativo-Low com Detecção de Borda)
// para remover a metaestabilidade e detecta borda de subida
// ====================================================================

module botaosincronizado (
    input entrada,        // Entrada do botão (ativo-low)
    input CLOCK,          // Clock do sistema
    input RESET,          // Reset 
    output saida          // Pulso de 1 ciclo na borda de subida
);

    // =================================================================
    // WIRES INTERNOS
    // =================================================================

    wire notentrada;        // Botão invertido 
    wire sinal1;            // Primeiro estágio de sincronização
    wire sinal2;            // Segundo estágio de sincronização
    wire sinalatrasado;     // Sinal atrasado em 1 ciclo
    wire notsinalatrasado;  // Negação do sinal atrasado

    // Invertendo sinal do botão
    not NotEntrada(notentrada, entrada);


    /* - - - Dois flip-flops em cascata para sincronizar com o clock - - - */

    // Primeiro estágio de sincronização
    flipflopbase FFSINAL1 (
    .Q(sinal1),
    .D(notentrada),
    .CLOCK(CLOCK),
    .RESET(RESET)
    );

    // Segundo estágio de sincronização (sinal estável)
    flipflopbase FFSINAL2 (
    .Q(sinal2),
    .D(sinal1),
    .CLOCK(CLOCK),
    .RESET(RESET)
    );


    /* - - - Criando versão atrasada em 1 ciclo para comparar a borda - - - */

    flipflopbase FFATRASO (
    .Q(sinalatrasado),
    .D(sinal2),
    .CLOCK(CLOCK),
    .RESET(RESET)
    );

    /* - - - Detectando borda de subida do botão - - -

    Borda detectada quando: sinal2=1 E sinalatrasado=0
    Isso ocorre por apenas 1 ciclo de clock */

    not NotAtrasado(notsinalatrasado, sinalatrasado);

    and DetectorBorda(saida, sinal2, notsinalatrasado);

endmodule