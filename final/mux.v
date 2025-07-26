
// mux module that works with 8 bit input data

`timescale 1ns/100ps
module mux(IN1, IN2, SELECT, OUT);

	//Input and output port declaration
	input [7:0] IN1, IN2;
	input SELECT;
	output reg [7:0] OUT;
	
	//updating output value with change of any of the inputs
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