module vinhovasfTOP (
    // ===== CLOCK E RESET =====
    input wire CLOCK_50,
    input wire [1:0] KEY,
    
    // ===== CHAVES =====
    input wire [9:0] SW,
    
    // ===== LEDs =====
    output wire [9:0] LEDR,
    
    // ===== DISPLAYS 7 SEGMENTOS =====
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    // ========================================
    // SINAIS DE CONTROLE
    // ========================================
    
    wire reset, start;
    assign reset = ~KEY[1];
    assign start = ~KEY[0];
    
    // ========================================
    // SINAIS DE COMUNICAÇÃO ENTRE FSMs
    // ========================================
    
    wire motor_ativo;
    wire garrafa_cheia;
    wire garrafa_vedada;
    wire garrafa_aprovada;
    wire decrementar_rolha;
    wire incrementar_duzia;
    wire rolhas_disponiveis;
    wire alarme_sem_rolha;
    wire dispensador_ativo;
    
    // ========================================
    // CONTADORES
    // ========================================
    
    wire [3:0] count_garrafas;
    wire [3:0] count_duzias;
    wire [6:0] count_rolhas;
    wire duzia_completa;
    
    // ========================================
    // SENSORES SIMULADOS
    // ========================================
    
    wire sensor_qualidade = SW[0];
    wire repor_manual = SW[7];
    
    reg [2:0] posicao_garrafa;
    wire sensor_garrafa_motor = (posicao_garrafa == 3'd1);
    wire sensor_garrafa_enchimento = (posicao_garrafa == 3'd2);
    wire sensor_garrafa_vedacao = (posicao_garrafa == 3'd3);
    wire sensor_garrafa_cq = (posicao_garrafa == 3'd4);
    
    reg [25:0] contador_tempo;
    
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            posicao_garrafa <= 3'd0;
            contador_tempo <= 26'd0;
        end else begin
            if (contador_tempo >= 26'd50_000_000) begin
                contador_tempo <= 26'd0;
                if (start && motor_ativo) begin
                    case (posicao_garrafa)
                        3'd0: posicao_garrafa <= 3'd1;
                        3'd1: posicao_garrafa <= 3'd2;
                        3'd2: if (garrafa_cheia) posicao_garrafa <= 3'd3;
                        3'd3: if (garrafa_vedada) posicao_garrafa <= 3'd4;
                        3'd4: posicao_garrafa <= 3'd0;
                    endcase
                end
            end else begin
                contador_tempo <= contador_tempo + 26'd1;
            end
        end
    end
    
    // ========================================
    // INSTÂNCIAS DAS FSMs
    // ========================================
    
    fsm_motor fsm_mot (
        .MOTOR_ATIVO(motor_ativo),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .START(start),
        .ROLHAS_DISPONIVEIS(rolhas_disponiveis),
        .GARRAFA_PRESENTE(sensor_garrafa_motor)
    );
    
    fsm_enchimento fsm_ench (
        .GARRAFA_CHEIA(garrafa_cheia),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .GARRAFA_PRESENTE(sensor_garrafa_enchimento),
        .SENSOR_NIVEL(garrafa_cheia)
    );
    
    fsm_vedacao fsm_ved (
        .GARRAFA_VEDADA(garrafa_vedada),
        .DECREMENTA_ROLHA(decrementar_rolha),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .GARRAFA_PRESENTE(sensor_garrafa_vedacao),
        .ROLHAS_DISPONIVEIS(rolhas_disponiveis),
        .SENSOR_VEDACAO(garrafa_vedada)
    );
    
    fsm_qualidade fsm_cq (
        .GARRAFA_APROVADA(garrafa_aprovada),
        .INCREMENTA_DUZIA(incrementar_duzia),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .GARRAFA_PRESENTE(sensor_garrafa_cq),
        .SENSOR_QUALIDADE(sensor_qualidade),
        .GARRAFA_CHEIA(garrafa_cheia),
        .ATUADOR_VEDACAO_OK(garrafa_vedada),
        .GARRAFA_VEDADA(garrafa_vedada)
    );
    
    // ========================================
    // SISTEMA DE ROLHAS
    // ========================================
    
    sistemarolhas sys_rolhas (
        .ROLHAS_DISPONIVEIS(count_rolhas),
        .ESTOQUE_DISPENSADOR(),
        .ROLHAS_OK(rolhas_disponiveis),
        .ALARME_SEM_ROLHA(alarme_sem_rolha),
        .DISPENSADOR_ATIVO(dispensador_ativo),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .DECREMENTAR_ROLHA(decrementar_rolha),
        .REPOR_MANUAL(repor_manual)
    );
    
    // ========================================
    // CONTADORES DE PRODUÇÃO
    // ========================================
    
    contadorgarrafas cnt_garrafas (
        //.COUNT(count_garrafas),
        .DUZIA_COMPLETA(duzia_completa),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .ENABLE(incrementar_duzia)
    );
    
    contadorduzias cnt_duzias (
        .COUNT(count_duzias),
        .CLOCK(CLOCK_50),
        .RESET(reset),
        .ENABLE(duzia_completa)
    );
    
    // ========================================
    // SISTEMA DE DISPLAYS (MÓDULO ÚNICO!)
    // ========================================
    
    sistemadisplays displays (
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .count_garrafas(count_garrafas),
        .count_duzias(count_duzias),
        .count_rolhas(count_rolhas)
    );
    
    // ========================================
    // LEDs DE STATUS
    // ========================================
    
    assign LEDR[0] = alarme_sem_rolha;
    assign LEDR[1] = motor_ativo;
    assign LEDR[2] = garrafa_cheia;
    assign LEDR[3] = garrafa_vedada;
    assign LEDR[4] = garrafa_aprovada;
    assign LEDR[5] = dispensador_ativo;
    assign LEDR[9:6] = 4'b0000;

endmodule