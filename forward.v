//group 40
//E/21/017 , E/21/126

// FORWARD functional unit: passes the 8-bit input DATA directly to RESULT
// Introduces a delay of 1 time unit before forwarding

module FORWARD(DATA, RESULT);

	// 8-bit input value
	input [7:0] DATA;
	
	// 8-bit output value
	output [7:0] RESULT;
	
	// Forward DATA to RESULT with 1 time unit delay
	assign #1 RESULT = DATA;

endmodule
