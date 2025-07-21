// EcoMender Bot : Task 2A - UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Baudrate: 115200 

Input:  clk_3125 	- 3125 KHz clock
        rx      	- UART Receiver

Output: rx_msg 		- received input message of 8-bit width
		  rx_parity 	- received parity bit
        rx_complete 	- successful uart packet processed signal
*/
// module declaration
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );


//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
//
//initial begin
//    rx_msg = 0; rx_parity = 0; rx_complete = 0;
//end

// State definitions for the state machine
parameter IDLE = 3'b000,
          START = 3'b001,
          DATA = 3'b010,
          PARITY = 3'b011,
          STOP = 3'b100;

reg [2:0] state = IDLE;           // Initial state set to IDLE
reg [2:0] bit_counter = 0;        // Bit counter for 8 data bits
reg parity_calc = 0;              // For calculating even parity
reg [4:0] sample_counter = 0;     // Sampling counter to sample every bit time
reg [7:0] rx_data = 0;				// Register to hold received data
reg parity;            

// Calculate the number of cycles per bit
localparam BIT_PERIOD = 27;       // 14 cycles at 3.125 MHz for 230400 baud rate

initial begin
	rx_msg = 0;
	rx_parity = 0;
	rx_complete = 0;
end

always @(posedge clk_3125) begin
//    rx_complete <= 0;  // Default rx_complete is 0
	 
	 if (state != STOP) begin
        rx_complete <= 0;
    end
	 
    case (state)
			
		  IDLE: begin
				if(~rx) begin
					state <= START;
				end
		  end
        START: begin
//				rx_complete <= 0;
            if (sample_counter == BIT_PERIOD) begin
                sample_counter <= 1;
					 state <= DATA;
					 
            end else begin
                sample_counter <= sample_counter + 1;
            end
        end

        DATA: begin
            if (sample_counter == BIT_PERIOD) begin
                sample_counter <= 1;
					 
                if (bit_counter == 7) begin
                    state <= PARITY;
						  bit_counter <= 0;
                end else begin
                    bit_counter <= bit_counter + 1;
                end
				end else if (sample_counter == 14) begin
//					 rx_data <= {1'b0, rx, rx_data[6:1]};
					 rx_data[bit_counter] = rx;
					 sample_counter <= sample_counter + 1;
            end else begin
                sample_counter <= sample_counter + 1;
            end
        end

        PARITY: begin
            if (sample_counter == BIT_PERIOD) begin
                sample_counter <= 1;
					 state <= STOP;
            end else if (sample_counter == 14) begin
					 parity <= rx; // Capture received parity bit
					 
//					 if (parity_calc == rx) begin // Check even parity
//                    rx_data <= rx_data;
//                end 
//					 else begin
//                    rx_data <= 63; // Error detected, reset to IDLE
//                end
					 
					 sample_counter <= sample_counter + 1;
				end else begin
                sample_counter <= sample_counter + 1;
            end
        end

        STOP: begin
            if (sample_counter == BIT_PERIOD) begin
                sample_counter <= 1;
					 rx_parity <= parity;
					 
                rx_msg <= rx_data;
					 
                rx_complete <= 1; // Indicate successful packet reception
                state <= IDLE; // Return to IDLE for the next packet
            end else begin
                sample_counter <= sample_counter + 1;
            end
        end

    endcase
end

always@(*) begin
	parity_calc = ^rx_data;
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
