// =============================================================================================
// DISPENSADOR DE ROLHAS (REABASTECE AS ROLHAS DO CONTADOR AUTOMATICAMENTE OU MANUALEMENTE (SW7))
// =============================================================================================

module dispensadorrolhas (
    output reg [7:0] ESTOQUE,           // Quantidade de rolhas disponíveis
    output reg DISPENSADOR_ATIVO,       // Indicador visual de operação (LED)
    output reg LOAD_CONTADOR,           // Sinal de carga para o contador externo
    output reg [6:0] VALOR_CARGA,       // Valor que será aplicado ao contador
    input  [6:0] COUNT_ATUAL,           // Quantidade atual de rolhas processadas
    input  ADDROLHASMANUAL,             // Pulso de incremento manual (SW7)
    input  CLOCK,
    input  RESET
);

    // --------------------------------------------------------
    // Parâmetros Definidos

    localparam [7:0] CAPACIDADE  = 8'd100;      // Estoque inicial máximo
    localparam [6:0] QTD_RECARGA = 7'd15;       // Quantidade recarregada automaticamente
    localparam [6:0] LIMITE_MIN  = 7'd5;        // Limite para acionar recarga automática

    // --------------------------------------------------------
    // Sinais auxiliares

    wire precisa_recarga;            // alto quando COUNT_ATUAL <= 5
    wire tem_estoque;                // alto se ainda existe estoque disponível
    wire [7:0] transferencia_auto;   // Quantidade a ser recarregada
    wire [7:0] novo_valor_auto;      // Resultado do contador após a recarga

    // Verifica necessidade de recarga e disponibilidade no estoque
    assign precisa_recarga  = (COUNT_ATUAL <= LIMITE_MIN);
    assign tem_estoque = (ESTOQUE > 8'd0);

    // Define quanto será transferido automaticamenten (15 rolhas ou o restante disponível)
    assign transferencia_auto = (ESTOQUE >= QTD_RECARGA) ? QTD_RECARGA : ESTOQUE;

    // Soma COUNT_ATUAL + transferência automática (8 bits)
    assign novo_valor_auto = {1'b0, COUNT_ATUAL} + transferencia_auto;

    // --------------------------------------------------------
    // LÓGICA PRINCIPAL

    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin

            // Estado inicial
            ESTOQUE           <= CAPACIDADE;
            DISPENSADOR_ATIVO <= 1'b0;
            LOAD_CONTADOR     <= 1'b0;
            VALOR_CARGA       <= 7'd0;

        end else begin

            // Estado padrão por ciclo: desabilita sinais
            DISPENSADOR_ATIVO <= 1'b0;
            LOAD_CONTADOR     <= 1'b0;

            // ==================================================
            // CONDIÇÃO 1 — RECARGA AUTOMÁTICA
            // O contador é recarregado assim que o valor atual
            // está abaixo do limite e ainda existe estoque.

            if (precisa_recarga && tem_estoque) begin

                DISPENSADOR_ATIVO <= 1'b1;   // Indica operação
                LOAD_CONTADOR     <= 1'b1;   // Habilita carga

                // Limita o contador ao valor máximo (99)
                if (novo_valor_auto > 8'd99)
                    VALOR_CARGA <= 7'd99;
                else
                    VALOR_CARGA <= novo_valor_auto[6:0];

                // Atualiza estoque após recarga
                ESTOQUE <= ESTOQUE - transferencia_auto;
            end

            // ==================================================
            // CONDIÇÃO 2 — ADIÇÃO MANUAL (SW7)
            // Permite adicionar uma rolha manualmente, desde que
            // o contador ainda não esteja cheio.

            else if (ADDROLHASMANUAL && (COUNT_ATUAL < 7'd99)) begin

                DISPENSADOR_ATIVO <= 1'b1;  // Indica operação
                LOAD_CONTADOR     <= 1'b1;  // Habilita carga

                // Incremento unitário
                VALOR_CARGA <= COUNT_ATUAL + 7'd1;

            end
        end
    end

endmodule
