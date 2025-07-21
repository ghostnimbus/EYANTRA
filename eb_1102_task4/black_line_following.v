module black_line_following(
    input wire clk,
    input wire reset,
    input wire [2:0] line_sensor,
    input wire robot_enabled,
    input wire [1:0] turn_direction,
    input pwm_f,
    input pwm_b,
    output reg enA, enB,
    output reg in2, in1,
    output reg in4, in3
);

    parameter IDLE = 2'b00;
    parameter TURN = 2'b01;
    parameter LINE_FOLLOW = 2'b10;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (robot_enabled && line_sensor == 3'b111)
                    next_state = TURN;
                else if (robot_enabled)
                    next_state = LINE_FOLLOW;
                else
                    next_state = IDLE;
            end
            TURN: begin
                if (line_sensor == 3'b010 || 3'b001)
                    next_state = LINE_FOLLOW;
                else
                    next_state = TURN;
            end
            LINE_FOLLOW: begin
                if (!robot_enabled)
                    next_state = IDLE;
                else if (line_sensor == 3'b111)
                    next_state = TURN;
                else
                    next_state = LINE_FOLLOW;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            enA = 0; enB = 0;
            in2 = 0; in1 = 0;
            in4 = 0; in3 = 0;
        end else begin
            case (current_state)
                IDLE: begin
                    enA = 0; enB = 0;
                    in2 = 0; in1 = 0;
                    in4 = 0; in3 = 0;
                end
                TURN: begin
                    case (turn_direction)
                        2'b01: begin
                            enA = 0; enB = pwm_f;
                            in2 = 0; in1 = 1;
                            in4 = 1; in3 = 0;
                        end
                        2'b10: begin
                            enA = pwm_f; enB = 0;
                            in2 = 1; in1 = 0;
                            in4 = 0; in3 = 1;
                        end
                        2'b00: begin
                            enA = pwm_f; enB = pwm_f;
                            in2 = 1; in1 = 0;
                            in4 = 1; in3 = 0;
                        end
                        default: begin
                            enA = 0; enB = 0;
                            in2 = 0; in1 = 0;
                            in4 = 0; in3 = 0;
                        end
                    endcase
                end
                LINE_FOLLOW: begin
                    case (line_sensor)
                        3'b000: begin
                            enA = 0; enB = 0;
                            in2 = 0; in1 = 0;
                            in4 = 0; in3 = 0;
                        end
                        3'b001: begin
                            enA = pwm_f; enB = pwm_b;
                            in2 = 1; in1 = 0;
                            in4 = 0; in3 = 1;
                        end
                        3'b010: begin
                            enA = pwm_f; enB = pwm_f;
                            in2 = 1; in1 = 0;
                            in4 = 1; in3 = 0;
                        end
                        3'b011: begin
                            enA = pwm_f; enB = pwm_b;
                            in2 = 1; in1 = 0;
                            in4 = 0; in3 = 1;
                        end
                        3'b100: begin
                            enA = pwm_b; enB = pwm_f;
                            in2 = 0; in1 = 1;
                            in4 = 1; in3 = 0;
                        end
                        3'b110: begin
                            enA = pwm_b; enB = pwm_f;
                            in2 = 0; in1 = 1;
                            in4 = 1; in3 = 0;
                        end
                        3'b111: begin
                            enA = pwm_f; enB = pwm_f;
                            in2 = 0; in1 = 0;
                            in4 = 0; in3 = 0;
                        end
                        default: begin
                            enA = pwm_f; enB = pwm_f;
                            in2 = 1; in1 = 0;
                            in4 = 1; in3 = 0;
                        end
                    endcase
                end
                default: begin
                    enA = pwm_f; enB = pwm_f;
                    in2 = 0; in1 = 0;
                    in4 = 0; in3 = 0;
                end
            endcase
        end
    end
endmodule
