
`timescale 1ns/100ps

/**
 * DATA MEMORY MODULE
 * 256-byte memory with 32-bit block access
 * Implements 40ns read/write latency
 */

module data_memory(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait
);
input				clock;
input           	reset;
input           	read;
input           	write;
input[5:0]      	address;
input[31:0]     	writedata;
output reg [31:0]	readdata;
output reg      	busywait;

//Declare memory array 256x8-bits 
reg [7:0] memory_array [255:0];

//Detecting an incoming memory access
reg readaccess, writeaccess;

// =============================================
// ACCESS DETECTION LOGIC
// =============================================

always @(read, write)
begin
	// Set busywait when either read or write is requested
	busywait = (read || write)? 1 : 0;

	// Decode exact operation type
	readaccess = (read && !write)? 1 : 0; // Pure read
	writeaccess = (!read && write)? 1 : 0; // Pure write
end

//Reading & writing

// =============================================
// MEMORY OPERATIONS (40ns latency)
// =============================================

always @(posedge clock)
begin
	// READ OPERATION
	if(readaccess)
	begin
		// Read 4 bytes with 40ns delay
		readdata[7:0]   = #40 memory_array[{address,2'b00}];
		readdata[15:8]  = #40 memory_array[{address,2'b01}];
		readdata[23:16] = #40 memory_array[{address,2'b10}];
		readdata[31:24] = #40 memory_array[{address,2'b11}];

		// Clear flags after operation completes
		busywait = 0;
		readaccess = 0;
	end

	// WRITE OPERATION
	if(writeaccess)
	begin
		// Write 4 bytes with 40ns delay

		memory_array[{address,2'b00}] = #40 writedata[7:0];
		memory_array[{address,2'b01}] = #40 writedata[15:8];
		memory_array[{address,2'b10}] = #40 writedata[23:16];
		memory_array[{address,2'b11}] = #40 writedata[31:24];

		// Clear flags after operation completes
		busywait = 0;
		writeaccess = 0;
	end
end

// =============================================
// MEMORY INITIALIZATION
// =============================================


//Reset memory
integer i;
always @(posedge reset)
begin
    if (reset)
    begin
		// Clear all memory locations
        for (i=0;i<256; i=i+1)
            memory_array[i] = 0;
        
		// Reset control signals
        busywait = 0;
		readaccess = 0;
		writeaccess = 0;
    end
end

endmodule
