module black_line_following(
    input wire clk,
    input wire reset,
    input wire [2:0] line_sensor,
    input wire robot_enabled,
    // turn_direction encoding:
    // 2'b11: Straight, 2'b01: Left, 2'b10: Right, 2'b00: U-turn requested
    input wire [1:0] turn_direction,
    input wire pwm_f,
    input wire pwm_b,
    // New input: when asserted, the robot should stop for pick/place.
    input wire activate_pick_operation,
	 input wire activate_place_operation,
    output reg enA, enB,
    output reg in2, in1,
    output reg in4, in3
);

    // Define state codes using 3 bits.
    localparam IDLE           = 3'b000;
    localparam TURN           = 3'b001;
    localparam LINE_FOLLOW    = 3'b010;
    localparam UTURN_REVERSE  = 3'b011;
    localparam UTURN_TURN     = 3'b100;

    // Special value for turn_direction that indicates a U-turn.
    localparam UTURN_DIR      = 2'b00; // now U-turn requested is 2'b00
    // Note: Straight is now defined as 2'b11.

    reg [2:0] current_state, next_state;

    // State register update.
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic.
    // If robot_enabled is false or activate_operation is asserted, remain in IDLE.
    always @(*) begin
        if (!robot_enabled || activate_pick_operation || activate_place_operation)
            next_state = IDLE;
        else begin
            case (current_state)
                IDLE: begin
                    // If a U-turn is requested and the sensor shows a node (3'b111), go to UTURN_REVERSE.
                    if (line_sensor == 3'b111 && turn_direction == UTURN_DIR)
                        next_state = UTURN_REVERSE;
                    else if (line_sensor == 3'b111 || line_sensor == 3'b000)
                        next_state = TURN;
                    else
                        next_state = LINE_FOLLOW;
                end

                TURN: begin
                    // If a U-turn is requested, override and go to UTURN_REVERSE.
                    if (turn_direction == UTURN_DIR)
                        next_state = UTURN_REVERSE;
                    // Otherwise, if sensor indicates a pattern (010, 001, or 100) meaning "go straight",
                    // then return to LINE_FOLLOW.
                    else if ((line_sensor == 3'b010) || (line_sensor == 3'b001) || (line_sensor == 3'b100))
                        next_state = LINE_FOLLOW;
                    else
                        next_state = TURN;
                end

                LINE_FOLLOW: begin
                    if (line_sensor == 3'b111) begin
                        if (turn_direction == UTURN_DIR)
                            next_state = UTURN_REVERSE;
                        else
                            next_state = TURN;
                    end else
                        next_state = LINE_FOLLOW;
                end

                UTURN_REVERSE: begin
                    // In UTURN_REVERSE, drive backward until a trigger pattern appears.
                    if ((line_sensor == 3'b010) || (line_sensor == 3'b100) || (line_sensor == 3'b001))
                        next_state = UTURN_TURN;
                    else
                        next_state = UTURN_REVERSE;
                end

                UTURN_TURN: begin
                    // Rotate in place (e.g., to the right) until alignment is detected (sensor = 010).
                    if (line_sensor == 3'b010)
                        next_state = LINE_FOLLOW;
                    else
                        next_state = UTURN_TURN;
                end

                default: next_state = IDLE;
            endcase
        end
    end

    // Output logic: if activate_operation is high, stop motors.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            enA <= 0; enB <= 0;
            in2 <= 0; in1 <= 0;
            in4 <= 0; in3 <= 0;
        end else begin
            if (activate_pick_operation || activate_place_operation) begin
                // Stop the robot when pick/place operation is active.
                enA <= 0; enB <= 0;
                in2 <= 0; in1 <= 0;
                in4 <= 0; in3 <= 0;
            end else begin
                case (current_state)
                    IDLE: begin
                        enA <= 0; enB <= 0;
                        in2 <= 0; in1 <= 0;
                        in4 <= 0; in3 <= 0;
                    end
                    TURN: begin
                        // In TURN state (non-U-turn), use the provided turn_direction.
                        case (turn_direction)
                            2'b01: begin // Left turn
                                enA <= 0; enB <= pwm_f;
                                in2 <= 0; in1 <= 1;
                                in4 <= 1; in3 <= 0;
                            end
                            2'b10: begin // Right turn
                                enA <= pwm_f; enB <= 0;
                                in2 <= 1; in1 <= 0;
                                in4 <= 0; in3 <= 1;
                            end
                            2'b11: begin // Straight (default)
                                enA <= pwm_f; enB <= pwm_f;
                                in2 <= 1; in1 <= 0;
                                in4 <= 1; in3 <= 0;
                            end
                            default: begin
                                enA <= 0; enB <= 0;
                                in2 <= 0; in1 <= 0;
                                in4 <= 0; in3 <= 0;
                            end
                        endcase
                    end
                    LINE_FOLLOW: begin
                        case (line_sensor)
                            3'b000: begin
                                enA <= 0; enB <= 0;
                                in2 <= 0; in1 <= 0;
                                in4 <= 0; in3 <= 0;
                            end
                            3'b001: begin
                                enA <= pwm_f; enB <= pwm_b;
                                in2 <= 1; in1 <= 0;
                                in4 <= 0; in3 <= 1;
                            end
                            3'b010: begin
                                enA <= pwm_f; enB <=pwm_f;
                                in2 <= 1; in1 <= 0;
                                in4 <= 1; in3 <= 0;
                            end
                            3'b011: begin
                                enA <=pwm_f; enB <= pwm_b;
                                in2 <= 1; in1 <= 0;
                                in4 <= 0; in3 <= 1;
                            end
                            3'b100: begin
                                enA <= pwm_b; enB <= pwm_f;
                                in2 <= 0; in1 <= 1;
                                in4 <= 1; in3 <= 0;
                            end
                            3'b110: begin
                                enA <=pwm_b; enB <= pwm_f;
                                in2 <= 0; in1 <= 1;
                                in4 <= 1; in3 <= 0;
                            end
                            default: begin
                                enA <= pwm_f; enB <= pwm_f;
                                in2 <= 1; in1 <= 0;
                                in4 <= 1; in3 <= 0;
                            end
                        endcase
                    end

                    UTURN_REVERSE: begin
                        // In UTURN_REVERSE, drive in reverse.
                        enA <= pwm_b; enB <= pwm_b;
                        // Set motor directions to reverse.
                        in2 <= 0; in1 <= 1;
                        in4 <= 0; in3 <= 1;
                    end

                    UTURN_TURN: begin
                        // In UTURN_TURN, rotate in place (here, for example, a right turn).
                        enA <= pwm_f; enB <= pwm_f;
                        in2 <= 1; in1 <= 0;
                        in4 <= 0; in3 <= 1;
                    end

                    default: begin
                        enA <= 0; enB <= 0;
                        in2 <= 0; in1 <= 0;
                        in4 <= 0; in3 <= 0;
                    end
                endcase
            end
        end
    end

endmodule
