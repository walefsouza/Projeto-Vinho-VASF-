// ============================================
// TOP-LEVEL VINHOVASF
// Sistema de Automação de Envase de Garrafas
// ============================================

module vinhovasfTOP (
    // ===== ENTRADAS DA PLACA =====
    input CLOCK_50,           // Clock 50MHz da placa
    input [1:0] KEY,          // KEY[0]=START/STOP, KEY[1]=RESET
    input [9:0] SW,           // Chaves
    
    // ===== SAÍDAS DA PLACA =====
    output [9:0] LEDR,        // LEDs de status
    output [6:0] HEX0,        // Display unidade rolhas
    output [6:0] HEX1,        // Display dezena rolhas
    output [6:0] HEX2,        // Display unidade dúzias
    output [6:0] HEX3,        // Display dezena dúzias
    output [6:0] HEX4,        // Display unidade garrafas
    output [6:0] HEX5         // Display dezena garrafas
);

    // =========================================================================
    // SINAIS DE CONTROLE GLOBAL

    wire reset_global;             // Reset do sistema
    wire clock_sistema;            // Clock dividido (1Hz para visualização)
    wire pulso_start;              // Pulso do botão START
    wire start_ativo;              // Flag START (0=PARADO, 1=RODANDO)
    wire pulso_adiciona_manual;    // Pulso SW[7] (adicionar rolha)
    
    // =========================================================================
    // SINAIS DAS FSMs

    wire MotorATIVO;               // Motor da esteira ligado
    wire VALVULA_EV;               // Válvula de enchimento ativa
    wire GaCheia;                  // Flag: garrafa enchida
    wire GaVedada;                 // Flag: garrafa vedada
    wire DecrementarRolha;         // Pulso para decrementar contador rolhas
    wire Lacre;               	   // Flag: passou controle qualidade
	wire Descarte;                // Flag: nao passou controle qualidade
    wire IncrementarGarrafa;       // Pulso para incrementar contador garrafas
	wire EmInspecao;
	
    // =========================================================================
    // SINAIS DOS CONTADORES

    wire [3:0] COUNT_GA;           // Contador garrafas 0-12
    wire [3:0] COUNT_DU;           // Contador dúzias 0-10
    wire [6:0] COUNT_RO;           // Contador rolhas 0-99
    wire DuziaCompleta;            // Pulso: completou 12 garrafas
    wire ZERO;                     // Flag: contador rolhas = 0
    
    // =========================================================================
    // SINAIS DO DISPENSADOR
	
    wire [7:0] ESTOQUE;            // Rolhas no dispensador (0-150)
    wire DispensadorATIVO;         // LED dispensador ativo
    wire LOAD_CONTADOR;            // Sinal LOAD do contador
    wire [6:0] VALOR_CARGA;        // Valor a carregar no contador
    wire ROlhasDisponiveis;        // Flag: tem rolhas na linha
    wire SEMROLHAS;                // Alarme: sem rolhas
    
    // =========================================================================
    // SINAIS DE SENSORES (Simulados com Chaves)

    wire GARRAFA_PRESENTE;         // SW[0]: Garrafa na posição
    wire SENSOR_NIVEL;             // SW[1]: Nível cheio detectado
    wire GA_APROVADA;         // SW[2]: Qualidade OK
	wire GA_REPROVADA;
	
	wire PulsoAprovada;
	wire PulsoReprovada;
    
	assign GARRAFA_PRESENTE = SW[0];
	assign SENSOR_NIVEL = SW[1];
	assign GA_APROVADA = SW[2];
	assign GA_REPROVADA = SW[3];
    
    // =========================================================================
    // 1. CONTROLE DE ENTRADAS
    
    // RESET 
    assign reset_global = !KEY[1];
    
    // DIVISOR DE CLOCK (50MHz para 5Hz)
    divisorfrequencia DIVISORCLOCK (
        .CLOCKOUT(clock_sistema),
        .CLOCKIN(CLOCK_50),
        .RESET(reset_global)
    );
    
    // BOTÃO START/STOP (KEY[0])
    botaosincronizado BOTAOSTART (
        .entrada(KEY[0]),               
        .saida(pulso_start),            
        .CLOCK(CLOCK_50),               
        .RESET(reset_global)
    );
    
    // TOGGLE START/STOP (0=PARADO, 1=RODANDO)
    contadortoggle STARTouSTOP (
        .Q(start_ativo),
        .PULSO(pulso_start),
        .CLOCK(CLOCK_50),
        .RESET(reset_global)
    );
    
    // LEVEL TO PULSE (ADD ROLHAS MANUAL, APROVADA, REPROVADA)
    leveltopulse LevelRolha (
        .PULSE(pulso_adiciona_manual),
        .CLOCK(clock_sistema),              
        .RESET(reset_global),
        .LEVEL(SW[7])
    );

    leveltopulse LevelAprovada (
        .PULSE(PulsoAprovada),
        .CLOCK(clock_sistema),               
        .RESET(reset_global),
        .LEVEL(SW[2])
    );

    leveltopulse LevelREprovada (
        .PULSE(PulsoReprovada),
        .CLOCK(clock_sistema),               
        .RESET(reset_global),
        .LEVEL(SW[3])
    );
    
    // =========================================================================
    // 2. MÁQUINAS DE ESTADOS 

    // FSM MOTOR
	fsm_motor MOTOR (
        .MOTOR_ATIVO(MotorATIVO),
        .CLOCK(clock_sistema),
        .RESET(reset_global || !start_ativo),
        .START(start_ativo),
        .ROLHAS_DISPONIVEIS(ROlhasDisponiveis),
        .GARRAFA_PRESENTE(GARRAFA_PRESENTE),
        .PROCESSO_ATIVO(GaCheia || GaVedada || EmInspecao)
	);
    
    // FSM ENCHIMENTO
    fsm_enchimento ENCHIMENTO (
        .VALVULA_EV(VALVULA_EV),
        .GARRAFA_CHEIA(GaCheia),
        .CLOCK(clock_sistema),              
        .RESET(reset_global || !start_ativo),
        .GARRAFA_PRESENTE(GARRAFA_PRESENTE),
        .SENSOR_NIVEL(SENSOR_NIVEL)
    );
    
    // FSM VEDAÇÃO
    fsm_vedacao VEDACAO (
        .GARRAFA_VEDADA(GaVedada),
        .DECREMENTA_ROLHA(DecrementarRolha),
        .CLOCK(clock_sistema),              
        .RESET(reset_global || !start_ativo),
		.GARRAFA_CHEIA(GaCheia),
        .GARRAFA_PRESENTE(GARRAFA_PRESENTE),
        .ROLHAS_DISPONIVEIS(ROlhasDisponiveis)
    );

    // FSM QUALIDADE
	fsm_qualidade CONTROLEdeQ(
        .DESCARTE(Descarte),
        .LACRE(Lacre),
        .INCREMENTA_GARRAFA(IncrementarGarrafa),
        .EM_INSPECAO(EmInspecao),
        .CLOCK(clock_sistema),
        .RESET(reset_global || !start_ativo),
        .GARRAFA_ENCHIMENTO(GARRAFA_PRESENTE),
        .GARRAFA_VEDADA(GaVedada),
        .PULSO_APROVADA(PulsoAprovada),
        .PULSO_REPROVADA(PulsoReprovada)
	); 
    // =========================================================================
    // 3. CONTADORES
    
    // CONTADOR DE GARRAFAS (0-12)
    contadorgarrafas CONTGARRAFAS (
        .DUZIA_COMPLETA(DuziaCompleta),
        .COUNT(COUNT_GA),
        .CLOCK(clock_sistema),             
        .RESET(reset_global),
        .ENABLE(IncrementarGarrafa && start_ativo)
    );
    
    // CONTADOR DE DÚZIAS (0-10)
    contadorduzias CONTDUZIAS (
        .COUNT(COUNT_DU),
        .CLOCK(clock_sistema),              
        .RESET(reset_global),
        .ENABLE(DuziaCompleta && start_ativo)
    );
    
    // CONTADOR DE ROLHAS (20-0)
    contadorrolhas CONTROLHAS (
        .COUNT(COUNT_RO),
        .ZERO(ZERO),
        .CLOCK(clock_sistema),              
        .RESET(reset_global),
        .LOAD(LOAD_CONTADOR),
        .ENABLE(DecrementarRolha && start_ativo),
        .DADOS(VALOR_CARGA)
    );
    
    // =========================================================================
    // 4. DISPENSADOR DE ROLHAS

    dispensadorrolhas DISPENSADOR (
        .ESTOQUE(ESTOQUE),
        .DISPENSADOR_ATIVO(DispensadorATIVO),
        .LOAD_CONTADOR(LOAD_CONTADOR),
        .VALOR_CARGA(VALOR_CARGA),
        .COUNT_ATUAL(COUNT_RO),
        .ADDROLHASMANUAL(pulso_adiciona_manual),
        .CLOCK(clock_sistema),              
        .RESET(reset_global)
    );
    
    // Lógica do alarme e disponibilidade
    assign ROlhasDisponiveis = !ZERO;
    assign SEMROLHAS = ZERO && (ESTOQUE == 8'd0);
    
    // =========================================================================
    // 5. DISPLAYS 7 SEGMENTOS
    
    sistemadisplays DISPLAYS (
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .COUNT_GARRAFAS(COUNT_GA),
        .COUNT_DUZIAS(COUNT_DU),
        .COUNT_ROLHAS(COUNT_RO)
    );
    
    // =========================================================================
    // 6. LEDS DE STATUS

	assign LEDR[9] = start_ativo;           // Sistema rodando
    assign LEDR[8] = (COUNT_DU == 4'd10);   // 10 dúzias alcançadas
    assign LEDR[7] = 1'b0;                  // Reservado
    assign LEDR[6] = Descarte;              // Garrafa descartada
    assign LEDR[5] = DispensadorATIVO;      // Dispensador ativo
    assign LEDR[4] = Lacre;                 // Qualidade OK
    assign LEDR[3] = GaVedada;              // Vedada
    assign LEDR[2] = VALVULA_EV;            // Enchendo
    assign LEDR[1] = MotorATIVO;            // Motor Ativo
    assign LEDR[0] = SEMROLHAS;             // Sem rolhas 

endmodule
