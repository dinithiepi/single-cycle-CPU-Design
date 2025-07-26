
//logical AND operation
//delay of 1 time unit
`timescale 1ns/100ps
module AND(DATA1, DATA2, RESULT);

	//Input ports
	input [7:0] DATA1, DATA2;
	
	//output ports
	output [7:0] RESULT;
	
	//Assigns logical AND result
	assign #1 RESULT = DATA1 & DATA2;
	
endmodule
