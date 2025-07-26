// mux module that works with 32 bit input data

`timescale 1ns/100ps
module mux32(IN1, IN2, SELECT, OUT);

	//Input and output port declaration
	input [31:0] IN1, IN2;
	input SELECT;
	output reg [31:0] OUT;
	
	//updating output value when change of any of the inputs
	always @ (IN1, IN2, SELECT)
	begin
		if (SELECT == 1'b1)		
		begin
			OUT = IN2;
		end
		else					
		begin
			OUT = IN1;
		end
	end

endmodule