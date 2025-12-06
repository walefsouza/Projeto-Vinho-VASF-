// ============================================
// FSM ENCHIMENTO - 3 ESTADOS (MOORE)
// ============================================

module fsm_enchimento (
    output VALVULA_EV,          // LED da válvula
    output GARRAFA_CHEIA,       // Flag para próxima FSM
    input CLOCK,
    input RESET,
    input GARRAFA_PRESENTE,
    input SENSOR_NIVEL          // Detecta nível cheio
);

    // Codificação de estados (3 estados = 2 bits)
    localparam [1:0] VAZIA    = 2'b00,
                     ENCHENDO = 2'b01,
                     CHEIA    = 2'b10;
    
    reg [1:0] estado_atual, estado_proximo;
    
    // -------------------------------------------------------
    // LÓGICA DE TRANSIÇÃO (Combinacional)
    // -------------------------------------------------------
    always @(*) begin
        estado_proximo = estado_atual;  // Padrão: mantém
        
        case (estado_atual)
		  
            VAZIA: begin
                if (GARRAFA_PRESENTE)
                    estado_proximo = ENCHENDO;
            end
            
            ENCHENDO: begin
                if (SENSOR_NIVEL)
                    estado_proximo = CHEIA;
                // Se garrafa sair durante enchimento (erro)
                else if (!GARRAFA_PRESENTE)
                    estado_proximo = VAZIA;
            end
            
            CHEIA: begin
                if (!GARRAFA_PRESENTE)
                    estado_proximo = VAZIA;
            end
            
            default: estado_proximo = VAZIA;
        endcase
    end
    
    // -------------------------------------------------------
    // FLIP-FLOPS DE ESTADO (Síncrono)
    // -------------------------------------------------------
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= VAZIA;
        else
            estado_atual <= estado_proximo;
    end
    
    // -------------------------------------------------------
    // SAÍDAS (MOORE - dependem apenas do estado)
    // -------------------------------------------------------
    assign VALVULA_EV = (estado_atual == ENCHENDO);
    assign GARRAFA_CHEIA = (estado_atual == CHEIA);

endmodule