//output the 2's complement value of the input

`timescale 1ns/100ps
module twosComp(IN, OUT);

	//Declaration of input and output ports
	input [7:0] IN;
	output [7:0] OUT;
	
	//assigning two's complement value
	assign #1 OUT = ~IN + 1;

endmodule