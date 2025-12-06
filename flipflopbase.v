// Módulo flip flop que armazena 1 bit de dados na borda de subida do clock.

module flipflopbase (Q, D, CLOCK, RESET);

	input D;
	input CLOCK;
	input RESET;
	output reg Q;

	// sensibilidade da borda de súbida do clock

	always @(posedge CLOCK) 
		begin
	
			if (RESET) 
				begin // condição de reset sincrono a ser checada no clock em nivel alto
						Q <= 1'b0; // zerando a saida
				end 
				
			else 
				begin
					Q <= D; // copiando entrada de dados
				end
		end
		
endmodule