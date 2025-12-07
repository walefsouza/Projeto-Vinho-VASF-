// ============================================
// PARÂMETROS GLOBAIS CONFIGURÁVEIS
// ============================================
`define CAPACIDADE_DISPENSADOR 150  // Altere aqui conforme necessário
`define ROLHAS_POR_RECARGA 15       // Quantidade transferida por vez
`define LIMITE_MINIMO_LINHA 5       // Quando aciona recarga automática


// ============================================
// LEVEL TO PULSE SIMPLES
// ============================================
module level_to_pulse (
    output PULSE,
    input CLOCK,
    input RESET,
    input LEVEL
);
    reg level_anterior;
    
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            level_anterior <= 1'b0;
        else
            level_anterior <= LEVEL;
    end
    
    // Pulso na transição 0→1
    assign PULSE = LEVEL && !level_anterior;
endmodule


// ============================================
// DISPENSADOR SIMPLES (Apenas Registrador + Lógica)
// ============================================
module dispensador (
    output reg [7:0] ESTOQUE,           // Rolhas disponíveis no dispensador
    output reg DISPENSADOR_ATIVO,       // LED indicador
    output reg LOAD_CONTADOR,           // Sinal de carga para contador
    output reg [6:0] VALOR_CARGA,       // Valor a carregar no contador
    input [6:0] COUNT_ATUAL,            // Valor atual do contador de rolhas
    input PULSO_ADICIONA_MANUAL,        // Do level_to_pulse (SW7)
    input CLOCK,
    input RESET
);
    localparam [7:0] CAPACIDADE = `CAPACIDADE_DISPENSADOR;
    localparam [6:0] QTD_RECARGA = `ROLHAS_POR_RECARGA;
    localparam [6:0] LIMITE_MIN = `LIMITE_MINIMO_LINHA;
    
    // Sinais auxiliares
    wire precisa_recarga;
    wire tem_estoque;
    wire [7:0] transferencia_auto;
    wire [7:0] novo_valor_auto;
    
    // Detecções
    assign precisa_recarga = (COUNT_ATUAL <= LIMITE_MIN);
    assign tem_estoque = (ESTOQUE > 8'd0);
    
    // Calcula transferência automática (15 ou o que tiver)
    assign transferencia_auto = (ESTOQUE >= QTD_RECARGA) ? QTD_RECARGA : ESTOQUE;
    
    // Novo valor do contador após recarga
    assign novo_valor_auto = {1'b0, COUNT_ATUAL} + transferencia_auto;
    
    // -------------------------------------------------------
    // LÓGICA PRINCIPAL (Síncrono)
    // -------------------------------------------------------
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            ESTOQUE <= CAPACIDADE;
            DISPENSADOR_ATIVO <= 1'b0;
            LOAD_CONTADOR <= 1'b0;
            VALOR_CARGA <= 7'd0;
            
        end else begin
            // Padrão: desliga tudo
            DISPENSADOR_ATIVO <= 1'b0;
            LOAD_CONTADOR <= 1'b0;
            
            // -----------------------------------------------
            // CONDIÇÃO 1: Recarga Automática (Prioridade)
            // -----------------------------------------------
            if (precisa_recarga && tem_estoque) begin
                // Ativa LED
                DISPENSADOR_ATIVO <= 1'b1;
                
                // Ativa carga no contador
                LOAD_CONTADOR <= 1'b1;
                
                // Limita a 99
                if (novo_valor_auto > 8'd99)
                    VALOR_CARGA <= 7'd99;
                else
                    VALOR_CARGA <= novo_valor_auto[6:0];
                
                // Decrementa estoque
                ESTOQUE <= ESTOQUE - transferencia_auto;
            end
            
            // -----------------------------------------------
            // CONDIÇÃO 2: Adição Manual (SW7)
            // -----------------------------------------------
            else if (PULSO_ADICIONA_MANUAL && tem_estoque && (COUNT_ATUAL < 7'd99)) begin
                // Ativa LED
                DISPENSADOR_ATIVO <= 1'b1;
                
                // Ativa carga no contador
                LOAD_CONTADOR <= 1'b1;
                
                // Adiciona apenas 1 rolha
                VALOR_CARGA <= COUNT_ATUAL + 7'd1;
                
                // Decrementa 1 do estoque
                ESTOQUE <= ESTOQUE - 8'd1;
            end
        end
    end
    
endmodule


// ============================================
// SISTEMA COMPLETO DE ROLHAS
// ============================================
module sistema_rolhas (
    output [6:0] COUNT_ROLHAS,
    output [7:0] ESTOQUE_DISPENSADOR,
    output DISPENSADOR_ATIVO,
    output ALARME_SEM_ROLHA,
    input CLOCK,
    input RESET,
    input DECREMENTA_ROLHA,       // Pulso da FSM Vedação
    input SW7                     // Chave física
);
    // Sinais internos
    wire LOAD_ROLHAS;
    wire [6:0] VALOR_CARGA;
    wire ZERO;
    wire pulso_adiciona;
    wire dispensador_vazio;
    
    // -------------------------------------------------------
    // LEVEL TO PULSE para SW7
    // -------------------------------------------------------
    level_to_pulse L2P_SW7 (
        .PULSE(pulso_adiciona),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .LEVEL(SW7)
    );
    
    // -------------------------------------------------------
    // CONTADOR DE ROLHAS (Seu módulo estrutural)
    // -------------------------------------------------------
    contadorrolhas CONTADOR (
        .COUNT(COUNT_ROLHAS),
        .ZERO(ZERO),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .LOAD(LOAD_ROLHAS),
        .ENABLE(DECREMENTA_ROLHA),
        .DADOS(VALOR_CARGA)
    );
    
    // -------------------------------------------------------
    // DISPENSADOR (Novo módulo simplificado)
    // -------------------------------------------------------
    dispensador DISP (
        .ESTOQUE(ESTOQUE_DISPENSADOR),
        .DISPENSADOR_ATIVO(DISPENSADOR_ATIVO),
        .LOAD_CONTADOR(LOAD_ROLHAS),
        .VALOR_CARGA(VALOR_CARGA),
        .COUNT_ATUAL(COUNT_ROLHAS),
        .PULSO_ADICIONA_MANUAL(pulso_adiciona),
        .CLOCK(CLOCK),
        .RESET(RESET)
    );
    
    // -------------------------------------------------------
    // ALARME: Sem rolhas na linha E no dispensador
    // -------------------------------------------------------
    assign dispensador_vazio = (ESTOQUE_DISPENSADOR == 8'd0);
    assign ALARME_SEM_ROLHA = ZERO && dispensador_vazio;
    
endmodule


// ============================================
// SISTEMA DE GARRAFAS E DÚZIAS
// ============================================
module sistema_garrafas (
    output [3:0] COUNT_GARRAFAS,
    output [3:0] COUNT_DUZIAS,
    output LIMITE_DUZIAS,
    input CLOCK,
    input RESET,
    input INCREMENTA_GARRAFA
);
    wire DUZIA_COMPLETA;
    wire [3:0] count_garrafas_interno;
    
    // Contador de Garrafas (0-12)
    contadorgarrafas CONT_GARRAFAS (
        .DUZIA_COMPLETA(DUZIA_COMPLETA),
        .COUNT(count_garrafas_interno),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .ENABLE(INCREMENTA_GARRAFA)
    );
    
    assign COUNT_GARRAFAS = count_garrafas_interno;
    
    // Contador de Dúzias (0-10)
    contadorduzias CONT_DUZIAS (
        .COUNT(COUNT_DUZIAS),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .ENABLE(DUZIA_COMPLETA)
    );
    
    // Detecção de 10 dúzias (1010 binário)
    wire notQ2, notQ0;
    not NotQ2 (notQ2, COUNT_DUZIAS[2]);
    not NotQ0 (notQ0, COUNT_DUZIAS[0]);
    and AndLimite (LIMITE_DUZIAS, COUNT_DUZIAS[3], notQ2, COUNT_DUZIAS[1], notQ0);
    
endmodule
