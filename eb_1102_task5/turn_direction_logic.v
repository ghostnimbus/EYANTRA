module turn_direction_logic (
    input  wire         clk,
    input  wire         reset,
    input  wire [2:0]   line_sensor,     // 3-LED array input
    input  wire [23:0]  node_directions, // 32-bit variable path (each 2-bit field)
    input  wire [3:0]   path_length,     // Number of valid nodes in node_directions
    // Signals to select a hardcoded unit path:
    input  wire         Go_to_PU,
    input  wire         Go_to_FU,
    input  wire         Go_to_WU,
	 input wire [4:0] prev_node_of_end_point,
    output reg  [1:0]   turn_direction,  // Output direction (2 bits)
    output reg          arrived,        // Asserted when variable path finishes
    output reg          unit_lap_done             // Asserted when hardcoded path finishes
);

  // Direction encoding (for example):
  // LEFT     = 2'b01, 
  // STRAIGHT = 2'b11, 
  // RIGHT    = 2'b10

  //-------------------------------------------------------------------------
  // Hardcoded Sequences for different units.
  //-------------------------------------------------------------------------
  parameter [2:0] PU_path_length = 4; // number of nodes in PU hardcoded sequence
  parameter [2:0] FU_path_length = 4;
  parameter [2:0] WU_path_length = 4;

  // Example hardcoded sequences (each 2-bit field represents a turn):
  // For instance, PU_seq: STRAIGHT, LEFT, RIGHT, STRAIGHT, LEFT, RIGHT, STRAIGHT, STRAIGHT.
  // (These are given as concatenated 2-bit values; note that the LSB 2 bits are for the first node.)
  reg [7:0] PU_seq, FU_seq, WU_seq;
  initial begin
    PU_seq = {(prev_node_of_end_point == 0) ? 2'b01 : 2'b10, 2'b11, 2'b11, 2'b11};
    FU_seq = {(prev_node_of_end_point == 10) ? 2'b11 : 2'b10, 2'b10, 2'b11, 2'b10};
    WU_seq = {(prev_node_of_end_point == 21) ? 2'b11 : 2'b10, 2'b11, 2'b11, 2'b11};
  end

  //-------------------------------------------------------------------------
  // Internal registers
  //-------------------------------------------------------------------------
  // Mode: 0 = variable (node_directions) mode, 1 = hardcoded mode
  reg mode;
  // Index into variable path (each index selects 2 bits from node_directions)
  reg [3:0] var_index;
  // Index into hardcoded sequence
  reg [3:0] hard_index;
  // Flag to indicate we've already detected a node (to avoid re-counting)
  reg node_detected;

  //-------------------------------------------------------------------------
  // Main state/update logic
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      mode           <= 1'b0;         // default: variable mode
      var_index      <= 4'd0;
      hard_index     <= 4'd0;
      turn_direction <= 2'b10;
      node_detected  <= 1'b0;
      arrived       <= 1'b0;
      unit_lap_done    <= 1'b0;
    end else begin
      // Detect node when line_sensor is all high (3'b111) and not already flagged.
      if (line_sensor == 3'b111 && !node_detected) begin
        node_detected <= 1'b1; // Mark that node has been detected

        // Check if any Go_to signal is high. If so, override variable mode.
        if (Go_to_PU || Go_to_FU || Go_to_WU) begin
          mode <= 1'b1; // hardcoded mode
          // (On mode switch, you may choose to reset hard_index if desired)
          // Here we assume hard_index remains continuous for the current unit.
          if (Go_to_PU) begin
            // Extract the 2-bit field from PU_seq corresponding to hard_index.
            turn_direction <= PU_seq[(hard_index*2) +: 2];
          end else if (Go_to_FU) begin
            turn_direction <= FU_seq[(hard_index*2) +: 2];
          end else if (Go_to_WU) begin
            turn_direction <= WU_seq[(hard_index*2) +: 2];
          end
          hard_index <= hard_index + 1;
          // If we've reached the end of the hardcoded sequence, assert Done.
          if ((Go_to_PU && (hard_index + 1 == PU_path_length)) ||
              (Go_to_FU && (hard_index + 1 == FU_path_length)) ||
              (Go_to_WU && (hard_index + 1 == WU_path_length)))
            unit_lap_done <= 1;
          else
            unit_lap_done <= 0;
        end else begin
          // Otherwise, remain in variable mode.
          mode <= 1'b0;
          if (var_index < path_length) begin
            turn_direction <= node_directions[var_index*2 +: 2];
            var_index <= var_index + 1;
            arrived <= 0;
          end else begin
            // Variable sequence complete.
            arrived <= 1;
            unit_lap_done <= 0; // Or you may decide Done here if appropriate.
          end
        end

      end else if (line_sensor != 3'b111) begin
        node_detected <= 1'b0;
		  var_index <= 0;
      end
      // (Optional: add logic to revert mode back to variable mode after a hardcoded run is done.)
    end
  end

endmodule

