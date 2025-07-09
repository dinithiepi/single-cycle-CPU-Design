//group 40
//E/21/017 , E/21/126

// This module performs a bitwise AND operation on two 8-bit input values
// Produces the result at the output after a delay of 1 time unit
module AND(DATA1, DATA2, RESULT);

	// 8-bit input operands
	input [7:0] DATA1, DATA2;
	
	// 8-bit output result
	output [7:0] RESULT;
	
	// Perform bitwise AND on DATA1 and DATA2, assign to RESULT with a 1-time-unit delay
	assign #1 RESULT = DATA1 & DATA2;
	
endmodule
