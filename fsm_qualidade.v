// ===============================================================
// FSM DA QUALIDADE — 2 ESTADOS (MEALY)

// Decide se a garrafa é aprovada (lacre) ou reprovada (descarte). 
// ===============================================================

module fsm_qualidade (
    // Saídas
    output DESCARTE,              // Pulso de rejeição
    output LACRE,                 // Pulso de aprovação
    output INCREMENTA_GARRAFA,    // Incrementa contador (quando aprovada)
    output EM_INSPECAO,           // A garrafa está sendo avaliada
    
    // Entradas
    input CLOCK,
    input RESET,
    input GARRAFA_ENCHIMENTO,     // Garrafa presente no estágio anterior
    input GARRAFA_VEDADA,         // Pulso sinalizando a vedação
    input PULSO_APROVADA,         // Chave que aprova
    input PULSO_REPROVADA         // Chave que reprova
);

    // Estados
    localparam AGUARDANDO    = 1'b0;   // Esperando garrafa vedada
    localparam INSPECIONANDO = 1'b1;   // Avaliando aprovação/reprovação
    
    reg estado_atual, estado_proximo;
    reg descarte_reg;                 // Saída Mealy: depende de estado + entrada
    reg lacre_reg;                    // Saída Mealy: depende de estado + entrada
    reg garrafa_vedada_latched;       // Guarda pulso curto de vedação

    // Saídas diretas
    assign DESCARTE    = descarte_reg;
    assign LACRE       = lacre_reg;
    assign EM_INSPECAO = (estado_atual == INSPECIONANDO);

    // ===========================================================
    // LÓGICA DE TRANSIÇÃO 

    always @(*) begin
        estado_proximo = estado_atual;

        // Sinais começam zerados
        descarte_reg = 1'b0;
        lacre_reg    = 1'b0;
        
        case (estado_atual)

            // --------------------------------------------
            // ESTADO: AGUARDANDO
            // Espera a garrafa vedada chegar ao setor

            AGUARDANDO: begin
                // Usa o latch para capturar pulso curto de vedação
                if (garrafa_vedada_latched && !GARRAFA_ENCHIMENTO)
                    estado_proximo = INSPECIONANDO;
            end
            
            // --------------------------------------------
            // ESTADO: INSPECIONANDO

            INSPECIONANDO: begin
                
                // Se uma nova garrafa chega antes da decisão
                if (GARRAFA_ENCHIMENTO)
                    estado_proximo = AGUARDANDO;

                // Aprovação → pulso combinacional
                else if (PULSO_APROVADA && !PULSO_REPROVADA) begin
                    lacre_reg = 1'b1;
                    estado_proximo = AGUARDANDO;
                end

                // Reprovação → pulso combinacional
                else if (PULSO_REPROVADA && !PULSO_APROVADA) begin
                    descarte_reg = 1'b1;
                    estado_proximo = AGUARDANDO;
                end
            end

            default: estado_proximo = AGUARDANDO;
        endcase
    end

    // ===========================================================
    // FLIP-FLOPS DO ESTADO E SINAL DE "GARRAFA_VEDADA"
    // ===========================================================
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            estado_atual <= AGUARDANDO;
            garrafa_vedada_latched <= 1'b0;
        end 
        else begin
            estado_atual <= estado_proximo;

            // Guarda o pulso curto de vedação
            if (GARRAFA_VEDADA)
                garrafa_vedada_latched <= 1'b1;

            // Libera latch quando decisão for tomada
            else if ((PULSO_APROVADA || PULSO_REPROVADA) && estado_atual == INSPECIONANDO)
                garrafa_vedada_latched <= 1'b0;
        end
    end

    // Pulso para contador de garrafas aprovadas (Mealy)
    assign INCREMENTA_GARRAFA = (estado_atual == INSPECIONANDO) && lacre_reg;

endmodule
