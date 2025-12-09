// ============================================
// FSM DO MOTOR — 2 ESTADOS (MOORE)

// Controla o motor que move as garrafas na esteira,
// ligando somente quando o sistema está liberado.
// ============================================

module fsm_motor (
    output MOTOR_ATIVO,          // Motor ligado (LED)
    input CLOCK,
    input RESET,
    input START,                 // Pulso de início do sistema
    input ROLHAS_DISPONIVEIS,    // Estoque suficiente
    input GARRAFA_PRESENTE,      // Sensor na esteira
    input PROCESSO_ATIVO         // Outra FSM está ocupada
);

    // Estado atual e próximo
    reg estado_atual;
    reg estado_proximo;
    
    // Codificação dos estados
    localparam MOTOR_OFF = 1'b0;   // Motor parado
    localparam MOTOR_ON  = 1'b1;   // Motor ligado
    
    // -------------------------------------------------------
    // LÓGICA DE TRANSIÇÃO

    always @(*) begin
        case (estado_atual)

            MOTOR_OFF: begin
                // Liga se: START ativo + tem rolhas + esteira livre + nenhum processo rodando
                if (START && ROLHAS_DISPONIVEIS && !GARRAFA_PRESENTE && !PROCESSO_ATIVO)
                    estado_proximo = MOTOR_ON;
                else
                    estado_proximo = MOTOR_OFF;
            end
            
            MOTOR_ON: begin
                // Desliga se qualquer condição impedir avanço
                if (GARRAFA_PRESENTE || !START || !ROLHAS_DISPONIVEIS)
                    estado_proximo = MOTOR_OFF;
                else
                    estado_proximo = MOTOR_ON;
            end

        endcase
    end
    
    // -------------------------------------------------------
    // REGISTRO DE ESTADO (Síncrono)
-
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= MOTOR_OFF;
        else
            estado_atual <= estado_proximo;
    end
    
    // -------------------------------------------------------
    // SAÍDA (MOORE)

    assign MOTOR_ATIVO = (estado_atual == MOTOR_ON);

endmodule
