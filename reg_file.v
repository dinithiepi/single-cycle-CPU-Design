
//group 40
//E/21/017 , E/21/126


// Register file module: 8 registers, each 8 bits wide
// Supports synchronous reset and write, and asynchronous read
// Read delay: 2 time units; Write and Reset delay: 1 time unit
// Used to store intermediate data during instruction execution in CPU

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);

	// 8-bit input data to be written to the register file
	input [7:0] IN;

	// 3-bit addresses to select registers for input and two outputs
	input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;

	// Control signals: write enable, clock, and reset
	input WRITE, CLK, RESET;

	// 8-bit outputs read from two selected registers
	output [7:0] OUT1, OUT2;

	// Internal register array: 8 registers of 8 bits each
	reg [7:0] REGISTER [7:0];

	// Loop index variable for reset logic
	integer i;

	// Asynchronous reads with 2 time unit delay
	assign #2 OUT1 = REGISTER[OUT1ADDRESS];		
	assign #2 OUT2 = REGISTER[OUT2ADDRESS];		

	// Synchronous reset and write operations triggered on rising edge of CLK
	always @ (posedge CLK)
	begin
		// On reset, clear all registers after 1 time unit
		if (RESET == 1'b1)
		begin
			#1 for (i = 0; i < 8; i = i + 1)
			begin
				REGISTER[i] = 8'b00000000;	// Clear each register
			end
		end
		// On write enable, write input data to selected register after 1 time unit
		else if (WRITE == 1'b1)
		begin
			#1 REGISTER[INADDRESS] = IN;	// Write IN to register at INADDRESS
		end
	end

	// Display initial values of all registers at simulation start
	initial
	begin
		#5
		$display("\t\t TIME \t R0 \t R1 \t R2 \t R3 \t R4 \t R5 \t R6 \t R7");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", REGISTER[0], REGISTER[1], REGISTER[2], REGISTER[3], REGISTER[4], REGISTER[5], REGISTER[6], REGISTER[7]);
	end

endmodule
