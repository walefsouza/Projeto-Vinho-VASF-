module fsm_qualidade (
    output GARRAFA_APROVADA,
    output INCREMENTA_DUZIA,    // Pulso quando aprova
    input CLOCK,
    input RESET,
    input GARRAFA_PRESENTE,
    input SENSOR_QUALIDADE,
    input GARRAFA_CHEIA,        // Da FSM Enchimento
    input GARRAFA_VEDADA        // Da FSM Vedação
);

//level to pulse?

    reg estado_atual;
    reg estado_proximo;
    
    localparam NAO_APROVADA = 1'b0;
    localparam APROVADA     = 1'b1;
    
    always @(*) begin
        case (estado_atual)
            NAO_APROVADA: begin
                // Só aprova se TUDO estiver OK
                if (GARRAFA_PRESENTE && SENSOR_QUALIDADE && 
                    GARRAFA_CHEIA && GARRAFA_VEDADA)
                    estado_proximo = APROVADA;
                else
                    estado_proximo = NAO_APROVADA;
            end
            
            APROVADA: begin
                if (!GARRAFA_PRESENTE)  // Garrafa saiu
                    estado_proximo = NAO_APROVADA;
                else
                    estado_proximo = APROVADA;
            end
        endcase
    end
    
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= NAO_APROVADA;
        else
            estado_atual <= estado_proximo;
    end
    
    assign GARRAFA_APROVADA = (estado_atual == APROVADA);
    
    // Pulso de incremento na transição para APROVADA
    assign INCREMENTA_DUZIA = (!estado_atual) && estado_proximo;

endmodule