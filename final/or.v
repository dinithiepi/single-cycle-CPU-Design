//The OR functional 
//delay of 1 time unit

`timescale 1ns/100ps
module OR(DATA1, DATA2, RESULT);

	//Input port declaration
	input [7:0] DATA1, DATA2;
	
	//Declaration of output port
	output [7:0] RESULT;
	
	//Assigns logical OR result
	assign #1 RESULT = DATA1 | DATA2;
	
endmodule
