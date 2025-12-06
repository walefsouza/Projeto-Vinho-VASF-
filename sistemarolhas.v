/*// ============================================
// CONTROLADOR DE SISTEMA DE ROLHAS
// Integra contador, dispensador e lógica de reposição
// ============================================

module sistemarolhas (
    output [6:0] ROLHAS_DISPONIVEIS,    // Para HEX1-HEX0
    output [7:0] ESTOQUE_DISPENSADOR,   // Para LEDs ou HEX extra
    output ROLHAS_OK,                    // Flag para FSM Vedação
    output ALARME_SEM_ROLHA,            // LED de alerta
    output DISPENSADOR_ATIVO,           // LED dispensador
    input CLOCK,
    input RESET,
    input DECREMENTAR_ROLHA,            // Pulso da FSM Vedação
    input REPOR_MANUAL                  // Chave SW7
);

    wire nivel_baixo;
    wire contador_vazio;
    wire dispensador_vazio;
    wire reposicao_auto;
    wire reposicao_manual;
    wire reposicao_total;
    wire [6:0] valor_reposicao;
    
    // -------------------------------------------------------
    // 1. CONTADOR DE ROLHAS (0-99)
    // -------------------------------------------------------
    contadorrolhas cnt_rolhas (
        .COUNT(ROLHAS_DISPONIVEIS),
        .NIVEL_BAIXO(nivel_baixo),
        .VAZIO(contador_vazio),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .DECREMENTAR(DECREMENTAR_ROLHA),
        .INCREMENTAR(reposicao_total),
        .VALOR_CARGA(valor_reposicao)
    );
    
    // -------------------------------------------------------
    // 2. DISPENSADOR FÍSICO (0-255)
    // -------------------------------------------------------
    dispensadorrolhas disp (
        .COUNT(ESTOQUE_DISPENSADOR),
        .VAZIO(dispensador_vazio),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .REPOSICAO(reposicao_total),
        .QUANTIDADE(valor_reposicao)
    );
    
    // -------------------------------------------------------
    // 3. LÓGICA DE REPOSIÇÃO AUTOMÁTICA
    // -------------------------------------------------------
    // Ativa quando: contador <= 5 E dispensador não vazio
    wire not_disp_vazio;
    not NotDispVazio (not_disp_vazio, dispensador_vazio);
    and AndRepoAuto (reposicao_auto, nivel_baixo, not_disp_vazio);
    
    // -------------------------------------------------------
    // 4. LÓGICA DE REPOSIÇÃO MANUAL
    // -------------------------------------------------------
    // Debounce da chave SW7 (simplificado)
    reg repor_manual_sync;
    reg repor_manual_prev;
    wire repor_manual_edge;
    
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            repor_manual_sync <= 1'b0;
            repor_manual_prev <= 1'b0;
        end else begin
            repor_manual_sync <= REPOR_MANUAL;
            repor_manual_prev <= repor_manual_sync;
        end
    end
    
    // Detecta borda de subida
    wire not_prev;
    not NotPrev (not_prev, repor_manual_prev);
    and AndEdge (repor_manual_edge, repor_manual_sync, not_prev);
    and AndRepoManual (reposicao_manual, repor_manual_edge, not_disp_vazio);
    
    // -------------------------------------------------------
    // 5. SELEÇÃO DE VALOR E DISPARO
    // -------------------------------------------------------
    // reposicao_auto: adiciona 15
    // reposicao_manual: adiciona 1
    or OrRepoTotal (reposicao_total, reposicao_auto, reposicao_manual);
    
    // Valor = 15 se auto, 1 se manual
    // 15 = 0001111, 1 = 0000001
    wire [6:0] valor_auto = 7'b0001111;   // 15
    wire [6:0] valor_manual = 7'b0000001; // 1
    
    multiplexador2x1 MuxVal0 (.S(valor_reposicao[0]), .Sel(reposicao_auto), .A(valor_manual[0]), .B(valor_auto[0]));
    multiplexador2x1 MuxVal1 (.S(valor_reposicao[1]), .Sel(reposicao_auto),
                              .A(valor_manual[1]), .B(valor_auto[1]));
    multiplexador2x1 MuxVal2 (.S(valor_reposicao[2]), .Sel(reposicao_auto),
                              .A(valor_manual[2]), .B(valor_auto[2]));
    multiplexador2x1 MuxVal3 (.S(valor_reposicao[3]), .Sel(reposicao_auto),
                              .A(valor_manual[3]), .B(valor_auto[3]));
    multiplexador2x1 MuxVal4 (.S(valor_reposicao[4]), .Sel(reposicao_auto),
                              .A(valor_manual[4]), .B(valor_auto[4]));
    multiplexador2x1 MuxVal5 (.S(valor_reposicao[5]), .Sel(reposicao_auto),
                              .A(valor_manual[5]), .B(valor_auto[5]));
    multiplexador2x1 MuxVal6 (.S(valor_reposicao[6]), .Sel(reposicao_auto),
                              .A(valor_manual[6]), .B(valor_auto[6]));
    
    // -------------------------------------------------------
    // 6. SAÍDAS DE STATUS
    // -------------------------------------------------------
    wire not_contador_vazio;
    not NotContVazio (not_contador_vazio, contador_vazio);
    assign ROLHAS_OK = not_contador_vazio;
    
    assign ALARME_SEM_ROLHA = contador_vazio;
    assign DISPENSADOR_ATIVO = reposicao_auto;

endmodule*/