`timescale 1ns/100ps

/**
 * DATA CACHE MODULE
 * Implements a direct-mapped write-back cache with 8 blocks (32B each)
 * Interfaces with CPU and main memory
 */

module data_cache(
    clock, reset, 
    read, write, address, cpu_writeData, 
    cpu_readData, busywait,
    mem_read, mem_write, mem_address, 
    mem_writedata, mem_readdata, mem_busywait
);
    
    // Input/output declarations
    input clock, reset;
    input [7:0] address, cpu_writeData;
    input write, read;
    output reg [7:0] cpu_readData;
    output reg busywait;

    // Memory interface
    input [31:0] mem_readdata;
    input mem_busywait;
    output reg [31:0] mem_writedata;
    output reg [5:0] mem_address;
    output reg mem_read, mem_write;

    // Cache parameters
    wire [2:0] tag, index;
    wire [1:0] offset;
    wire hit, dirty;
    reg tagmatch;
    reg cache_write;
    reg pending_write;  // To hold write requests during misses

    // Cache memory structure
    reg [31:0] cacheblock_array [7:0];
    reg dirty_array [7:0];
    reg valid_array [7:0];
    reg [2:0] tagArray [7:0];

    // Address decomposition
    assign #1 tag = address[7:5]; // Extract tag bits
    assign #1 index = address[4:2]; // Cache block index
    assign #1 offset = address[1:0]; // Byte select
    assign #1 dirty = dirty_array[index]; // Dirty bit for current block

    // Hit detection
    // Tag comparison with 0.9ns delay (matches cache access time)
    always @(*) begin
        #0.9  // Matching the tag comparison delay
        tagmatch = (tag == tagArray[index]); // Compare tags
    end
    // Hit occurs when tags match and block is valid
    assign hit = tagmatch & valid_array[index];

    // Read data output
    // Combinational read path - outputs data immediately

    
    always @(*) begin
        
        if (hit && !busywait) begin  // Only output on valid hits
        
        case (offset)
            0: cpu_readData = cacheblock_array[index][7:0];
            1: cpu_readData = cacheblock_array[index][15:8];
            2: cpu_readData = cacheblock_array[index][23:16];
            3: cpu_readData = cacheblock_array[index][31:24];
        endcase
        end
        else begin
            cpu_readData = 8'bx;  // Or hold previous value
    end
    end

    // Cache write handling (only on hits)
    always @(posedge clock) begin
        if (cache_write && hit) begin
            case (offset) // Update appropriate byte
                0: cacheblock_array[index][7:0] <= cpu_writeData;
                1: cacheblock_array[index][15:8] <= cpu_writeData;
                2: cacheblock_array[index][23:16] <= cpu_writeData;
                3: cacheblock_array[index][31:24] <= cpu_writeData;
            endcase
            dirty_array[index] <= 1; // Mark block as dirty
            cache_write <= 0; // Clear write flag
        end
    end

    // =============================================
    // CACHE CONTROLLER FINITE STATE MACHINE
    // =============================================

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;
    reg [7:0] saved_address;
    reg [7:0] saved_writeData;
    reg saved_write;

    // State transition logic
    always @(*) begin
        case (state)
            IDLE:

                // Start memory access on cache miss
                if ((read || write) && !hit) begin
                    if (dirty)
                        next_state = MEM_WRITE; // Write back dirty block first
                    else
                        next_state = MEM_READ; // Read directly from memory
                end
                else
                    next_state = IDLE; // Stay idle
            
            MEM_READ:
                // Wait for memory response
                if (!mem_busywait)
                    next_state = IDLE;
                else
                    next_state = MEM_READ;
                    
            MEM_WRITE:
                // After writeback, transition to read
                if (!mem_busywait)
                    next_state = MEM_READ;
                else
                    next_state = MEM_WRITE;
        endcase
    end

    // FSM output logic
    always @(*) begin
        case(state)
            IDLE: begin
                // Default inactive state
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'bx;
                mem_writedata = 32'bx;
            end
         
            MEM_READ: begin
                // Memory read state
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index}; // Requested block address
                mem_writedata = 32'bx; // Not writing
            end
            
            MEM_WRITE: begin
                // Memory write state
                mem_read = 0;
                mem_write = 1;
                mem_address = {tagArray[index], index}; // Block to write back
                mem_writedata = cacheblock_array[index]; // Data to write
            end
        endcase
    end

    // FSM sequential logic and cache updates
    integer i;
    always @(posedge clock, posedge reset) begin
        if (reset) begin
            // Reset all cache states
            state <= IDLE;
            for (i = 0; i < 8; i = i+1) begin
                dirty_array[i] <= 0; // Clear dirty bits
                valid_array[i] <= 0; // Invalidate all blocks
            end
            
        end
        else begin
            // Normal operation
            state <= next_state;
            
            // Save write requests during misses
            if (state == IDLE && write && !hit) begin
                saved_address <= address;
                saved_writeData <= cpu_writeData;
                saved_write <= 1;
            end
            
            // Handle memory read completion
            if (state == MEM_READ && !mem_busywait) begin

                cacheblock_array[index] <= mem_readdata;
                tagArray[index] <= tag;
                valid_array[index] <= 1; // Mark as valid
                dirty_array[index] <= 0; // Now clean
                
                // Complete pending write if exists
                if (saved_write && index == saved_address[4:2]) begin
                    case (saved_address[1:0])
                        0: cacheblock_array[index][7:0] <= saved_writeData;
                        1: cacheblock_array[index][15:8] <= saved_writeData;
                        2: cacheblock_array[index][23:16] <= saved_writeData;
                        3: cacheblock_array[index][31:24] <= saved_writeData;
                    endcase


                    dirty_array[index] <= 1; // Mark as dirty again
                    saved_write <= 0; // Clear pending write
                end
                
            end
            
            // Handle memory write completion
            if (state == MEM_WRITE && !mem_busywait) begin
                dirty_array[index] <= 0; // Block is now clean
            end
            
        end
    end

    // Busywait generation
    always @(*) begin
        if (reset)
            busywait = 0; // Inactive during reset
        else if ((read || write) && !hit)
            busywait = 1; // Stall on cache miss
        else if (state != IDLE)
            busywait = 1; // Stall during memory ops
        else if (write && hit)
            busywait = 0;  // Write hit completes immediately
        else
            busywait = (read || write) ? !hit : 0; // Default case
    end

    // Cache write signal generation (only for hits)
    always @(*) begin
        if (write && hit && state == IDLE)
            cache_write = 1; // Enable cache write
        else
            cache_write = 0; // Default disabled
    end

endmodule