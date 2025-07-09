// The ADD functional unit performs addition of two 8-bit input values: DATA1 and DATA2
// The result is sent to the RESULT output after a delay of 2 time units
module ADD(DATA1, DATA2, RESULT);

	// 8-bit input operands for the addition operation
	input [7:0] DATA1, DATA2;
	
	// 8-bit output to store the result of the addition
	output [7:0] RESULT;
	
	// Perform addition and assign the result to RESULT after 2 time units
	assign #2 RESULT = DATA1 + DATA2;
	
endmodule
