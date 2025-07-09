//testbench for CPU
// This testbench simulates a simple CPU with instruction memory and data memory
`include "dmem.v"
`include "cpu.v"
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
	wire WRITE, READ, BUSYWAIT;
	wire [7:0] ADDRESS, WRITEDATA, READDATA;
    
   
    
    // Instruction Memory
    // 1024 x 8-bit memory to store instructions
	reg [7:0] instr_mem [1023:0];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
	assign #2 INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
// loadi  r3 = 7
{instr_mem[3], instr_mem[2], instr_mem[1], instr_mem[0]} = 32'b00000000_00000011_00000000_00000111;

// loadi  r5 = 6 
{instr_mem[7], instr_mem[6], instr_mem[5], instr_mem[4]} = 32'b00000000_00000101_00000000_00000110;

// loadi  r4 = 4
{instr_mem[11], instr_mem[10], instr_mem[9], instr_mem[8]} = 32'b00000000_00000100_00000000_00000100;

// swd r3,r4
{instr_mem[15], instr_mem[14], instr_mem[13], instr_mem[12]} = 32'b00001010_00000000_00000011_00000100;

// swi r3,0x02
{instr_mem[19], instr_mem[18], instr_mem[17], instr_mem[16]} = 32'b00001011_00000000_00000011_00000010;

// lwd r1, r4
{instr_mem[23], instr_mem[22], instr_mem[21], instr_mem[20]} = 32'b00001000_00000001_00000000_00000100;

// lwi r7, 0x02
{instr_mem[27], instr_mem[26], instr_mem[25], instr_mem[24]} = 32'b00001001_00000111_00000000_00000010;



        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("instr_mem.mem", instr_mem);
    end
	
	
	/*

	DATA MEMORY

    */
	data_memory my_datamem(CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, BUSYWAIT);
	
	
	
    /* 
    
     CPU
    
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, BUSYWAIT);
     integer i;

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        for (i =0 ;i<8 ;i++ ) begin
            $dumpvars(1, cpu_tb.mycpu.my_reg.REGISTER[i]);
        end
        $dumpvars(0, cpu_tb);
        for (i =0 ;i<10 ;i++ ) begin
            $dumpvars(1, cpu_tb.my_datamem.memory_array[i]);
        end
        
        CLK = 1'b0;
        RESET = 1'b1;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
		#5
		RESET = 1'b0;
        
        // finish simulation after some time
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule