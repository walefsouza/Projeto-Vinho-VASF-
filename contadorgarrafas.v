// ============================================
// CONTADOR CRESCENTE 0-12 PARA UMA DÚZIA
// ============================================

module contadorgarrafas (
    output DUZIA_COMPLETA,
    input CLOCK,
    input RESET,
    input ENABLE
);

    wire [3:0] COUNT;
    wire [3:0] Qbar;           
    wire [3:0] And;        
    wire [3:0] Xor;          
    wire [3:0] Mux;             
    wire LIMITE;                
    wire LOAD;                    
    wire EnableReal;             
    
    wire notQ1, notQ0;
    not NotQ1 (notQ1, COUNT[1]);
    not NotQ0 (notQ0, COUNT[0]);
    and AndLimit (LIMITE, COUNT[3], COUNT[2], notQ1, notQ0);
    
    and AndLoad (LOAD, LIMITE, ENABLE);
    assign DUZIA_COMPLETA = LOAD; 
    
    
    wire notLOAD;
    not NotLOAD (notLOAD, LOAD);
    and AndEnableBlock (EnableReal, ENABLE, notLOAD);
    
    
    flipflopbase FF0 (.Q(COUNT[0]), .D(Mux[0]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF1 (.Q(COUNT[1]), .D(Mux[1]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF2 (.Q(COUNT[2]), .D(Mux[2]), .CLOCK(CLOCK), .RESET(RESET));
    flipflopbase FF3 (.Q(COUNT[3]), .D(Mux[3]), .CLOCK(CLOCK), .RESET(RESET));
    
    
    not Not0 (Qbar[0], COUNT[0]);
    not Not1 (Qbar[1], COUNT[1]);
    not Not2 (Qbar[2], COUNT[2]);
    not Not3 (Qbar[3], COUNT[3]);
    
    
    and And0 (And[0], EnableReal, COUNT[0]);
    and And1 (And[1], And[0], COUNT[1]);
    and And2 (And[2], And[1], COUNT[2]);
    
    
    xor Xor0 (Xor[0], COUNT[0], EnableReal);
    xor Xor1 (Xor[1], COUNT[1], And[0]);
    xor Xor2 (Xor[2], COUNT[2], And[1]);
    xor Xor3 (Xor[3], COUNT[3], And[2]);

    
    multiplexador2x1 MUX0 (.S(Mux[0]), .Sel(LOAD), .A(Xor[0]), .B(1'b0)); 
    multiplexador2x1 MUX1 (.S(Mux[1]), .Sel(LOAD), .A(Xor[1]), .B(1'b0)); 
    multiplexador2x1 MUX2 (.S(Mux[2]), .Sel(LOAD), .A(Xor[2]), .B(1'b0)); 
    multiplexador2x1 MUX3 (.S(Mux[3]), .Sel(LOAD), .A(Xor[3]), .B(1'b0)); 
    

endmodule