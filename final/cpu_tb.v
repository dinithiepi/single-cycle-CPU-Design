
`timescale 1ns/100ps
`include "dmem_for_dcache.v"
`include "dcache.v"
`include "icache.v"
`include "imem_for_icache.v"
`include "cpu.v"

module cpu_tb;

    reg CLK, RESET;
	
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
	
	
	wire CPU_READ, CPU_WRITE, CPU_BUSYWAIT;
	wire DM_READ, DM_WRITE, DM_BUSYWAIT;
	
	wire [7:0] CPU_ADDRESS, CPU_WRITEDATA, CPU_READDATA;
	wire [31:0] DM_WRITEDATA, DM_READDATA;
	wire [5:0] DM_ADDRESS;
	
	
	wire INSTR_BUSYWAIT;
	
	
	wire IM_READ, IM_BUSYWAIT;
	wire [5:0] IM_ADDRESS;
	wire [127:0] IM_INSTR;
	
	integer i;
	
	/*
	------------
	DATA MEMORY
	------------
    */
	data_memory my_datamem(CLK, RESET, DM_READ, DM_WRITE, DM_ADDRESS, DM_WRITEDATA, DM_READDATA, DM_BUSYWAIT);
	
	/*
	------------
	DATA CACHE
	------------
    */
	data_cache my_datacache (CLK, RESET, CPU_READ, CPU_WRITE, CPU_ADDRESS, CPU_WRITEDATA, CPU_READDATA, CPU_BUSYWAIT, DM_READ, DM_WRITE, DM_ADDRESS, DM_WRITEDATA, DM_READDATA, DM_BUSYWAIT);



	/*
	------------------
	INSTRUCTION CACHE
	------------------
    */
	icache my_icache(CLK, RESET, PC[9:0], INSTRUCTION, INSTR_BUSYWAIT, IM_READ, IM_ADDRESS, IM_INSTR, IM_BUSYWAIT);
	
	
	/*
	------------------
	INSTRUCTION MEMORY
	------------------
    */
	instruction_memory my_imemory(CLK, IM_READ, IM_ADDRESS, IM_INSTR, IM_BUSYWAIT);
	
	
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET, CPU_READ, CPU_WRITE, CPU_ADDRESS, CPU_WRITEDATA, CPU_READDATA, CPU_BUSYWAIT, INSTR_BUSYWAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);

		$dumpfile("cpu_wavedata.vcd");

        
		$dumpvars(0, cpu_tb);
        for (i =0 ;i<8 ;i++ ) begin
            $dumpvars(1, cpu_tb.mycpu.my_reg.REGISTER[i]);
        
        end

        $dumpvars(0, cpu_tb);
        for (i =0 ;i<10 ;i++ ) begin
            $dumpvars(1, cpu_tb.my_datamem.memory_array[i]);
        end

        $dumpvars(0, cpu_tb);
        for (i =0 ;i<8 ;i++ ) begin
            $dumpvars(1, cpu_tb.my_datacache.cacheblock_array[i]);
        end

		$dumpvars(0, cpu_tb);
        for (i =0 ;i<8 ;i++ ) begin
            $dumpvars(1, cpu_tb.my_icache.instr_block_array[i]);
        end




        $dumpvars(0, cpu_tb);




        
        CLK = 1'b0;
        RESET = 1'b1;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
		#5
		RESET = 1'b0;
        
        // finish simulation after some time
        #5000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule