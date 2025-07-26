//Combinational logic for flow control

/*
JUMP = 0  BRANCH = 0          : OUT = 0 (Normal flow)
JUMP = 1                      : OUT = 1 (Offset flow)
JUMP = 0  BRANCH = 1 ZERO = 0 : OUT = 0 (Normal flow)
JUMP = 0  BRANCH = 1 ZERO = 1 : OUT = 1 (Offset flow)
*/


//Contains no delays

`timescale 1ns/100ps

module flowControl(JUMP, BRANCH, ZERO, OUT);

	//Input and output port declaration
	input JUMP, BRANCH, ZERO;
	output OUT;
	
	//Assigns OUT based on values of JUMP, BRANCH and ZERO
	assign OUT = JUMP | (BRANCH & ZERO);

endmodule