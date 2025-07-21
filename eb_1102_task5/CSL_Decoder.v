module CSL_Decoder(
    input  wire clk,
    input  wire rx_complete,    // Goes high when a character is received
    input  wire [7:0] rx_msg,     // Received character
    input  wire task_complete,  // Signal from bot indicating task is done
    output reg Go_to_PU,        // Prototyping Unit signal
    output reg Go_to_FU,        // Fabrication Unit signal
    output reg Go_to_WU,        // Warehouse Unit signal
    output reg [1:0] unit_type, // 1 = PU, 2 = FU, 3 = WU
    output reg [4:0] csl_start, // Start point for the unit
    output reg [4:0] csl_end,   // End point for the unit
    output reg [4:0] csl_prev_node_of_end_point // Previous node for the unit end
);

    reg [3:0] state;  // FSM state variable
    reg Go_to_PU_next, Go_to_FU_next, Go_to_WU_next; // Store next request
    reg request_count; // 0 = Home, 1 = One request pending
	 
    // Define fixed start and end points for each unit (example values)
    parameter [4:0] PU_START = 5'd10,
                    PU_END   = 5'd30,
                    PU_PREV  = 5'd28;
    parameter [4:0] FU_START = 5'd24,
                    FU_END   = 5'd19,
                    FU_PREV  = 5'd18;
    parameter [4:0] WU_START = 5'd18,
                    WU_END   = 5'd11,
                    WU_PREV  = 5'd12;

    initial begin
        state = 0;
        request_count = 0;
        Go_to_PU = 0;
        Go_to_FU = 0;
        Go_to_WU = 0;
        Go_to_PU_next = 0;
        Go_to_FU_next = 0;
        Go_to_WU_next = 0;
        unit_type = 0;
        csl_start = 5'd0;
        csl_end   = 5'd0;
        csl_prev_node_of_end_point = 5'd0;
    end

    always @(posedge clk) begin
        if (task_complete) begin
            // Reset request count and move to the next stored request (if any)
            if (request_count == 1) begin
                request_count <= 0;
                Go_to_PU <= Go_to_PU_next;
                Go_to_FU <= Go_to_FU_next;
                Go_to_WU <= Go_to_WU_next;
                Go_to_PU_next <= 0;
                Go_to_FU_next <= 0;
                Go_to_WU_next <= 0;
            end else begin
                request_count <= 0;
                Go_to_PU <= 0;
                Go_to_FU <= 0;
                Go_to_WU <= 0;
            end
        end

        if (rx_complete) begin
            case (state)
                0: if (rx_msg == "C") state <= 1; else state <= 0;
                1: if (rx_msg == "S") state <= 2; else state <= 0;
                2: if (rx_msg == "L") state <= 3; else state <= 0;
                3: if (rx_msg == "-") state <= 4; else state <= 0;
                4: begin
                        if (rx_msg == "P") begin 
                           state <= 5; // PU message
                           unit_type <= 1;
                        end else if (rx_msg == "F") begin
                           state <= 8; // FU message
                           unit_type <= 2;
                        end else if (rx_msg == "W") begin
                           state <= 11; // WU message
                           unit_type <= 3;
                        end else state <= 0;
                   end

                // Prototyping Unit (PU) decoding:
                5: if (rx_msg == "U") state <= 6; else state <= 0;
                6: if (rx_msg == "-") state <= 7; else state <= 0;
                7: if (rx_msg == "#") begin
                        if (request_count == 0) begin
                            Go_to_PU <= 1; 
                            request_count <= 1;
                        end else begin
                            Go_to_PU_next <= 1;
                        end
                        // Assign fixed start/end and previous node for PU.
                        csl_start <= PU_START;
                        csl_end   <= PU_END;
                        csl_prev_node_of_end_point <= PU_PREV;
                        state <= 0;
                   end else state <= 0;

                // Fabrication Unit (FU) decoding:
                8: if (rx_msg == "U") state <= 9; else state <= 0;
                9: if (rx_msg == "-") state <= 10; else state <= 0;
                10: if (rx_msg == "#") begin
                        if (request_count == 0) begin
                            Go_to_FU <= 1; 
                            request_count <= 1;
                        end else begin
                            Go_to_FU_next <= 1;
                        end
                        // Assign fixed start/end and previous node for FU.
                        csl_start <= FU_START;
                        csl_end   <= FU_END;
                        csl_prev_node_of_end_point <= FU_PREV;
                        state <= 0;
                    end else state <= 0;

                // Warehouse Unit (WU) decoding:
                11: if (rx_msg == "U") state <= 12; else state <= 0;
                12: if (rx_msg == "-") state <= 13; else state <= 0;
                13: if (rx_msg == "#") begin
                        if (request_count == 0) begin
                            Go_to_WU <= 1; 
                            request_count <= 1;
                        end else begin
                            Go_to_WU_next <= 1;
                        end
                        // Assign fixed start/end and previous node for WU.
                        csl_start <= WU_START;
                        csl_end   <= WU_END;
                        csl_prev_node_of_end_point <= WU_PREV;
                        state <= 0;
                    end else state <= 0;

                default: state <= 0;
            endcase
        end
    end

endmodule
