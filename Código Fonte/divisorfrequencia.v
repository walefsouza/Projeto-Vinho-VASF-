// ============================================
// DIVISOR DE FREQUÊNCIA 
// ============================================

module divisorfrequencia (
    output reg CLOCKOUT,   // Clock dividido 
    input CLOCKIN,         // Clock de entrada 
    input RESET            // RESET
);


    // Frequência de 5 Hz (10.000.000)

    localparam DIVISOR = 27'd10000000; 

    // Contador interno responsável pela divisão
    reg [26:0] contador;

    // -------------------------------------------------------
    // LÓGICA PRINCIPAL DO DIVISOR

    always @(posedge CLOCKIN or posedge RESET) begin

        if (RESET) begin
            contador  <= 27'd0;
            CLOCKOUT  <= 1'b0;

        end else begin

            // Ao atingir o divisor, reinicia o contador e alterna CLOCKOUT
            if (contador >= (DIVISOR - 1)) begin
                contador <= 27'd0;
                CLOCKOUT <= ~CLOCKOUT;
            end

            // Caso contrário apenas incrementa
            else begin
                contador <= contador + 1'b1;
            end
        end
    end

endmodule
