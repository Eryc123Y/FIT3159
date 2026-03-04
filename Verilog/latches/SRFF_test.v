`include "logic-gates/nand.v"
`include "logic-gates/others.v"
`include "latches/SRFF.v"

module SRFF_test;
    // Inputs
    reg R, clock, S;
    
    // Outputs
    wire Q, Q_bar;
    
    // Instantiate the Unit Under Test (UUT)
    SRFF uut (
        .R(R),
        .clock(clock),
        .S(S),
        .Q(Q),
        .Q_bar(Q_bar)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10 time unit period
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        R = 0;
        S = 0;
        
        // Wait for global reset
        #10;
        
        $display("Time\tR\tS\tclock\tQ\tQ_bar");
        $display("----\t-\t-\t-----\t-\t-----");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, R, S, clock, Q, Q_bar);
        
        // Test Case 1: No operation (R=0, S=0)
        #10;
        R = 0; S = 0;
        #20;
        
        // Test Case 2: Set operation (R=0, S=1)
        R = 0; S = 1;
        #20;
        
        // Test Case 3: Hold state (R=0, S=0) after set
        R = 0; S = 0;
        #20;
        
        // Test Case 4: Reset operation (R=1, S=0)
        R = 1; S = 0;
        #20;
        
        // Test Case 5: Hold state (R=0, S=0) after reset
        R = 0; S = 0;
        #20;
        
        // Test Case 6: Set again
        R = 0; S = 1;
        #20;
        
        // Test Case 7: Reset again
        R = 1; S = 0;
        #20;
        
        // Test Case 8: Skip invalid state (R=1, S=1) 
        // R = 1; S = 1;  // Commented out - ignoring this case
        // #20;
        
        // Test Case 9: Return to normal operation
        R = 0; S = 0;
        #20;
        
        // Additional test: Multiple clock cycles with different inputs
        R = 0; S = 1;
        #10;
        R = 0; S = 0;
        #30;
        R = 1; S = 0;
        #10;
        R = 0; S = 0;
        #30;
        
        $display("\nTest completed!");
        $display("SR Flip-Flop behavior summary:");
        $display("- When S=1, clock=1: Q should be set to 1");
        $display("- When R=1, clock=1: Q should be reset to 0");
        $display("- When S=0, R=0: Q should hold its previous state");
        $display("- Clock controls when changes take effect");
        
        $finish;
    end
    
    // Remove invalid state monitoring - ignoring S=1, R=1 case
    // always @(posedge clock) begin
    //     if (S && R) begin
    //         $display("WARNING: Invalid state detected at time %0t - both S and R are high!", $time);
    //     end
    // end
    
    // Check for proper complementary outputs (ignore when both S and R are high)
    always @(*) begin
        if (Q === Q_bar && !(S && R)) begin
            $display("ERROR: Q and Q_bar are not complementary at time %0t", $time);
        end
    end
    
endmodule
