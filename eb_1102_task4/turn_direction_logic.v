module turn_direction_logic (
    input wire clk,
    input wire reset,
    input wire [2:0] line_sensor,      // Sensor input: 3-LED array
    output reg [1:0] turn_direction,    // 00: Straight, 01: Left, 10: Right
	 output reg lap_done,
	 output reg Done
);
    reg [4:0] sequence_index = 0; // Index to step through the turn sequence (extended for two laps)
	 reg node_detected = 0;  

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sequence_index <= 0;
//            turn_direction <= 2'b00; // Default direction: Straight
				node_detected <= 0;
        end else begin
            // Detect the rising edge of line_sensor == 3'b111
            if (line_sensor == 3'b111 && node_detected == 0) begin
//                turn_direction <= turn_sequence[sequence_index]; // Update turn direction
                node_detected <= 1; // Mark node detection
                if (sequence_index < 18) 
                    sequence_index <= sequence_index + 1;
            end 
            else if (line_sensor != 3'b111) begin
                node_detected <= 0; // Reset the flag when not on a node
            end
        end
    end
	 
	 always @(*) begin
    case(sequence_index)
        0, 1 ,5,6,9: turn_direction = 2'b00; // Straight
        2, 7, 8 : turn_direction = 2'b10; // Right
        3,10,12,14,15  : turn_direction = 2'b00;
        4, 11, 13, 16, 17 : turn_direction = 2'b10;
        default: turn_direction = 2'b00;
    endcase
	  if(sequence_index == 18) Done = 1;
	  else begin Done=0; end 
	  
	  if(sequence_index == 9) lap_done = 1;
	  else begin lap_done=0; end

end
	 
	 
endmodule
