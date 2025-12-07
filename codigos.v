// ============================================
// PARÂMETROS GLOBAIS CONFIGURÁVEIS
// ============================================
`define CAPACIDADE_DISPENSADOR 150  // Altere aqui conforme necessário
`define ROLHAS_POR_RECARGA 15       // Quantidade transferida por vez
`define LIMITE_MINIMO_LINHA 5       // Quando aciona recarga automática
`define LIMITE_MAXIMO_LINHA 99      // Capacidade máxima do contador

// ============================================
// DISPENSADOR DE ROLHAS (Reservatório Finito)
// ============================================
module dispensador_reservatorio (
    output reg [7:0] ESTOQUE_DISP,        // Rolhas disponíveis no dispensador
    output DISPENSADOR_VAZIO,             // Flag: sem rolhas no dispensador
    output DISPENSADOR_ATIVO,             // LED indicador
    input CLOCK,
    input RESET,
    input SOLICITA_RECARGA,               // Pedido de transferência
    input [7:0] QUANTIDADE_SOLICITADA     // Quanto transferir
);
    localparam [7:0] CAPACIDADE = `CAPACIDADE_DISPENSADOR;
    
    reg transferindo;
    reg [7:0] quantidade_a_transferir;
    
    // -------------------------------------------------------
    // LÓGICA DE TRANSFERÊNCIA
    // -------------------------------------------------------
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            ESTOQUE_DISP <= CAPACIDADE;  // Inicia cheio
            transferindo <= 1'b0;
            quantidade_a_transferir <= 8'd0;
        end else begin
            if (SOLICITA_RECARGA && !transferindo && ESTOQUE_DISP > 0) begin
                // Inicia transferência
                transferindo <= 1'b1;
                
                // Transfere o que foi pedido OU o que tem disponível
                if (QUANTIDADE_SOLICITADA <= ESTOQUE_DISP)
                    quantidade_a_transferir <= QUANTIDADE_SOLICITADA;
                else
                    quantidade_a_transferir <= ESTOQUE_DISP;
                    
            end else if (transferindo) begin
                // Conclui transferência
                ESTOQUE_DISP <= ESTOQUE_DISP - quantidade_a_transferir;
                transferindo <= 1'b0;
            end
        end
    end
    
    // -------------------------------------------------------
    // SAÍDAS
    // -------------------------------------------------------
    assign DISPENSADOR_VAZIO = (ESTOQUE_DISP == 8'd0);
    assign DISPENSADOR_ATIVO = transferindo;
    
endmodule

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
// CONTROLADOR SIMPLES DO DISPENSADOR
// Apenas lógica combinacional + registradores
// ============================================
module controlador_dispensador (
    output reg [7:0] ESTOQUE_DISPENSADOR,
    output [6:0] VALOR_CARGA_CONTADOR,
    output LOAD_CONTADOR,
    output ROLHAS_DISPONIVEIS,
    output ALARME_SEM_ROLHA,
    output DISPENSADOR_ATIVO,
    input [6:0] COUNT_ATUAL,
    input CLOCK,
    input RESET,
    input PULSO_ADICIONA_MANUAL,      // Já vem do L2P
    input DECREMENTA_ROLHA            // Pulso da FSM Vedação
);
    localparam [7:0] CAPACIDADE = `CAPACIDADE_DISPENSADOR;
    localparam [6:0] QTD_RECARGA = `ROLHAS_POR_RECARGA;
    localparam [6:0] LIMITE_MIN = `LIMITE_MINIMO_LINHA;
    localparam [6:0] LIMITE_MAX = `LIMITE_MAXIMO_LINHA;
    
    // -------------------------------------------------------
    // DETECÇÕES (Lógica Combinacional)
    // -------------------------------------------------------
    wire precisa_recarga_auto;
    wire pode_adicionar;
    wire dispensador_vazio;
    wire contador_vazio;
    
    assign precisa_recarga_auto = (COUNT_ATUAL <= LIMITE_MIN);
    assign pode_adicionar = (COUNT_ATUAL < LIMITE_MAX);
    assign dispensador_vazio = (ESTOQUE_DISPENSADOR == 8'd0);
    assign contador_vazio = (COUNT_ATUAL == 7'd0);
    
    assign ROLHAS_DISPONIVEIS = !contador_vazio;
    assign ALARME_SEM_ROLHA = contador_vazio && dispensador_vazio;
    
    // -------------------------------------------------------
    // SINAIS DE CONTROLE
    // -------------------------------------------------------
    wire aciona_recarga_auto;
    wire aciona_adicao_manual;
    
    assign aciona_recarga_auto = precisa_recarga_auto && 
                                 !dispensador_vazio && 
                                 pode_adicionar;
    
    assign aciona_adicao_manual = PULSO_ADICIONA_MANUAL && 
                                  pode_adicionar;
    
    // Qualquer ação de carga
    assign LOAD_CONTADOR = aciona_recarga_auto || aciona_adicao_manual;
    assign DISPENSADOR_ATIVO = LOAD_CONTADOR;
    
    // -------------------------------------------------------
    // CÁLCULO DO VALOR A CARREGAR
    // -------------------------------------------------------
    wire [7:0] count_mais_recarga;
    wire [7:0] count_mais_1;
    wire [7:0] novo_valor_temp;
    
    assign count_mais_recarga = {1'b0, COUNT_ATUAL} + {1'b0, QTD_RECARGA};
    assign count_mais_1 = {1'b0, COUNT_ATUAL} + 8'd1;
    
    // Escolhe qual operação
    assign novo_valor_temp = aciona_recarga_auto ? count_mais_recarga : count_mais_1;
    
    // Limita a 99
    assign VALOR_CARGA_CONTADOR = (novo_valor_temp > LIMITE_MAX) ? 
                                   LIMITE_MAX : 
                                   novo_valor_temp[6:0];
    
    // -------------------------------------------------------
    // ATUALIZAÇÃO DO ESTOQUE DO DISPENSADOR
    // -------------------------------------------------------
    wire [7:0] quantidade_transferida;
    
    // Calcula quanto será transferido
    assign quantidade_transferida = aciona_recarga_auto ? 
                                    (QTD_RECARGA > ESTOQUE_DISPENSADOR ? 
                                     ESTOQUE_DISPENSADOR : 
                                     QTD_RECARGA) : 
                                    (aciona_adicao_manual ? 8'd1 : 8'd0);
    
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET)
            ESTOQUE_DISPENSADOR <= CAPACIDADE;
        else if (LOAD_CONTADOR)
            ESTOQUE_DISPENSADOR <= ESTOQUE_DISPENSADOR - quantidade_transferida;
    end
    
endmodule


// ============================================
// SISTEMA COMPLETO DE ROLHAS (SIMPLIFICADO)
// ============================================
module sistema_rolhas (
    output [6:0] COUNT_ROLHAS,
    output [7:0] ESTOQUE_DISPENSADOR,
    output ROLHAS_DISPONIVEIS,
    output DISPENSADOR_ATIVO,
    output ALARME_SEM_ROLHA,
    input CLOCK,
    input RESET,
    input DECREMENTA_ROLHA,       // Pulso da FSM Vedação
    input SW7                     // Chave física (sem debouncer!)
);
    // Sinais internos
    wire LOAD_ROLHAS;
    wire [6:0] VALOR_CARGA;
    wire ZERO;
    wire pulso_adiciona;
    
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
    // CONTADOR DE ROLHAS
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
    // CONTROLADOR SIMPLIFICADO
    // -------------------------------------------------------
    controlador_dispensador CONTROLADOR (
        .ESTOQUE_DISPENSADOR(ESTOQUE_DISPENSADOR),
        .VALOR_CARGA_CONTADOR(VALOR_CARGA),
        .LOAD_CONTADOR(LOAD_ROLHAS),
        .ROLHAS_DISPONIVEIS(ROLHAS_DISPONIVEIS),
        .ALARME_SEM_ROLHA(ALARME_SEM_ROLHA),
        .DISPENSADOR_ATIVO(DISPENSADOR_ATIVO),
        .COUNT_ATUAL(COUNT_ROLHAS),
        .CLOCK(CLOCK),
        .RESET(RESET),
        .PULSO_ADICIONA_MANUAL(pulso_adiciona),
        .DECREMENTA_ROLHA(DECREMENTA_ROLHA)
    );
    
endmodule


// ============================================
// SISTEMA DE GARRAFAS E DÚZIAS (Mantido igual)
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
