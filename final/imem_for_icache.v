

module instruction_memory(
	clock,
	read,
    address,
    readinst,
	busywait
);
input				clock;
input				read;
input[5:0]			address;
output reg [127:0]	readinst;
output	reg			busywait;

reg readaccess;

//Declare memory array 1024x8-bits 
reg [7:0] memory_array [1023:0];

//Initialize instruction memory
initial
begin
	busywait = 0;
	readaccess = 0;
	
    // Sample program given below. You may hardcode your software program here, or load it from a file:
	// Sample program to test the CPU
	// This program performs a series of load, store, and arithmetic operations
	// The program is designed to test the functionality of the CPU and the cache system
    {memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  = 32'b00000000000001000000000000011011; // loadi 4 #27
    {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  = 32'b00000000000001010000000000100010; // loadi 5 #34
    {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  = 32'b00000010000001100000010000000101; // add 6 4 5
    {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00000000000000010000000001011010; // loadi 1 90
    
	{memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00000000000001000000000000000011; // loadi 4 #3
	{memory_array[10'd23], memory_array[10'd22], memory_array[10'd21], memory_array[10'd20]} = 32'b00000000000001010000000000000010; // loadi 5 #2
	{memory_array[10'd27], memory_array[10'd26], memory_array[10'd25], memory_array[10'd24]} = 32'b00000010000001100000010000000101; // add 6 4 5
	{memory_array[10'd31], memory_array[10'd30], memory_array[10'd29], memory_array[10'd28]} = 32'b00000011000000010000000100000100; // sub 1 1 4
	
	//swi R1, [00001000]   // 
    // store the value in R1 in address 00001000
    //write cache miss not dirty, 
    //{instr_mem[7], instr_mem[6], instr_mem[5], instr_mem[4]} = 32'b00001011_00000000_00000001_00001000;
	{memory_array[10'd35], memory_array[10'd34], memory_array[10'd33], memory_array[10'd32]} = 32'b00001011_00000000_00000001_00001000; 
	
    //read cache hit
    
    //lwi  R2, [00001000]   
    //load the value in address 00001000 into R2
    //cache hit
    //{instr_mem[11], instr_mem[10], instr_mem[9], instr_mem[8]} = 32'b00001001_00000010_00000000_00001000;
	{memory_array[10'd39], memory_array[10'd38], memory_array[10'd37], memory_array[10'd36]} = 32'b00001001_00000010_00000000_00001000; 


	//write cache hit
	//swi R4, 00001000
	{memory_array[10'd43], memory_array[10'd42], memory_array[10'd41], memory_array[10'd40]} = 32'b00001011_00000000_00000100_00001000;
	
	
	
	//write cache miss dirty
	//swi R5, 00101000
	{memory_array[10'd47], memory_array[10'd46], memory_array[10'd45], memory_array[10'd44]} = 32'b00001011_00000000_00000101_00101000; 
	
	//loadi R0, 10
	{memory_array[10'd51],  memory_array[10'd50],  memory_array[10'd49],  memory_array[10'd48]}  = 32'b00000000_00000000_00000000_00001010;

	//read miss not dirty
	//lwi R0, 00000100
	{memory_array[10'd55], memory_array[10'd54], memory_array[10'd53], memory_array[10'd52]} = 32'b00001001_00000000_00000000_00000100; 
	
	//read miss dirty
	//lwi R0, 00001000
	//{memory_array[10'd59], memory_array[10'd58], memory_array[10'd57], memory_array[10'd56]} = 32'b00001001_00000000_00000000_00001000; 
	
	//read hit
	//lwi R6, 00000100
	//{memory_array[10'd63], memory_array[10'd62], memory_array[10'd61], memory_array[10'd60]} = 32'b00001001_00000110_00000000_00000100;

	//read hit
	//lwi R1, 00001000
	//{memory_array[10'd67], memory_array[10'd66], memory_array[10'd65], memory_array[10'd64]} = 32'b00001001_00000001_00000000_00001000;

	


	//$readmemb("instr_mem.mem", memory_array);
end



//Detecting an incoming memory access
always @(read)
begin
    busywait = (read)? 1 : 0;
    readaccess = (read)? 1 : 0;
end

//Reading
always @(posedge clock)
begin
	if(readaccess)
	begin
		readinst[7:0]     = #40 memory_array[{address,4'b0000}];
		readinst[15:8]    = #40 memory_array[{address,4'b0001}];
		readinst[23:16]   = #40 memory_array[{address,4'b0010}];
		readinst[31:24]   = #40 memory_array[{address,4'b0011}];
		readinst[39:32]   = #40 memory_array[{address,4'b0100}];
		readinst[47:40]   = #40 memory_array[{address,4'b0101}];
		readinst[55:48]   = #40 memory_array[{address,4'b0110}];
		readinst[63:56]   = #40 memory_array[{address,4'b0111}];
		readinst[71:64]   = #40 memory_array[{address,4'b1000}];
		readinst[79:72]   = #40 memory_array[{address,4'b1001}];
		readinst[87:80]   = #40 memory_array[{address,4'b1010}];
		readinst[95:88]   = #40 memory_array[{address,4'b1011}];
		readinst[103:96]  = #40 memory_array[{address,4'b1100}];
		readinst[111:104] = #40 memory_array[{address,4'b1101}];
		readinst[119:112] = #40 memory_array[{address,4'b1110}];
		readinst[127:120] = #40 memory_array[{address,4'b1111}];
		busywait = 0;
		readaccess = 0;
	end
end

// initial begin
// 	$monitor(read);
// 	end
 
endmodule
