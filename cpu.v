

`include "alu.v"
`include "reg_file.v"
`include "secondary.v"

// The CPU module is the top-level module that integrates all components of the CPU
// It handles the instruction decoding, control signals, and data flow between the components	
module cpu(PC, INSTRUCTION, CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, BUSYWAIT);

	//Input Port Declaration
	input [31:0] INSTRUCTION;
	input [7:0] READDATA;
	input CLK, RESET, BUSYWAIT;

	//Output Port Declaration
	output reg [31:0] PC;
	output [7:0] ADDRESS, WRITEDATA;
	output reg READ, WRITE;

	//Connections for Register File
	wire [2:0] READREG1, READREG2, WRITEREG;
	wire [7:0] REGOUT1, REGOUT2;
	reg WRITEENABLE;

	//Connections for ALU
	wire [7:0] OPERAND1, OPERAND2, ALURESULT;
	reg [2:0] ALUOP;
	wire ZERO;

	//Connections for negation MUX
	wire [7:0] negatedOp;
	wire [7:0] registerOp;
	reg signSelect;

	//Connections for immediate value MUX
	wire [7:0] IMMEDIATE;
	reg immSelect;

	//PC+4 value and PC value to be updated stored inside CPU
	wire [31:0] PCplus4;
	wire [31:0] PCout;

	//Connections for Jump/Branch Adder
	wire [31:0] TARGET;
	wire [7:0] OFFSET;
	
	//Connections for flow control combinational unit
	reg JUMP;
	reg BRANCH;

	//Connections for flow control MUX
	wire flowSelect;
	
	//Connections to Data memory
	assign ADDRESS = ALURESULT;
	assign WRITEDATA = REGOUT1;
	
	//Connections for data memory MUX
	reg dataSelect;
	wire [7:0] REGIN;

	//Current OPCODE stored in CPU
	reg [7:0] OPCODE;

	//Instantiation of CPU modules
	//8x8 Register File
	//the writeenable signal of the register file is set to HIGH only when the CPU is not busy waiting 

	reg_file my_reg(REGIN, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, (WRITEENABLE & (!BUSYWAIT)), CLK, RESET);
	
	//ALU
	alu my_alu(REGOUT1, OPERAND2, ALURESULT, ZERO, ALUOP);
	
	//2's Complement Unit
	twosComp my_twosComp(REGOUT2, negatedOp);
	
	//Negation MUX (Chooses between +ve and -ve value of REGOUT2)
	mux negationMUX(REGOUT2, negatedOp, signSelect, registerOp);
	
	//Immediate Value MUX (Chooses between immediate value and register value for Operand 2 of ALU)
	mux immediateMUX(registerOp, IMMEDIATE, immSelect, OPERAND2);

	//PC+4 Adder
	pcAdder my_pcAdder(PC, PCplus4);
	
	//Jump/Branch Target Adder
	jumpbranchAdder my_jumpbranchAdder(PCplus4, OFFSET, TARGET);
	
	//Flow Control Combinational Logic Unit (Handles combinational logic for select input of Flow Control MUX)
	flowControl my_flowControl(JUMP, BRANCH, ZERO, flowSelect);
	
	//Flow Control MUX (Chooses between normal PC value or offset value for flow control instructions)
	mux32 flowctrlmux(PCplus4, TARGET, flowSelect, PCout);
	
	//Data Memory MUX
	mux datamux(ALURESULT, READDATA, dataSelect, REGIN);
	
	
	
	
	
	// Control Logic for CPU
	
	
	//PC Update
	always @ ( posedge CLK)
	begin
		if (RESET == 1'b1) #1 PC = 0;		//If RESET signal is HIGH, set PC to zero
		else if (BUSYWAIT == 1'b1);			//If BUSYWAIT signal is HIGH, do nothing (Keep same PC value)
		else #1 PC = PCout;					//Else, write new PC value
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
	
	//READREG1 and READREG2 are used for reading from the register file
	//WRITEREG is used for writing to the register file
	assign READREG1 = INSTRUCTION[15:8];
	assign IMMEDIATE = INSTRUCTION[7:0];
	assign READREG2 = INSTRUCTION[7:0];
	assign WRITEREG = INSTRUCTION[23:16];
	assign OFFSET = INSTRUCTION[23:16];
	
	
	
	//Decoding the instruction
	always @ (INSTRUCTION)
	begin
		
		OPCODE = INSTRUCTION[31:24];	//Mapping the OP-CODE section of the instruction to OPCODE
		
		#1			//1 Time Unit Delay for Decoding process
		
		case (OPCODE)
		
			// loadi: Load immediate value into register
			8'b00000000:	begin
								ALUOP = 3'b000;			// ALU set to forward
								immSelect = 1'b1;		// Select immediate value
								signSelect = 1'b0;		// Use positive value
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;		// Enable register write
							end
		
			// mov: Move value from one register to another
			8'b00000001:	begin
								ALUOP = 3'b000;			// ALU set to forward
								immSelect = 1'b0;		// Select register input
								signSelect = 1'b0;
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;
							end
			
			// add: Add two register values
			8'b00000010:	begin
								ALUOP = 3'b001;			// ALU set to add
								immSelect = 1'b0;
								signSelect = 1'b0;
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;
							end	
		
			// sub: Subtract second register from first
			8'b00000011:	begin
								ALUOP = 3'b001;			// ALU still uses add
								immSelect = 1'b0;
								signSelect = 1'b1;		// Enable two's complement
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;
							end

			// and: Logical AND of two registers
			8'b00000100:	begin
								ALUOP = 3'b010;			// ALU set to AND
								immSelect = 1'b0;
								signSelect = 1'b0;
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;
							end
							
			// or: Logical OR of two registers
			8'b00000101:	begin
								ALUOP = 3'b011;			// ALU set to OR
								immSelect = 1'b0;
								signSelect = 1'b0;
								JUMP = 1'b0;
								BRANCH = 1'b0;
								WRITEENABLE = 1'b1;
							end
			
			// j: Unconditional jump
			8'b00000110:	begin
								JUMP = 1'b1;			// Enable jump
								BRANCH = 1'b0;
								WRITEENABLE = 1'b0;		// No register write
							end
			
			// beq: Branch if equal (zero flag = 1)
			8'b00000111:	begin
								ALUOP = 3'b001;			// Use ALU to compare (subtract)
								immSelect = 1'b0;
								signSelect = 1'b1;		// Two's complement for subtraction
								JUMP = 1'b0;
								BRANCH = 1'b1;			// Enable branch logic
								WRITEENABLE = 1'b0;
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
		
	end
	
endmodule


