//group 40
//E/21/017 , E/21/126

// secondary.v
// initialization of the secondary modules used in the CPU
// 	twosComp my_twosComp(OPERAND2, negatedOp);
module twosComp(IN, OUT);

	//Input and output port declaration
	//This module takes an 8-bit input and outputs its two's complement
	input [7:0] IN;
	output [7:0] OUT;
	
	//Assigns the two's complement of IN to OUT after a delay of 1 time unit
	//Two's complement is calculated by inverting the bits and adding 1
	assign #1 OUT = ~IN + 1;

endmodule


//The jumpbranchAdder module generates the target address for jump and branch instructions
//It takes the current PC value and an 8-bit OFFSET, and outputs a 32-bit TARGET address
//The OFFSET is sign-extended to 32 bits and shifted left by 2 bits before
module jumpbranchAdder(PC, OFFSET, TARGET);
	
	
	input [31:0] PC;//Declaration of input port for current PC value
	input [7:0] OFFSET;//Declaration of input port for branch offset
	output [31:0] TARGET;//Declaration of output port for target address
	
	wire [21:0] signBits;		//Bus to store extended sign bits
	
	assign signBits = {22{OFFSET[7]}};	//assigning the sign bit (MSB) of OFFSET to all 22 bits in signBits
	

	assign #2 TARGET = PC + {signBits, OFFSET, 2'b0};	
	
endmodule


//The pcAdder module generates the PC+4 value from the PC input after a delay of 1 time unit
module pcAdder(PC, PCplus4);
	
	//Declaration of input and output ports
	input [31:0] PC;
	output [31:0] PCplus4;

	//Assign PC+4 value to the output after 1 time unit delay
	assign #1 PCplus4 = PC + 4;
	
endmodule

//mux module selects between two 8-bit inputs based on a SELECT signal
//If SELECT is HIGH, it outputs the second input; if LOW, it outputs the first input
//This module is used for selecting between register values or immediate values in the CPU

module mux(IN1, IN2, SELECT, OUT);

	//Input and output port declaration
	input [7:0] IN1, IN2;
	input SELECT;
	output reg [7:0] OUT;
	
	//MUX should update output value upon change of any of the inputs
	always @ (IN1, IN2, SELECT)
	begin
		if (SELECT == 1'b1)		//If SELECT is HIGH, switch to 2nd input
		begin
			OUT = IN2;
		end
		else					//If SELECT is LOW, switch to 1st input
		begin
			OUT = IN1;
		end
	end

endmodule

//mux32 module selects between two 32-bit inputs based on a SELECT signal
//If SELECT is HIGH, it outputs the second input; if LOW, it outputs the first
module mux32(IN1, IN2, SELECT, OUT);

	//Input and output port declaration
	input [31:0] IN1, IN2;
	input SELECT;
	output reg [31:0] OUT;
	
	//MUX should update output value upon change of any of the inputs
	always @ (IN1, IN2, SELECT)
	begin
		if (SELECT == 1'b1)		//If SELECT is HIGH, switch to 2nd input
		begin
			OUT = IN2;
		end
		else					//If SELECT is LOW, switch to 1st input
		begin
			OUT = IN1;
		end
	end

endmodule

// flowControl module determines whether to jump or branch based on JUMP, BRANCH, and ZERO signals
// If JUMP is HIGH, it outputs HIGH; if BRANCH is HIGH and ZERO is	 HIGH, it also outputs HIGH
// Otherwise, it outputs LOW		
module flowControl(JUMP, BRANCH, ZERO, OUT);

	//Input and output port declaration
	input JUMP, BRANCH, ZERO;
	output OUT;
	
	//Assigns OUT based on values of JUMP, BRANCH and ZERO using simple combinational logic
	assign OUT = JUMP | (BRANCH & ZERO);

endmodule