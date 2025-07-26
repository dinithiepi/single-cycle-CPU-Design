
`include "add.v"
`include"forward.v"
`include "and.v"
`include "or.v"

`timescale 1ns/100ps

/* RESULT output gives the result of the given operation on the data
ZERO output indicates whether the RESULT output is zero */

module alu(DATA1, DATA2, RESULT, ZERO, SELECT);
	
	//input ports
	input [7:0] DATA1, DATA2;
	input [2:0] SELECT;
	
	//Output ports
	output reg [7:0] RESULT;
	output ZERO;
	
	//wires for outputs of functional units
	wire [7:0] forwardOut, addOut, andOut, orOut;
	
	
	// instantiating functional units
	FORWARD forwardUnit(DATA2, forwardOut);
	ADD addUnit(DATA1, DATA2, addOut);
	AND andUnit(DATA1, DATA2, andOut);
	OR orUnit(DATA1, DATA2, orOut);
	
	
	//Selecting the corresponding result according to the select signal
	
	always @ (forwardOut, addOut, andOut, orOut, SELECT)	
	begin	
		case (SELECT)		//selecting the outputs

			3'b000 :	RESULT = forwardOut;	//SELECT = 0 : FORWARD
			
			3'b001 :	RESULT = addOut;		//SELECT = 1 : ADD
			
			3'b010 :	RESULT = andOut;		//SELECT = 2 : AND
			
			3'b011 :	RESULT = orOut;			//SELECT = 3 : OR
			
		endcase
	end
		
	//combinational logic to generate the ZERO output
	assign ZERO = ~(RESULT[0] | RESULT[1] | RESULT[2] | RESULT[3] | RESULT[4] | RESULT[5] | RESULT[6] | RESULT[7]);
	
endmodule