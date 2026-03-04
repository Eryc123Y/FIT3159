`ifndef ADDER_SUBTRACTOR_16BIT_OVERFLOW_V
`define ADDER_SUBTRACTOR_16BIT_OVERFLOW_V

`include "arithmetics/ripple_carry_adder_16bit.v"

/**
 * 16-bit Adder-Subtractor with Overflow Detection
 * 
 * This module implements a versatile arithmetic unit that can perform both
 * addition and subtraction on 16-bit signed or unsigned numbers, with
 * comprehensive overflow detection for different number representations.
 * 
 * Key Features:
 * - Addition and subtraction in one module
 * - Signed overflow detection (2's complement)
 * - Unsigned overflow detection 
 * - Uses 2's complement arithmetic for subtraction
 * 
 * Operation Principle:
 * Addition: A + B
 * Subtraction: A + (~B) + 1 (2's complement of B)
 */
module AdderSubtractor16BitOverflow(
    input [15:0] a, b,           // 16-bit operands
    input sub,                   // Operation select: 0=ADD, 1=SUBTRACT
    output [15:0] result,        // 16-bit result
    output carry_out,            // Carry out from MSB (for unsigned overflow)
    output signed_overflow,      // Overflow flag for signed arithmetic
    output unsigned_overflow,    // Overflow flag for unsigned arithmetic
    output zero_flag,            // Result is zero
    output negative_flag         // Result is negative (MSB = 1)
);

    // Internal signals for 2's complement conversion
    wire [15:0] b_complement;    // B or ~B depending on operation
    wire [15:0] sum;             // Raw sum from adder
    wire cout;                   // Carry out from adder
    
    // Generate 2's complement of B for subtraction
    // For addition: b_complement = b
    // For subtraction: b_complement = ~b (1's complement)
    assign b_complement = sub ? ~b : b;
    
    // The main arithmetic unit - uses our 16-bit ripple carry adder
    // For subtraction, we add 1 via the carry input to complete 2's complement
    RippleCarryAdder16Bit adder(
        .a(a), 
        .b(b_complement), 
        .cin(sub),           // cin=1 for subtraction (adds 1 to complete 2's complement)
        .sum(sum), 
        .cout(cout)
    );
    
    // Output assignments
    assign result = sum;
    assign carry_out = cout;
    
    // Flag generation with detailed explanations
    
    /**
     * Zero Flag Detection
     * Result is zero when all bits are 0
     */
    assign zero_flag = (result == 16'h0000);
    
    /**
     * Negative Flag Detection
     * In 2's complement, MSB indicates sign:
     * MSB = 0: Positive number
     * MSB = 1: Negative number
     */
    assign negative_flag = result[15];
    
    /**
     * Unsigned Overflow Detection
     * For unsigned numbers (0 to 65535):
     * - Addition overflow: carry_out = 1
     * - Subtraction overflow: carry_out = 0 (borrow occurred)
     * 
     * Examples:
     * 65535 + 1 = 65536 (exceeds 16-bit range) → carry_out = 1
     * 0 - 1 = -1 (invalid for unsigned) → carry_out = 0
     */
    assign unsigned_overflow = sub ? ~carry_out : carry_out;
    
    /**
     * Signed Overflow Detection (2's Complement)
     * For signed numbers (-32768 to +32767):
     * 
     * Overflow occurs when the result doesn't fit in the valid range.
     * This happens when adding two numbers of the same sign produces
     * a result with the opposite sign.
     * 
     * Detection Logic:
     * - Addition: (A positive + B positive = Result negative) OR
     *            (A negative + B negative = Result positive)
     * - Subtraction: (A positive - B negative = Result negative) OR
     *               (A negative - B positive = Result positive)
     * 
     * Simplified detection:
     * Overflow = (A_sign == B_effective_sign) AND (A_sign != Result_sign)
     * 
     * Where B_effective_sign is:
     * - B_sign for addition
     * - ~B_sign for subtraction (since we're effectively adding -B)
     */
    wire a_sign, b_sign, b_effective_sign, result_sign;
    
    assign a_sign = a[15];                    // Sign of A
    assign b_sign = b[15];                    // Sign of B
    assign b_effective_sign = sub ? ~b_sign : b_sign;  // Effective sign of B
    assign result_sign = result[15];          // Sign of result
    
    // Overflow detection: same input signs but different result sign
    assign signed_overflow = (a_sign == b_effective_sign) && (a_sign != result_sign);
    
    /**
     * Alternative signed overflow detection (equivalent):
     * This method checks the carry into and out of the MSB
     * Overflow = carry_into_MSB XOR carry_out_of_MSB
     */
    // wire carry_into_msb = /* would need internal access to adder */;
    // assign signed_overflow_alt = carry_into_msb ^ carry_out;

endmodule

`endif // ADDER_SUBTRACTOR_16BIT_OVERFLOW_V
