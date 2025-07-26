
//forwards the DATA input to the RESULT output
//delay of 1 time unit

`timescale 1ns/100ps
module FORWARD(DATA, RESULT);

	//Input port
	input [7:0] DATA;
	
	//Output port
	output [7:0] RESULT;
	
	//forwarding
	assign #1 RESULT = DATA;

endmodule
