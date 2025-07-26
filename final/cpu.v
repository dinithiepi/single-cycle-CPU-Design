// =========================================================
// Simple CPU Design
// =========================================================
// This module ties together the register file, ALU, 
// data memory, and control units. It implements a
// single-cycle CPU that can fetch, decode, and
// execute a basic instruction set.
// =========================================================


`include "alu.v"
`include "reg_file.v"
`include "two_comp.v"
`include "jump_branch_adder.v"
`include "pcAdder.v"
`include "mux.v"
`include "mux32.v"
`include "flowControl.v"
`timescale 1ns/100ps

//CPU module

module cpu(
	PC, 
	INSTRUCTION, 
	CLK, 
	RESET, 
	READ, 
	WRITE, 
	ADDRESS, 
	WRITEDATA, 
	READDATA, 
	BUSYWAIT, 
	INSTR_BUSYWAIT);

	
    // I/O Definitions
    
	input [31:0] INSTRUCTION; // 32-bit instruction
	input [7:0] READDATA;
	input CLK, RESET, BUSYWAIT, INSTR_BUSYWAIT;

	
	output reg [31:0] PC;    // Program counter
	output [7:0] ADDRESS;    // Address for data memory
	output [7:0] WRITEDATA;  
	output reg READ, WRITE;

	
    // Register File Connections
    
	wire [2:0] READREG1, READREG2, WRITEREG;
	wire [7:0] REGOUT1, REGOUT2;
	reg WRITEENABLE;

	// ==========================
    // ALU Connections
    // ==========================
	wire [7:0] OPERAND1, OPERAND2, ALURESULT;
	reg [2:0] ALUOP;
	wire ZERO;

	// ==========================
    // Connections for Sign select mux
    // ==========================
	wire [7:0] negatedOp;
	wire [7:0] registerOp;
	reg signSelect;

	// ==========================
	//Connections for immediate select MUX
	// ==========================
	wire [7:0] IMMEDIATE;
	reg immSelect;

	// ==========================
	//Connections for Program Counter
	// ==========================
	wire [31:0] PCplus4;
	wire [31:0] PCout;
	
	// ==========================
	//Connections for BUSYWAIT MUX
	// ==========================
	wire [31:0] newPC;

	// ==========================
	//Connections for Jump/Branch Adder
	// ==========================
	wire [31:0] TARGET;
	wire [7:0] OFFSET;
	
	// ==========================
	//Connections for flow control combinational unit
	// ==========================
	reg JUMP;
	reg BRANCH;

	// ==========================
	//Connections for flow control MUX
	// ==========================
	wire flowSelect;
	
	// ==========================
	//Connections to Data memory
	// ==========================
	
	// The address for the data memory is the result of the ALU computation.
	// This allows instructions like load and store (e.g., lwd/swd) to use
	// ALU results as memory addresses.

	assign ADDRESS = ALURESULT;

	// The data to be written to the data memory (in a store instruction)
	// is taken directly from the value of the register REGOUT1 (source register).

	assign WRITEDATA = REGOUT1;
	
	// ==========================
	//Connections for data memory MUX
	// ==========================
	reg dataSelect;
	wire [7:0] REGIN;

	//Current OPCODE
	reg [7:0] OPCODE;

	//Instantiation of CPU modules

	// Register File: Reads and writes register values.
	reg_file my_reg(REGIN, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
	
	// ALU: Executes arithmetic and logical operations.
	alu my_alu(REGOUT1, OPERAND2, ALURESULT, ZERO, ALUOP);
	
	// Two's Complement Unit: Provides negation of second operand.
	twosComp my_twosComp(REGOUT2, negatedOp);
	
	// Negation Multiplexer: Selects between original and negated operand.
	mux negationMUX(REGOUT2, negatedOp, signSelect, registerOp);
	
	// Immediate Multiplexer: Chooses between register value and immediate.
	mux immediateMUX(registerOp, IMMEDIATE, immSelect, OPERAND2);

	// PC Adder: Increments the program counter.
	pcAdder my_pcAdder(PC, PCplus4);
	
	// Jump/Branch Adder: Calculates target address.
	jumpbranchAdder my_jumpbranchAdder(PCplus4, OFFSET, TARGET);
	
	// Flow Control Unit: Determines next instruction based on flags JUMP/BRANCH/ZERO
	flowControl my_flowControl(JUMP, BRANCH, ZERO, flowSelect);
	
	// Flow Control Multiplexer: Chooses next PC value
	mux32 flowctrlmux(PCplus4, TARGET, flowSelect, PCout);
	
	//// Data Memory Multiplexer: Selects between ALU result and data read.
	mux datamux(ALURESULT, READDATA, dataSelect, REGIN);
	
	//MUX to Change PC value based on BUSYWAIT signal
	//If BUSYWAIT is HIGH, newPC is the same PC value(Stalled)
	//Else newPC is next PC value
	mux32 busywaitMUX(PCout, PC, (BUSYWAIT | INSTR_BUSYWAIT), newPC);
	
	
	//-----------------------
	// Control Logic for CPU
	//-----------------------
	
	//PC Update
	always @ (posedge CLK)
	begin
		if (RESET == 1'b1) #1 PC = 0;		//If RESET signal is HIGH, set PC to zero
		else #1 PC = newPC;					//Write new PC value
	end
	
	//Clearing READ/WRITE controls for Data Memory when BUSYWAIT is de-asserted
	always @ (BUSYWAIT)
	begin
		if (BUSYWAIT == 1'b0)
		begin
			READ = 0;
			WRITE = 0;
		end
	end
	
	
	//Relevant portions of INSTRUCTION are mapped to the respective units
	
	///////////////////////////////////////////////////////////////////
	/*    OP-CODE    /     RD/IMM    /       RT      /     RS/IMM    */
	/*    [31:24]    /    [23:16]    /     [15:8]    /      [7:0]    */
	///////////////////////////////////////////////////////////////////
	/*       |       /        |      /        |      /       |       */
	/*    OPCODE     /    WRITEREG   /    READREG1   /    READREG2   */
	/*               /     OFFSET    /               /   IMMEDIATE   */
	/*****************************************************************/
	assign READREG1 = INSTRUCTION[15:8];
	assign IMMEDIATE = INSTRUCTION[7:0];
	assign READREG2 = INSTRUCTION[7:0];
	assign WRITEREG = INSTRUCTION[23:16];
	assign OFFSET = INSTRUCTION[23:16];
	
	
	
	//Decoding the instruction
	always @ (INSTRUCTION)
	begin
		//if (!INSTR_BUSYWAIT)
		//begin
			#1			//1 Time Unit Delay for Decoding process
			OPCODE = INSTRUCTION[31:24];	//Mapping the OP-CODE section of the instruction to OPCODE
			case (OPCODE)
			
				//loadi instruction
				8'b00000000:	begin
									ALUOP = 3'b000;			//Set ALU to forward
									immSelect = 1'b1;		//Set MUX to select immediate value
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output 
								end
			
				//mov instruction
				8'b00000001:	begin
									ALUOP = 3'b000;			//Set ALU to FORWARD
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end
				
				//add instruction
				8'b00000010:	begin
									ALUOP = 3'b001;			//Set ALU to ADD
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end	
			
				//sub instruction
				8'b00000011:	begin
									ALUOP = 3'b001;			//Set ALU to ADD
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b1;		//Set sign select MUX to negative sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end

				//and instruction
				8'b00000100:	begin
									ALUOP = 3'b010;			//Set ALU to AND
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end
								
				//or instruction
				8'b00000101:	begin
									ALUOP = 3'b011;			//Set ALU to OR
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end
				
				//j instruction
				8'b00000110:	begin
									JUMP = 1'b1;			//Set JUMP control signal to 1
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b0;		//Disable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end
				
				//beq instruction
				8'b00000111:	begin
									ALUOP = 3'b001;			//Set ALU to ADD
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b1;		//Set sign select MUX to negative sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b1;			//Set BRANCH control signal to 1
									WRITEENABLE = 1'b0;		//Disable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b0;		//Set Data Memory MUX to ALU output
								end
								
				//lwd instruction
				8'b00001000:	begin
									ALUOP = 3'b000;			//Set ALU to forward
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b1;			//Set READ control signal to HIGH
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b1;		//Set Data Memory MUX to Data memory input
								end
								
				//lwi instruction
				8'b00001001:	begin
									ALUOP = 3'b000;			//Set ALU to forward
									immSelect = 1'b1;		//Set MUX to select immediate value
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b1;		//Enable writing to register
									READ = 1'b1;			//Set READ control signal to HIGH
									WRITE = 1'b0;			//Set WRITE control signal to zero
									dataSelect = 1'b1;		//Set Data Memory MUX to Data memory input
								end
				
				//swd instruction
				8'b00001010:	begin
									ALUOP = 3'b000;			//Set ALU to forward
									immSelect = 1'b0;		//Set MUX to select register input
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b0;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b1;			//Set WRITE control signal to HIGH
								end
								
				//swi instruction
				8'b00001011:	begin
									ALUOP = 3'b000;			//Set ALU to forward
									immSelect = 1'b1;		//Set MUX to select immediate value
									signSelect = 1'b0;		//Set sign select MUX to positive sign
									JUMP = 1'b0;			//Set JUMP control signal to zero
									BRANCH = 1'b0;			//Set BRANCH control signal to zero
									WRITEENABLE = 1'b0;		//Enable writing to register
									READ = 1'b0;			//Set READ control signal to zero
									WRITE = 1'b1;			//Set WRITE control signal to HIGH
								end
			endcase
		//end
	end
	
endmodule


