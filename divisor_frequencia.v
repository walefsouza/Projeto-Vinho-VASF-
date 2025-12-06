module divisor_frequencia (
    input CLOCK,     // clock de entrada rápido
    input RESET,     // reset do contador
    output reg OUT   // clock de saída mais lento
);

    reg [24:0] counter;  // contador de 25 bits (ajuste conforme necessário)

    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            counter <= 0;
            OUT <= 0;
        end else begin
            if (counter == 25_000_000) begin  // Ajuste esse valor para obter a frequência desejada
                counter <= 0;
                OUT <= ~OUT;  // Alterna a saída
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
