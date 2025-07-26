//calculates the target instruction address by 
//sign extensioning the offset and multiplication by 4
//and adding to the PC+4 value

//Contains a delay of 2 time units

`timescale 1ns/100ps
module jumpbranchAdder(PC, OFFSET, TARGET);
	
	//Declaration of input and output ports
	input [31:0] PC;
	input [7:0] OFFSET;
	output [31:0] TARGET;
	
	wire [21:0] signBits;		//this bus to stores extended sign bits
	
	assign signBits = {22{OFFSET[7]}};	//extending the sign bit (MSB) of OFFSET to all 22 bits in bus
	
	
	//First 22 bits contain the extended sign bits, 
	//next 8 bits contain the actual offset, the next two 0 bits shift left by 2 (mutiplying by 4)
	assign #2 TARGET = PC + {signBits, OFFSET, 2'b0};	
	
endmodule