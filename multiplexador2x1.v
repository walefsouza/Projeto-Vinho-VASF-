// Multiplexador 2x1 

module multiplexador2x1(S, Sel, A, B); 

	input Sel;
	input A, B;
	output S;

	wire nsel, and0, and1;

	not Not0 (nsel, Sel);
	and And0 (and0, A, nsel);
	and And1 (and1, B, Sel);
	or  Or0 (S, and0, and1);

endmodule