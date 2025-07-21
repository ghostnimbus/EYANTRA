module SAM_Decoder(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx_complete,   // Asserted when a new character is available
    input  wire [7:0] rx_msg,        // Received character
    input  wire       task_complete, // Asserted by external controller when current task is done
    input  wire [1:0] unit_type,     // 1 = PU, 2 = FU, 3 = WU
    output reg [4:0]  pick_node,     // Computed pick node address
    output reg [4:0]  place_node,    // Computed place node address
	 output reg [1:0] subunit,
    output reg        action_valid   // Asserted when a valid action is available
);

  // FSM State Encoding
  localparam S_IDLE        = 0,
             S_A           = 1,
             S_M           = 2,
             S_DASH1     = 3,
             S_1         = 4,
             S_DOT1      = 5,
             S_TOKEN1_0  = 6,
             S_TOKEN1_1  = 7,
             S_TOKEN1_2  = 8,
             S_DASH2     = 9,
             S_2         = 10,
             S_DOT2      = 11,
             S_TOKEN2_0  = 12,
             S_TOKEN2_1  = 13,
             S_TOKEN2_2  = 14,
             S_DASH3     = 15,
             S_3         = 16,
             S_DOT3      = 17,
             S_TOKEN3_0  = 18,
             S_TOKEN3_1  = 19,
             S_TOKEN3_2  = 20,
             S_DASH4     = 21,
             S_HASH      = 22,
             S_PROCESS   = 23,
             S_WAIT      = 24;

  // Node Constants for PU
  parameter [4:0] PSU1 = 8'd27,
                  PSU2 = 8'd29,
                  PSU3 = 8'd31;
						
  // Node Constants for MU						
  parameter [4:0] MU1  = 8'd9,
                  MU2  = 8'd8,
                  MU3  = 8'd7;
						
  // Node Constants for SU						
  parameter [4:0] SU1  = 8'd5,
                  SU2  = 8'd4,
						SU3  = 8'd3;
						
  // Node Constants for FU
  parameter [4:0] FSU1 = 8'd25,
                  FSU2 = 8'd22,
                  FSU3 = 8'd20;
						
  // Node Constants for WU
  parameter [4:0] WSU1 = 8'd17,
                  WSU2 = 8'd15,
                  WSU3 = 8'd13;
						
//------------------------------------------------------						
// Functions to decode a token into a node value
//------------------------------------------------------
function [7:0] decode_MU;
  input [23:0] token;
  begin
    if (token == "MU1")
      decode_MU = MU1;
    else if (token == "MU2")
      decode_MU = MU2;
    else if (token == "MU3")
      decode_MU = MU3;
    else
      decode_MU = 8'h00;
  end
endfunction

function [7:0] decode_SU;
  input [23:0] token;
  begin
    if (token == "SU1")
      decode_SU = SU1;
    else if (token == "SU2")
      decode_SU = SU2;
    else if (token == "SU3")
      decode_SU = SU3;
    else
      decode_SU = 8'h00;
  end
endfunction

  // FSM state register and subunit counter
  reg [4:0] state;
//  reg [1:0] subunit; // 1, 2, or 3

  // Registers to store 3-character tokens for each subunit
  reg [7:0] token1_0, token1_1, token1_2;
  reg [7:0] token2_0, token2_1, token2_2;
  reg [7:0] token3_0, token3_1, token3_2;

  // Main FSM
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state        <= S_IDLE;
      subunit      <= 0;
      action_valid <= 0;
      pick_node    <= 8'h00;
      place_node   <= 8'h00;
      token1_0     <= 8'h00; token1_1 <= 8'h00; token1_2 <= 8'h00;
      token2_0     <= 8'h00; token2_1 <= 8'h00; token2_2 <= 8'h00;
      token3_0     <= 8'h00; token3_1 <= 8'h00; token3_2 <= 8'h00;
    end else begin
      case (state)
        // ===== Message Reception =====
        S_IDLE: begin
          action_valid <= 0;
          if (rx_complete) begin
            if (rx_msg == "S")
              state <= S_A;
				else
				  state <= S_IDLE;
          end
          // Otherwise hold S_IDLE
        end
        S_A: begin
          if (rx_complete) begin
            if (rx_msg == "A")
              state <= S_M;
				else
				  state <= S_IDLE;
          end
        end
        S_M: begin
          if (rx_complete) begin
            if (rx_msg == "M")
              state <= S_DASH1;
				else
				  state <= S_IDLE;
          end
        end
        S_DASH1: begin
          if (rx_complete) begin
            if (rx_msg == "-")
              state <= S_1;
				else
				  state <= S_IDLE;
          end
        end
        S_1: begin
          if (rx_complete) begin
            if (rx_msg == "1")
              state <= S_DOT1;
				else
				  state <= S_IDLE;
          end
        end
        S_DOT1: begin
          if (rx_complete) begin
            if (rx_msg == ".")
              state <= S_TOKEN1_0;
				else
				  state <= S_IDLE;
          end
        end
        S_TOKEN1_0: begin
          if (rx_complete) begin
            token1_0 <= rx_msg;
            state <= S_TOKEN1_1;
          end
        end
        S_TOKEN1_1: begin
          if (rx_complete) begin
            token1_1 <= rx_msg;
            state <= S_TOKEN1_2;
          end
        end
        S_TOKEN1_2: begin
          if (rx_complete) begin
            token1_2 <= rx_msg;
            state <= S_DASH2;
          end
        end
        S_DASH2: begin
          if (rx_complete) begin
            if (rx_msg == "-")
              state <= S_2;
				else
				  state <= S_IDLE;
          end
        end
        S_2: begin
          if (rx_complete) begin
            if (rx_msg == "2")
              state <= S_DOT2;
				else
				  state <= S_IDLE;
          end
        end
        S_DOT2: begin
          if (rx_complete) begin
            if (rx_msg == ".")
              state <= S_TOKEN2_0;
				else
				  state <= S_IDLE;
          end
        end
        S_TOKEN2_0: begin
          if (rx_complete) begin
            token2_0 <= rx_msg;
            state <= S_TOKEN2_1;
          end
        end
        S_TOKEN2_1: begin
          if (rx_complete) begin
            token2_1 <= rx_msg;
            state <= S_TOKEN2_2;
          end
        end
        S_TOKEN2_2: begin
          if (rx_complete) begin
            token2_2 <= rx_msg;
            state <= S_DASH3;
          end
        end
        S_DASH3: begin
          if (rx_complete) begin
            if (rx_msg == "-")
              state <= S_3;
				else
				  state <= S_IDLE;
          end
        end
        S_3: begin
          if (rx_complete) begin
            if (rx_msg == "3")
              state <= S_DOT3;
				else
				  state <= S_IDLE;
          end
        end
        S_DOT3: begin
          if (rx_complete) begin
            if (rx_msg == ".")
              state <= S_TOKEN3_0;
				else
				  state <= S_IDLE;
          end
        end
        S_TOKEN3_0: begin
          if (rx_complete) begin
            token3_0 <= rx_msg;
            state <= S_TOKEN3_1;
          end
        end
        S_TOKEN3_1: begin
          if (rx_complete) begin
            token3_1 <= rx_msg;
            state <= S_TOKEN3_2;
          end
        end
        S_TOKEN3_2: begin
          if (rx_complete) begin
            token3_2 <= rx_msg;
            state <= S_DASH4;
          end
        end
        S_DASH4: begin
          if (rx_complete) begin
            if (rx_msg == "-")
              state <= S_HASH;
				else
				  state <= S_IDLE;
          end
        end
        S_HASH: begin
          if (rx_complete) begin
            if (rx_msg == "#") begin
              state   <= S_PROCESS;
              subunit <= 1; // Begin processing with subunit 1
            end else
				  state <= S_IDLE;
          end
        end

        // ===== Process Each Subunit’s Action =====
S_PROCESS: begin
  case (subunit)
    1: begin
         // Skip if token equals "XXX"
         if ({token1_0, token1_1, token1_2} == "XXX") begin
             action_valid <= 0;
             subunit <= subunit + 1;
         end else begin
             // Check token prefix (first two characters)
             if ({token1_0, token1_1} == "MU") begin
                 // Use token for pick, fixed node for place
                 place_node  <= decode_MU({token1_0, token1_1, token1_2});
                 case(unit_type)
                   2'd1: pick_node <= 27;  // PU fixed for subunit 1
                   2'd2: pick_node <= 25;  // FU fixed for subunit 1
                   2'd3: pick_node <= 17;  // WU fixed for subunit 1
                 endcase
             end
             else if ({token1_0, token1_1} == "SU") begin
                 // Use token for place, fixed node for pick
                 pick_node <= decode_SU({token1_0, token1_1, token1_2});
                 case(unit_type)
                   2'd1: place_node <= 27;
                   2'd2: place_node <= 25;
                   2'd3: place_node <= 17;
                 endcase
             end
             else begin
                 pick_node  <= 8'h00;
                 place_node <= 8'h00;
             end
             action_valid <= 1;
             state <= S_WAIT;
         end
       end

    2: begin
         if ({token2_0, token2_1, token2_2} == "XXX") begin
             action_valid <= 0;
             subunit <= subunit + 1;
         end else begin
             if ({token2_0, token2_1} == "MU") begin
                 place_node  <= decode_MU({token2_0, token2_1, token2_2});
                 case(unit_type)
                   2'd1: pick_node <= 29;
                   2'd2: pick_node <= 22;
                   2'd3: pick_node <= 15;
                 endcase
             end
             else if ({token2_0, token2_1} == "SU") begin
                 pick_node <= decode_SU({token2_0, token2_1, token2_2});
                 case(unit_type)
                   2'd1: place_node <= 29;
                   2'd2: place_node <= 22;
                   2'd3: place_node <= 15;
                 endcase
             end
             else begin
                 pick_node  <= 8'h00;
                 place_node <= 8'h00;
             end
             action_valid <= 1;
             state <= S_WAIT;
         end
       end

    3: begin
         if ({token3_0, token3_1, token3_2} == "XXX") begin
             action_valid <= 0;
             subunit <= subunit + 1;
         end else begin
             if ({token3_0, token3_1} == "MU") begin
                 place_node  <= decode_MU({token3_0, token3_1, token3_2});
                 case(unit_type)
                   2'd1: pick_node <= 31;
                   2'd2: pick_node <= 20;
                   2'd3: pick_node <= 13;
                 endcase
             end
             else if ({token3_0, token3_1} == "SU") begin
                 pick_node <= decode_SU({token3_0, token3_1, token3_2});
                 case(unit_type)
                   2'd1: place_node <= 31;
                   2'd2: place_node <= 20;
                   2'd3: place_node <= 13;
                 endcase
             end
             else begin
                 pick_node  <= 8'h00;
                 place_node <= 8'h00;
             end
             action_valid <= 1;
             state <= S_WAIT;
         end
       end

    default: begin
         state        <= S_IDLE;
         subunit      <= 0;
         action_valid <= 0;
    end
  endcase
end

        // ===== Wait for task_complete before processing the next subunit =====
        S_WAIT: begin
          if (task_complete) begin
            action_valid <= 0;
            subunit <= subunit + 1;
            if (subunit < 4)
              state <= S_PROCESS;
            else
              state <= S_IDLE; // All subunits processed
          end
        end

        default: state <= S_IDLE;
      endcase
    end
  end

endmodule
