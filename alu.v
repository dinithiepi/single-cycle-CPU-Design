
`include "add.v"
`include"forward.v"
`include "and.v"
`include "or.v"

/* The ALU module consists of two data inputs DATA1 and DATA2, 
one SELECT input to determine which ALU operation to perform on the two inputs 
and two outputs; the RESULT output which gives the result of the given operation on the data
and the ZERO output which indicates whether the RESULT output is zero */
module alu(DATA1, DATA2, RESULT, ZERO, SELECT);
	
	//Declaration of input ports
	input [7:0] DATA1, DATA2;
	input [2:0] SELECT;
	
	//Output port declaration
	output reg [7:0] RESULT;
	output ZERO;
	
	//Set of wires for outputs of each functional unit
	wire [7:0] forwardOut, addOut, andOut, orOut;
	
	
	//The functional units relevant to the different operations are instantiated here
	//They will output their result to the relevant Out wire
	FORWARD forwardUnit(DATA2, forwardOut);
	ADD addUnit(DATA1, DATA2, addOut);
	AND andUnit(DATA1, DATA2, andOut);
	OR orUnit(DATA1, DATA2, orOut);
	
	
	//This section of the ALU is analogous to a MUX
	//One of the functional units' results is sent to the RESULT output based on the SELECT value
	always @ (forwardOut, addOut, andOut, orOut, SELECT)	//RESULT output must be updated whenever the SELECT input or any of the functional units' outputs changes
	begin
		case (SELECT)		//Case statement to switch between the outputs

			3'b000 :	RESULT = forwardOut;	//SELECT = 0 : FORWARD
			
			3'b001 :	RESULT = addOut;		//SELECT = 1 : ADD
			
			3'b010 :	RESULT = andOut;		//SELECT = 2 : AND
			
			3'b011 :	RESULT = orOut;			//SELECT = 3 : OR
			
		endcase
	end
		
	//This section of the ALU contains the combinational logic to generate the ZERO output
	assign ZERO = ~(RESULT[0] | RESULT[1] | RESULT[2] | RESULT[3] | RESULT[4] | RESULT[5] | RESULT[6] | RESULT[7]);
	
endmodule