// ============================================================
// FSM DE VEDAÇÃO — 2 ESTADOS (MOORE)

// Responsável por detectar quando uma garrafa é vedada e gerar 
// um pulso para decrementar o estoque de rolhas.
// ============================================================

module fsm_vedacao (
    // Saídas
    output GARRAFA_VEDADA,       // Indica que a garrafa foi vedada (Moore)
    output DECREMENTA_ROLHA,     // Pulso gerado ao vedar (subtração de estoque)

    // Entradas
    input CLOCK,
    input RESET,
    input GARRAFA_CHEIA,         // Garrafa pronta para vedação
    input GARRAFA_PRESENTE,      // Indica garrafa posicionada
    input ROLHAS_DISPONIVEIS     // Evita vedação sem rolhas
);

    // -------------------------------------------------------
    // ESTADOS (Moore: 1 bit)
    // -------------------------------------------------------
    localparam NAO_VEDADA = 1'b0;   // Garrafa ainda não vedada
    localparam VEDADA     = 1'b1;   // Garrafa já recebeu a rolha

    reg estado_atual, estado_proximo;
    reg estado_anterior;            // Usado para gerar pulso de transição
    reg flag_vedada;                // Indica vedação (saída de Moore)

    assign GARRAFA_VEDADA = flag_vedada;

    // -------------------------------------------------------
    // LÓGICA DE TRANSIÇÃO DE ESTADOS 

    always @(*) begin
        case (estado_atual)

            // -----------------------------------------------
            // ESTADO: A garrafa ainda não foi vedada

            NAO_VEDADA: begin
                // Transita para "VEDADA" quando todas condições estão OK
                if (GARRAFA_CHEIA && GARRAFA_PRESENTE && ROLHAS_DISPONIVEIS)
                    estado_proximo = VEDADA;
                else
                    estado_proximo = NAO_VEDADA;
            end

            // -----------------------------------------------
            // ESTADO: Garrafa já foi vedada

            VEDADA: begin
                // Volta para "NAO_VEDADA" quando a garrafa sai
                if (!GARRAFA_PRESENTE)
                    estado_proximo = NAO_VEDADA;
                else
                    estado_proximo = VEDADA;
            end

            default:
                estado_proximo = NAO_VEDADA;
        endcase
    end

    // -------------------------------------------------------
    // REGISTRADORES DE ESTADO E LÓGICA DA FLAG DE VEDAÇÃO 

    always @(posedge CLOCK or posedge RESET) begin

        if (RESET) begin
            estado_atual    <= NAO_VEDADA;
            estado_anterior <= NAO_VEDADA;
            flag_vedada     <= 1'b0;

        end else begin
            estado_anterior <= estado_atual;
            estado_atual    <= estado_proximo;

            // Flag: ativa ao entrar em VEDADA
            if (estado_atual == VEDADA) begin
                flag_vedada <= 1'b1;
            end

            // Reseta quando a garrafa é removida
            else if (!GARRAFA_PRESENTE) begin
                flag_vedada <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------
    // PULSO PARA DECREMENTAR O ESTOQUE DE ROLHAS

    assign DECREMENTA_ROLHA = (estado_anterior == NAO_VEDADA) && (estado_atual == VEDADA);

endmodule
