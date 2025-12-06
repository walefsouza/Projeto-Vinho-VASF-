module dispensadorrolhas (
    output [7:0] ESTOQUE,      
    output VAZIO,             
    output [7:0] DISPENSADO,  
    input CLOCK,
    input RESET,
    input LOAD,               
    input ENABLE,             
    input [7:0] DADOS          
);

    wire [7:0] Qcount;
    wire [7:0] Qbar;
    wire [7:0] Sub15;          
    wire [7:0] ProxEstoque;    
    wire [7:0] Mux;
    wire Bout15;               
    wire EnableReal;          
    wire TemMaisDe15;          
    
    assign ESTOQUE = Qcount;

    flipflopbase FF0 (.Q(Qcount[0]), .D(Mux[0]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF1 (.Q(Qcount[1]), .D(Mux[1]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF2 (.Q(Qcount[2]), .D(Mux[2]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF3 (.Q(Qcount[3]), .D(Mux[3]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF4 (.Q(Qcount[4]), .D(Mux[4]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF5 (.Q(Qcount[5]), .D(Mux[5]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF6 (.Q(Qcount[6]), .D(Mux[6]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF7 (.Q(Qcount[7]), .D(Mux[7]), .CLOCK(CLOCK), .RESET(RESET));

    not Not0 (Qbar[0], Qcount[0]);
    not Not1 (Qbar[1], Qcount[1]);
    not Not2 (Qbar[2], Qcount[2]);
    not Not3 (Qbar[3], Qcount[3]);
    not Not4 (Qbar[4], Qcount[4]);
    not Not5 (Qbar[5], Qcount[5]);
    not Not6 (Qbar[6], Qcount[6]);
    not Not7 (Qbar[7], Qcount[7]);

    wire VazioTemp1, VazioTemp2;
    and AndVazio0 (VazioTemp1, Qbar[0], Qbar[1], Qbar[2], Qbar[3]);
    and AndVazio1 (VazioTemp2, Qbar[4], Qbar[5], Qbar[6], Qbar[7]);
    and AndVazio  (VAZIO, VazioTemp1, VazioTemp2);

    subtrator8x8 SubtratorPrincipal (
        .S(Sub15),                    
        .Bout(Bout15),                
        .A(Qcount),                  
        .B(8'b00001111),              
        .Bin(1'b0)                    
    );

    not NotBout (TemMaisDe15, Bout15);

    wire notVazio;
    not NotVazio (notVazio, VAZIO);
    and AndEnableBlock (EnableReal, ENABLE, notVazio);
    
    multiplexador2x1 MuxProx0 (.S(ProxEstoque[0]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[0]));
    multiplexador2x1 MuxProx1 (.S(ProxEstoque[1]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[1]));
    multiplexador2x1 MuxProx2 (.S(ProxEstoque[2]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[2]));
    multiplexador2x1 MuxProx3 (.S(ProxEstoque[3]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[3]));
    multiplexador2x1 MuxProx4 (.S(ProxEstoque[4]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[4]));
    multiplexador2x1 MuxProx5 (.S(ProxEstoque[5]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[5]));
    multiplexador2x1 MuxProx6 (.S(ProxEstoque[6]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[6]));
    multiplexador2x1 MuxProx7 (.S(ProxEstoque[7]), .Sel(TemMaisDe15), .A(1'b0), .B(Sub15[7]));
    
    wire [7:0] Xor;
    multiplexador2x1 MuxEnable0 (.S(Xor[0]), .Sel(EnableReal), .A(Qcount[0]), .B(ProxEstoque[0]));
    multiplexador2x1 MuxEnable1 (.S(Xor[1]), .Sel(EnableReal), .A(Qcount[1]), .B(ProxEstoque[1]));
    multiplexador2x1 MuxEnable2 (.S(Xor[2]), .Sel(EnableReal), .A(Qcount[2]), .B(ProxEstoque[2]));
    multiplexador2x1 MuxEnable3 (.S(Xor[3]), .Sel(EnableReal), .A(Qcount[3]), .B(ProxEstoque[3]));
    multiplexador2x1 MuxEnable4 (.S(Xor[4]), .Sel(EnableReal), .A(Qcount[4]), .B(ProxEstoque[4]));
    multiplexador2x1 MuxEnable5 (.S(Xor[5]), .Sel(EnableReal), .A(Qcount[5]), .B(ProxEstoque[5]));
    multiplexador2x1 MuxEnable6 (.S(Xor[6]), .Sel(EnableReal), .A(Qcount[6]), .B(ProxEstoque[6]));
    multiplexador2x1 MuxEnable7 (.S(Xor[7]), .Sel(EnableReal), .A(Qcount[7]), .B(ProxEstoque[7]));

    multiplexador2x1 MUX0 (.S(Mux[0]), .Sel(LOAD), .A(Xor[0]), .B(DADOS[0])); 
    multiplexador2x1 MUX1 (.S(Mux[1]), .Sel(LOAD), .A(Xor[1]), .B(DADOS[1])); 
    multiplexador2x1 MUX2 (.S(Mux[2]), .Sel(LOAD), .A(Xor[2]), .B(DADOS[2])); 
    multiplexador2x1 MUX3 (.S(Mux[3]), .Sel(LOAD), .A(Xor[3]), .B(DADOS[3])); 
    multiplexador2x1 MUX4 (.S(Mux[4]), .Sel(LOAD), .A(Xor[4]), .B(DADOS[4])); 
    multiplexador2x1 MUX5 (.S(Mux[5]), .Sel(LOAD), .A(Xor[5]), .B(DADOS[5])); 
    multiplexador2x1 MUX6 (.S(Mux[6]), .Sel(LOAD), .A(Xor[6]), .B(DADOS[6])); 
    multiplexador2x1 MUX7 (.S(Mux[7]), .Sel(LOAD), .A(Xor[7]), .B(DADOS[7])); 
    
    wire [7:0] QtdDispensada;
    multiplexador2x1 MuxDisp0 (.S(QtdDispensada[0]), .Sel(TemMaisDe15), .A(Qcount[0]), .B(1'b1));
    multiplexador2x1 MuxDisp1 (.S(QtdDispensada[1]), .Sel(TemMaisDe15), .A(Qcount[1]), .B(1'b1));
    multiplexador2x1 MuxDisp2 (.S(QtdDispensada[2]), .Sel(TemMaisDe15), .A(Qcount[2]), .B(1'b1));
    multiplexador2x1 MuxDisp3 (.S(QtdDispensada[3]), .Sel(TemMaisDe15), .A(Qcount[3]), .B(1'b1));
    multiplexador2x1 MuxDisp4 (.S(QtdDispensada[4]), .Sel(TemMaisDe15), .A(Qcount[4]), .B(1'b0));
    multiplexador2x1 MuxDisp5 (.S(QtdDispensada[5]), .Sel(TemMaisDe15), .A(Qcount[5]), .B(1'b0));
    multiplexador2x1 MuxDisp6 (.S(QtdDispensada[6]), .Sel(TemMaisDe15), .A(Qcount[6]), .B(1'b0));
    multiplexador2x1 MuxDisp7 (.S(QtdDispensada[7]), .Sel(TemMaisDe15), .A(Qcount[7]), .B(1'b0));
    
    // Só disponibiliza o valor quando EnableReal está ativo
    and AndDisp0 (DISPENSADO[0], QtdDispensada[0], EnableReal);
    and AndDisp1 (DISPENSADO[1], QtdDispensada[1], EnableReal);
    and AndDisp2 (DISPENSADO[2], QtdDispensada[2], EnableReal);
    and AndDisp3 (DISPENSADO[3], QtdDispensada[3], EnableReal);
    and AndDisp4 (DISPENSADO[4], QtdDispensada[4], EnableReal);
    and AndDisp5 (DISPENSADO[5], QtdDispensada[5], EnableReal);
    and AndDisp6 (DISPENSADO[6], QtdDispensada[6], EnableReal);
    and AndDisp7 (DISPENSADO[7], QtdDispensada[7], EnableReal);
	 
endmodule