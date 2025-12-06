// ====================================================================
// CONVERSOR BINÁRIO PARA BCD COM ALGORITMO DOUBLE DABBLE
// ====================================================================

module doubledabble7bits (Dezenas, Unidades, Binario);

	input [6:0] Binario;
	output [3:0] Dezenas;
	output [3:0] Unidades;

	// Wires para armazenar valores intermediários após cada estágio
	wire [3:0] dez0, dez1, dez2, dez3, dez4, dez5, dez6;
	wire [3:0] uni0, uni1, uni2, uni3, uni4, uni5, uni6;

	// Wires para valores corrigidos (após adicionar +3 se >= 5)
	wire [3:0] dez_corr1, dez_corr2, dez_corr3, dez_corr4, dez_corr5, dez_corr6, dez_corr0;
	wire [3:0] uni_corr1, uni_corr2, uni_corr3, uni_corr4, uni_corr5, uni_corr6, uni_corr0;

	wire GND;
	or OrGND(GND, 1'b0, 1'b0);

	// ========== ESTÁGIO 0: Inicialização ==========
	// Dezenas = 0000, Unidades = 0000
	
	or OrDez0_3(dez0[3], GND, GND);
	or OrDez0_2(dez0[2], GND, GND);
	or OrDez0_1(dez0[1], GND, GND);
	or OrDez0_0(dez0[0], GND, GND);

	or OrUni0_3(uni0[3], GND, GND);
	or OrUni0_2(uni0[2], GND, GND);
	or OrUni0_1(uni0[1], GND, GND);
	or OrUni0_0(uni0[0], GND, GND);

	// ========== ESTÁGIO 1: Corrige + Shift ==========
	corretor4x4BCD CorDez1 (.Saida(dez_corr1), .Entrada(dez0));
	corretor4x4BCD CorUni1 (.Saida(uni_corr1), .Entrada(uni0));

	multiplexador2x1 MuxD1_3 (.S(dez1[3]), .Sel(1'b1), .A(GND), .B(dez_corr1[2]));
	multiplexador2x1 MuxD1_2 (.S(dez1[2]), .Sel(1'b1), .A(GND), .B(dez_corr1[1]));
	multiplexador2x1 MuxD1_1 (.S(dez1[1]), .Sel(1'b1), .A(GND), .B(dez_corr1[0]));
	multiplexador2x1 MuxD1_0 (.S(dez1[0]), .Sel(1'b1), .A(GND), .B(uni_corr1[3]));

	multiplexador2x1 MuxU1_3 (.S(uni1[3]), .Sel(1'b1), .A(GND), .B(uni_corr1[2]));
	multiplexador2x1 MuxU1_2 (.S(uni1[2]), .Sel(1'b1), .A(GND), .B(uni_corr1[1]));
	multiplexador2x1 MuxU1_1 (.S(uni1[1]), .Sel(1'b1), .A(GND), .B(uni_corr1[0]));
	multiplexador2x1 MuxU1_0 (.S(uni1[0]), .Sel(1'b1), .A(GND), .B(Binario[6]));

	// ========== ESTÁGIO 2: Corrige + Shift ==========
	corretor4x4BCD CorDez2 (.Saida(dez_corr2), .Entrada(dez1));
	corretor4x4BCD CorUni2 (.Saida(uni_corr2), .Entrada(uni1));

	multiplexador2x1 MuxD2_3 (.S(dez2[3]), .Sel(1'b1), .A(GND), .B(dez_corr2[2]));
	multiplexador2x1 MuxD2_2 (.S(dez2[2]), .Sel(1'b1), .A(GND), .B(dez_corr2[1]));
	multiplexador2x1 MuxD2_1 (.S(dez2[1]), .Sel(1'b1), .A(GND), .B(dez_corr2[0]));
	multiplexador2x1 MuxD2_0 (.S(dez2[0]), .Sel(1'b1), .A(GND), .B(uni_corr2[3]));

	multiplexador2x1 MuxU2_3 (.S(uni2[3]), .Sel(1'b1), .A(GND), .B(uni_corr2[2]));
	multiplexador2x1 MuxU2_2 (.S(uni2[2]), .Sel(1'b1), .A(GND), .B(uni_corr2[1]));
	multiplexador2x1 MuxU2_1 (.S(uni2[1]), .Sel(1'b1), .A(GND), .B(uni_corr2[0]));
	multiplexador2x1 MuxU2_0 (.S(uni2[0]), .Sel(1'b1), .A(GND), .B(Binario[5]));

	// ========== ESTÁGIO 3: Corrige + Shift ==========
	corretor4x4BCD CorDez3 (.Saida(dez_corr3), .Entrada(dez2));
	corretor4x4BCD CorUni3 (.Saida(uni_corr3), .Entrada(uni2));

	multiplexador2x1 MuxD3_3 (.S(dez3[3]), .Sel(1'b1), .A(GND), .B(dez_corr3[2]));
	multiplexador2x1 MuxD3_2 (.S(dez3[2]), .Sel(1'b1), .A(GND), .B(dez_corr3[1]));
	multiplexador2x1 MuxD3_1 (.S(dez3[1]), .Sel(1'b1), .A(GND), .B(dez_corr3[0]));
	multiplexador2x1 MuxD3_0 (.S(dez3[0]), .Sel(1'b1), .A(GND), .B(uni_corr3[3]));

	multiplexador2x1 MuxU3_3 (.S(uni3[3]), .Sel(1'b1), .A(GND), .B(uni_corr3[2]));
	multiplexador2x1 MuxU3_2 (.S(uni3[2]), .Sel(1'b1), .A(GND), .B(uni_corr3[1]));
	multiplexador2x1 MuxU3_1 (.S(uni3[1]), .Sel(1'b1), .A(GND), .B(uni_corr3[0]));
	multiplexador2x1 MuxU3_0 (.S(uni3[0]), .Sel(1'b1), .A(GND), .B(Binario[4]));

	// ========== ESTÁGIO 4: Corrige + Shift ==========
	corretor4x4BCD CorDez4 (.Saida(dez_corr4), .Entrada(dez3));
	corretor4x4BCD CorUni4 (.Saida(uni_corr4), .Entrada(uni3));

	multiplexador2x1 MuxD4_3 (.S(dez4[3]), .Sel(1'b1), .A(GND), .B(dez_corr4[2]));
	multiplexador2x1 MuxD4_2 (.S(dez4[2]), .Sel(1'b1), .A(GND), .B(dez_corr4[1]));
	multiplexador2x1 MuxD4_1 (.S(dez4[1]), .Sel(1'b1), .A(GND), .B(dez_corr4[0]));
	multiplexador2x1 MuxD4_0 (.S(dez4[0]), .Sel(1'b1), .A(GND), .B(uni_corr4[3]));

	multiplexador2x1 MuxU4_3 (.S(uni4[3]), .Sel(1'b1), .A(GND), .B(uni_corr4[2]));
	multiplexador2x1 MuxU4_2 (.S(uni4[2]), .Sel(1'b1), .A(GND), .B(uni_corr4[1]));
	multiplexador2x1 MuxU4_1 (.S(uni4[1]), .Sel(1'b1), .A(GND), .B(uni_corr4[0]));
	multiplexador2x1 MuxU4_0 (.S(uni4[0]), .Sel(1'b1), .A(GND), .B(Binario[3]));

	// ========== ESTÁGIO 5: Corrige + Shift ==========
	corretor4x4BCD CorDez5 (.Saida(dez_corr5), .Entrada(dez4));
	corretor4x4BCD CorUni5 (.Saida(uni_corr5), .Entrada(uni4));

	multiplexador2x1 MuxD5_3 (.S(dez5[3]), .Sel(1'b1), .A(GND), .B(dez_corr5[2]));
	multiplexador2x1 MuxD5_2 (.S(dez5[2]), .Sel(1'b1), .A(GND), .B(dez_corr5[1]));
	multiplexador2x1 MuxD5_1 (.S(dez5[1]), .Sel(1'b1), .A(GND), .B(dez_corr5[0]));
	multiplexador2x1 MuxD5_0 (.S(dez5[0]), .Sel(1'b1), .A(GND), .B(uni_corr5[3]));

	multiplexador2x1 MuxU5_3 (.S(uni5[3]), .Sel(1'b1), .A(GND), .B(uni_corr5[2]));
	multiplexador2x1 MuxU5_2 (.S(uni5[2]), .Sel(1'b1), .A(GND), .B(uni_corr5[1]));
	multiplexador2x1 MuxU5_1 (.S(uni5[1]), .Sel(1'b1), .A(GND), .B(uni_corr5[0]));
	multiplexador2x1 MuxU5_0 (.S(uni5[0]), .Sel(1'b1), .A(GND), .B(Binario[2]));

	// ========== ESTÁGIO 6: Corrige + Shift ==========
	corretor4x4BCD CorDez6 (.Saida(dez_corr6), .Entrada(dez5));
	corretor4x4BCD CorUni6 (.Saida(uni_corr6), .Entrada(uni5));

	multiplexador2x1 MuxD6_3 (.S(dez6[3]), .Sel(1'b1), .A(GND), .B(dez_corr6[2]));
	multiplexador2x1 MuxD6_2 (.S(dez6[2]), .Sel(1'b1), .A(GND), .B(dez_corr6[1]));
	multiplexador2x1 MuxD6_1 (.S(dez6[1]), .Sel(1'b1), .A(GND), .B(dez_corr6[0]));
	multiplexador2x1 MuxD6_0 (.S(dez6[0]), .Sel(1'b1), .A(GND), .B(uni_corr6[3]));

	multiplexador2x1 MuxU6_3 (.S(uni6[3]), .Sel(1'b1), .A(GND), .B(uni_corr6[2]));
	multiplexador2x1 MuxU6_2 (.S(uni6[2]), .Sel(1'b1), .A(GND), .B(uni_corr6[1]));
	multiplexador2x1 MuxU6_1 (.S(uni6[1]), .Sel(1'b1), .A(GND), .B(uni_corr6[0]));
	multiplexador2x1 MuxU6_0 (.S(uni6[0]), .Sel(1'b1), .A(GND), .B(Binario[1]));

	// ========== ESTÁGIO 7 FINAL: Corrige + Shift ==========
	corretor4x4BCD CorDez7 (.Saida(dez_corr0), .Entrada(dez6));
	corretor4x4BCD CorUni7 (.Saida(uni_corr0), .Entrada(uni6));

	// Shift final + insere Binario[0]
	multiplexador2x1 MuxD7_3 (.S(Dezenas[3]), .Sel(1'b1), .A(GND), .B(dez_corr0[2]));
	multiplexador2x1 MuxD7_2 (.S(Dezenas[2]), .Sel(1'b1), .A(GND), .B(dez_corr0[1]));
	multiplexador2x1 MuxD7_1 (.S(Dezenas[1]), .Sel(1'b1), .A(GND), .B(dez_corr0[0]));
	multiplexador2x1 MuxD7_0 (.S(Dezenas[0]), .Sel(1'b1), .A(GND), .B(uni_corr0[3]));

	multiplexador2x1 MuxU7_3 (.S(Unidades[3]), .Sel(1'b1), .A(GND), .B(uni_corr0[2]));
	multiplexador2x1 MuxU7_2 (.S(Unidades[2]), .Sel(1'b1), .A(GND), .B(uni_corr0[1]));
	multiplexador2x1 MuxU7_1 (.S(Unidades[1]), .Sel(1'b1), .A(GND), .B(uni_corr0[0]));
	multiplexador2x1 MuxU7_0 (.S(Unidades[0]), .Sel(1'b1), .A(GND), .B(Binario[0]));

endmodule