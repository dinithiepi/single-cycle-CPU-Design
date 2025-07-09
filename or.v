//group 40
//E/21/017 , E/21/126



// OR functional unit: performs bitwise OR on two 8-bit inputs (DATA1, DATA2)
// Produces output on RESULT with a delay of 1 time unit

module OR(DATA1, DATA2, RESULT);

	// 8-bit input operands
	input [7:0] DATA1, DATA2;
	
	// 8-bit output result
	output [7:0] RESULT;
	
	// Compute bitwise OR of DATA1 and DATA2 with 1 time unit delay
	assign #1 RESULT = DATA1 | DATA2;
	
endmodule
