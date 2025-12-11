// ==============================================================
// Módulo que tem como finalidade comparar se o valor é maior ou
// menor que 3. Ele é fundamental para o algoritímo double dabble.

module comparador4x4BCD(S, A);

	input [3:0] A;
	output S;

	wire and0, and1;
	//S = A2 A0 + A2 A1 + A3

	and And0(and0, A[2], A[0]);
	and And1(and1, A[2], A[1]);

	or OrFinalS(S, and0, and1, A[3]);

endmodule

// ==============================================================
// Somador Completo de um bit

module somadorbase (S, Co, A, B, Cin);

	input A, B, Cin;
	output S, Co;
	
	wire xor0, and0, and1;
	
	xor Xor0 (xor0, A, B);
	xor Xor1 (S, Cin, xor0);
	
	
	and And0 (and0, xor0, Cin);
	and And1 (and1, A, B);
	
	or Or0 (Co, and0, and1);
	
endmodule

// ==============================================================
// Somador 4x4 que soma 3 quando o valor deslocado for maior ou igual a 5

module somador4x4 (S, Co, A, B, Cin);

	input [3:0] A, B; 
	input Cin; 

	output [3:0] S;
	output Co;

	wire c1, c2, c3;

	// Instanciando o somador de 1 bit para cada bit
	somadorbase s0 (.A(A[0]), .B(B[0]), .Cin(Cin),  .S(S[0]), .Co(c1));
	somadorbase s1 (.A(A[1]), .B(B[1]), .Cin(c1),   .S(S[1]), .Co(c2));
	somadorbase s2 (.A(A[2]), .B(B[2]), .Cin(c2),   .S(S[2]), .Co(c3));
	somadorbase s3 (.A(A[3]), .B(B[3]), .Cin(c3),   .S(S[3]), .Co(Co));

endmodule


// ==============================================================
// Módulo que realiza a correção dos valores deslocados, seguindo
// a lógica do corretor e utilizando o somador4x4 e multiplexadores

module corretor4x4BCD(Saida, Entrada);
	
	input [3:0] Entrada;
	output [3:0] Saida;
	
	wire Sinal, carry;
	wire [3:0] vsomado;
	wire [3:0] tres;

	// --- Gerar Constantes 0 (GND) e 1 (VCC) Estruturalmente ---
	wire GND, VCC;
	or OrGND(GND, 1'b0, 1'b0); // GND = 0
	not NotVCC(VCC, GND);      // VCC = 1
	
	// --- Definir Constante 3 (0011) ---
	// Conecta tres[0] e tres[1] a VCC, tres[2] e tres[3] a GND
	or OrTres0(tres[0], VCC, GND); // tres[0] = 1 | 0 = 1
	or OrTres1(tres[1], VCC, GND); // tres[1] = 1 | 0 = 1
	or OrTres2(tres[2], GND, GND); // tres[2] = 0 | 0 = 0
	or OrTres3(tres[3], GND, GND); // tres[3] = 0 | 0 = 0

	comparador4x4BCD Comparador (.S(Sinal), .A(Entrada));
	somador4x4 Somando3 (.S(vsomado), .Co(carry), .A(Entrada), .B(tres), .Cin(1'b0));
	
	// --- Selecionar Saida com MUXes ---
	// Se sinal=0 (Entrada<5), seleciona A (Entrada).
	// Se sinal=1 (Entrada>=5), seleciona B (vsomado = Entrada+3).
	
	multiplexador2x1 Mux0 (.S(Saida[0]), .Sel(Sinal), .A(Entrada[0]), .B(vsomado[0]));
	multiplexador2x1 Mux1 (.S(Saida[1]), .Sel(Sinal), .A(Entrada[1]), .B(vsomado[1]));
	multiplexador2x1 Mux2 (.S(Saida[2]), .Sel(Sinal), .A(Entrada[2]), .B(vsomado[2]));
	multiplexador2x1 Mux3 (.S(Saida[3]), .Sel(Sinal), .A(Entrada[3]), .B(vsomado[3]));

endmodule