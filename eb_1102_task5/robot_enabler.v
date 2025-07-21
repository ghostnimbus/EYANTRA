module robot_enabler(
    input wire clk,
    input wire reset,
    input wire csl_valid,   // Trigger to enable robot (one-pulse expected)
    input wire resolved,    // When high, robot is disabled
    output reg robot_enabled  // Robot enabled output
);

  always @(posedge clk or posedge reset) begin
    if (reset)
      robot_enabled <= 1'b0;
    else if (resolved)
      robot_enabled <= 1'b0; // Disable robot if resolved is high
    else if (csl_valid)
      robot_enabled <= 1'b1; // Enable robot on csl_valid trigger
    // Otherwise, maintain the previous state.
  end

endmodule
