module fsm_vedacao (
    output GARRAFA_VEDADA,
    output DECREMENTA_ROLHA,
    input CLOCK,
    input RESET,
    input GARRAFA_PRESENTE,
    input ROLHAS_DISPONIVEIS
	 // Sensor de vedação completa
);

    reg estado_atual;
    reg estado_proximo;
    
    localparam NAO_VEDADA = 1'b0;
    localparam VEDADA     = 1'b1;
    
    // -------------------------------------------------------
    // LÓGICA DE TRANSIÇÃO
    // -------------------------------------------------------
    always @(*) begin
        case (estado_atual)
            NAO_VEDADA: begin
                // Só veda se TEM garrafa E TEM rolhas E sensor confirma
                if (GARRAFA_PRESENTE && ROLHAS_DISPONIVEIS)
                    estado_proximo = VEDADA;
                else
                    estado_proximo = NAO_VEDADA;
            end
            
            VEDADA: begin
                // Volta apenas quando garrafa SAI
                // ROLHAS não importa mais aqui!
                if (!GARRAFA_PRESENTE)
                    estado_proximo = NAO_VEDADA;
                else
                    estado_proximo = VEDADA;
            end
        endcase
    end
    
    // -------------------------------------------------------
    // FLIP-FLOP DE ESTADO
    // -------------------------------------------------------
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= NAO_VEDADA;
        else
            estado_atual <= estado_proximo;
    end
    
    // -------------------------------------------------------
    // SAÍDAS (MOORE)
    // -------------------------------------------------------
    assign GARRAFA_VEDADA = (estado_atual == VEDADA);
    
    // Pulso na TRANSIÇÃO NAO_VEDADA → VEDADA
    assign DECREMENTA_ROLHA = (estado_atual == NAO_VEDADA) && 
                              (estado_proximo == VEDADA);

endmodule


/*// Na top-level, gerenciar o alarme:
wire alarme_sem_rolha;
wire motor_bloqueado;

assign alarme_sem_rolha = !ROLHAS_DISPONIVEIS;

// Motor só liga se START=1 E ROLHAS=1
// Se ROLHAS=0 durante operação, motor para
assign motor_bloqueado = (fsm_vedacao.estado_atual == NAO_VEDADA) && 
                         (GARRAFA_PRESENTE) && 
                         (!ROLHAS_DISPONIVEIS);

assign LEDR[0] = alarme_sem_rolha || motor_bloqueado;*/