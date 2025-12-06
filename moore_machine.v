module moore_machine ( input clk ,
input reset , input enter , output [2:0] S) ;
reg [2:0] state , nextstate ;
// state code
	parameter A = 2'b00 ;
	parameter B = 2'b01 ;
	parameter C = 2'b10 ;
	parameter D = 2'b11 ;
	
	
// state register
	always @ ( posedge clk , posedge
	reset )
		if ( reset ) state <= A ;
		else state <= nextstate ;
		
// next state logic
	always @ (*)
		case ( state )
			A : if ( enter ) nextstate = B ;
			else nextstate = A ;
			B : if ( enter ) nextstate = C ;
			else nextstate = A ;
			C : if ( enter ) nextstate = D ;
			else nextstate = A ;
			D : if ( enter ) nextstate = A ;
			else nextstate = A ;
			
			default : nextstate = A ;
		endcase
		

 // output logic
assign S[0] = ( state == B ) || ( state == C ) || ( state == D );
assign S[1] = ( state == C ) || ( state == D );
assign S[2] = ( state == D );

endmodule