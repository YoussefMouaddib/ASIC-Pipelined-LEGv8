`timescale 1ns / 1ps

module ARM_CPU_TB;
    reg clk;
    reg reset_n;
    wire [31:0] debug_out;

    // Instantiate the ARM_CPU
    ARM_CPU uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug_out(debug_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        
        // Reset sequence
        #10 reset_n = 1;

        // Run simulation for some cycles
        #100;

        // Finish simulation
        $finish;
    end

    // Monitor debug output
    initial begin
        $monitor("Time: %0t | PC: %h | Instruction: %h", $time, uut.pc, debug_out);
    end
endmodule
