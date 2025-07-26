/* Simple 8x8 register file
capable of reading and storing eight 8-bit values
and outputting stored 8-bit values
Writing to the register is synchronous at the rising edge of the CLK signal
Reading from the register is asynchronous
*/

`timescale 1ns/100ps

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

	//Declaration of input ports
	input [7:0] IN;
	input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
	
	
	input WRITE, CLK, RESET;
	
	//Output port declaration
	output [7:0] OUT1, OUT2;
	
	
	
	//Array of 8 8-bit registers
	reg [7:0] REGISTER [7:0];

	//Iterator variable used in for loop
	integer i;
	
	
	//Reads data from registers asynchronously
	//delay of 2 time units
	assign #2 OUT1 = REGISTER[OUT1ADDRESS];		
	assign #2 OUT2 = REGISTER[OUT2ADDRESS];		
	
	
	//Synchronous register operations (Write and Reset)
	//delay of 1 time unit
	always @ (posedge CLK)
	begin
		if (RESET == 1'b1)		
		begin
		
			#1 for (i = 0; i < 8; i = i + 1)			
			begin
				REGISTER[i] = 8'b00000000;		//resetting the REGISTER array to 0
			end
			
		end
		else if (WRITE == 1'b1)			//writing to the registers if WRITE signal is HIGH and RESET signal is LOW, 
		begin
		
			#1 REGISTER[INADDRESS] = IN;		
			
		end
		
	end
	
	
	//Logging register file contents
	initial
	begin
		#5
		$display("\t\t TIME \t R0 \t R1 \t R2 \t R3 \t R4 \t R5 \t R6 \t R7");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", REGISTER[0], REGISTER[1], REGISTER[2], REGISTER[3], REGISTER[4], REGISTER[5], REGISTER[6], REGISTER[7]);
	end

endmodule