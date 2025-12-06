module fsm_motor (
    output MOTOR_ATIVO,
    input CLOCK,
    input RESET,
    input START,
    input ROLHAS_DISPONIVEIS,
    input GARRAFA_PRESENTE
);

    reg estado_atual;
    reg estado_proximo;
    
    localparam MOTOR_OFF = 1'b0;
    localparam MOTOR_ON  = 1'b1;
    
    // Lógica de transição
    always @(*) begin
        case (estado_atual)
            MOTOR_OFF: begin
                if (START && ROLHAS_DISPONIVEIS && !GARRAFA_PRESENTE)
                    estado_proximo = MOTOR_ON;
                else
                    estado_proximo = MOTOR_OFF;
            end
            
            MOTOR_ON: begin
                if (START && ROLHAS_DISPONIVEIS && GARRAFA_PRESENTE)
                    estado_proximo = MOTOR_ON;
                else
                    estado_proximo = MOTOR_OFF;
            end
        endcase
    end
    
    // Flip-flop de estado
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            estado_atual <= MOTOR_OFF;
        else
            estado_atual <= estado_proximo;
    end
    
    // Saída Moore
    assign MOTOR_ATIVO = (estado_atual == MOTOR_ON);

endmodule