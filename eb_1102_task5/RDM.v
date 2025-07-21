module RDM(
    input  wire         clk,         // Clock
    input  wire         rst,         // Asynchronous reset (active high)
    input  wire         send_msg,    // Trigger to send the RDM message
    input  wire [4:0]   place_node,  // Place node value (determines location)
    input  wire         tx_done,     // Indicates that the last character has been transmitted
    output reg          tx_start,    // Pulse to start transmission of a character
	 output reg RDM_active,
    output reg [7:0]    tx_msg       // Transmitted character (ASCII)
);

    //--------------------------------------------------------------------------
    // Node Constants (using 5-bit values expressed as 8-bit hex literals)
    //--------------------------------------------------------------------------
    localparam [4:0] 
      // PU nodes
      PSU1_const = 8'd27,
      PSU2_const = 8'd29,
      PSU3_const = 8'd31,
      // MU nodes (maintenance unit)
      MU1_const  = 8'd09,
      MU2_const  = 8'd08,
      MU3_const  = 8'd07,
      // FU nodes
      FSU1_const = 8'd25,
      FSU2_const = 8'd22,
      FSU3_const = 8'd20,
      // WU nodes
      WSU1_const = 8'd17,
      WSU2_const = 8'd15,
      WSU3_const = 8'd13;

    //--------------------------------------------------------------------------
    // FSM State Encoding
    //--------------------------------------------------------------------------
    localparam S_IDLE = 0,
               S_LOAD = 1,
               S_TX   = 2,
               S_WAIT = 3,
               S_DONE = 4;
               
    reg [2:0] state;
    reg [3:0] index;            // Current character index in the message
    reg [3:0] message_length;   // Total number of characters in the message

    // Message memory (up to 16 characters)
    reg [7:0] message [0:15];

    //--------------------------------------------------------------------------
    // Message Assembly and Transmission FSM
    //--------------------------------------------------------------------------
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= S_IDLE;
            index          <= 0;
            tx_start       <= 0;
            tx_msg         <= 8'h00;
            message_length <= 0;
				RDM_active <= 0;
            // Clear message memory (fill with spaces)
            for (i = 0; i < 16; i = i + 1)
                message[i] <= 8'h20;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_start <= 0;
						  RDM_active <= 0;
                    if (send_msg) begin
                        state <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    // Load fixed header "RDM-"
                    message[0] <= 8'h52;  // 'R'
                    message[1] <= 8'h44;  // 'D'
                    message[2] <= 8'h4D;  // 'M'
                    message[3] <= 8'h2D;  // '-'
                    
                    // Based on the value of place_node, build the location string.
                    // For a PU location (4 characters, e.g. "PSU1")
case (place_node)
  PSU1_const: begin
      message[4] <= 8'h50;  // 'P'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h31;  // '1'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  PSU2_const: begin
      message[4] <= 8'h50;  // 'P'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h32;  // '2'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  PSU3_const: begin
      message[4] <= 8'h50;  // 'P'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h33;  // '3'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  MU1_const: begin
      message[4] <= 8'h4D;  // 'M'
      message[5] <= 8'h55;  // 'U'
      message[6] <= 8'h31;  // '1'
      message[7] <= 8'h2D;  // '-'
      message[8] <= 8'h23;  // '#'
      message_length <= 9;
  end

  MU2_const: begin
      message[4] <= 8'h4D;  // 'M'
      message[5] <= 8'h55;  // 'U'
      message[6] <= 8'h32;  // '2'
      message[7] <= 8'h2D;  // '-'
      message[8] <= 8'h23;  // '#'
      message_length <= 9;
  end

  MU3_const: begin
      message[4] <= 8'h4D;  // 'M'
      message[5] <= 8'h55;  // 'U'
      message[6] <= 8'h33;  // '3'
      message[7] <= 8'h2D;  // '-'
      message[8] <= 8'h23;  // '#'
      message_length <= 9;
  end

  FSU1_const: begin
      message[4] <= 8'h46;  // 'F'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h31;  // '1'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  FSU2_const: begin
      message[4] <= 8'h46;  // 'F'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h32;  // '2'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  FSU3_const: begin
      message[4] <= 8'h46;  // 'F'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h33;  // '3'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  WSU1_const: begin
      message[4] <= 8'h57;  // 'W'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h31;  // '1'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  WSU2_const: begin
      message[4] <= 8'h57;  // 'W'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h32;  // '2'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  WSU3_const: begin
      message[4] <= 8'h57;  // 'W'
      message[5] <= 8'h53;  // 'S'
      message[6] <= 8'h55;  // 'U'
      message[7] <= 8'h33;  // '3'
      message[8] <= 8'h2D;  // '-'
      message[9] <= 8'h23;  // '#'
      message_length <= 10;
  end

  default: begin
      message[4] <= 8'h58;  // 'X'
      message[5] <= 8'h58;  // 'X'
      message[6] <= 8'h58;  // 'X'
      message[7] <= 8'h2D;  // '-'
      message[8] <= 8'h23;  // '#'
      message_length <= 9;
  end
endcase


                    index <= 0;
                    state <= S_TX;
                end

                S_TX: begin
                    if (index < message_length) begin
                        tx_msg   <= message[index];
                        tx_start <= 1;
                        state    <= S_WAIT;
                    end else begin
                        state <= S_DONE;
                    end
						  RDM_active <= 1;
                end

                S_WAIT: begin
                    tx_start <= 0;
                    if (tx_done) begin
                        index <= index + 1;
                        state <= S_TX;
                    end
                end

                S_DONE: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
