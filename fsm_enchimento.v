// ================================================
// FSM ENCHIMENTO — 3 ESTADOS (MOORE)

// Controla a válvula de enchimento de garrafas.
// O comportamento depende apenas do estado atual.
// ================================================

module fsm_enchimento (
    output VALVULA_EV,          // Ativa a válvula durante o enchimento
    output GARRAFA_CHEIA,       // Indica finalização do processo
    input CLOCK,
    input RESET,
    input GARRAFA_PRESENTE,     // Garrafa posicionada no sensor
    input SENSOR_NIVEL          // Detecta garrafa cheia
);

    // --------------------------------------------
    // Codificação dos estados da FSM (Moore)

    localparam [1:0] VAZIA    = 2'b00;   // Nenhuma garrafa posicionada
    localparam [1:0] ENCHENDO = 2'b01;   // Válvula aberta, enchendo
    localparam [1:0] CHEIA    = 2'b10;   // Garrafa totalmente cheia

    reg [1:0] estado_atual, estado_proximo;

    // --------------------------------------------
    // LÓGICA DE PRÓXIMO ESTADO (Combinacional)

    always @(*) begin
        estado_proximo = estado_atual;  // Padrão: mantém o estado
        
        case (estado_atual)

            // Aguarda a chegada da garrafa
            VAZIA: begin
                if (GARRAFA_PRESENTE)
                    estado_proximo = ENCHENDO;
            end
            
            // Enchendo: finaliza ao detectar nível máximo
            ENCHENDO: begin
                if (SENSOR_NIVEL)
                    estado_proximo = CHEIA;
                else if (!GARRAFA_PRESENTE)
                    estado_proximo = VAZIA;   // Retorno seguro
            end
            
            // Garrafa cheia: volta ao estado inicial ao removê-la
            CHEIA: begin
                if (!GARRAFA_PRESENTE)
                    estado_proximo = VAZIA;
            end
            
            default:
                estado_proximo = VAZIA;
        endcase
    end
    
    // --------------------------------------------
    // REGISTRADOR DE ESTADO (Síncrono)

    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= VAZIA;
        else
            estado_atual <= estado_proximo;
    end
    
    // --------------------------------------------
    // SAÍDAS DO TIPO MOORE
    // Dependem somente do estado atual

    assign VALVULA_EV = (estado_atual == ENCHENDO);
    assign GARRAFA_CHEIA = (estado_atual == CHEIA);

endmodule
