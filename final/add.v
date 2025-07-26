
//adds together the two 8-bit numbers
//delay of 2 time units

`timescale 1ns/100ps
module ADD(DATA1, DATA2, RESULT);

	//Declaration of two 8-bit data inputs
	input [7:0] DATA1, DATA2;
	
	//Declaration of output
	output [7:0] RESULT;
	
	//Assigns evaluated result
	assign #2 RESULT = DATA1 + DATA2;
	
endmodule
