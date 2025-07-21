module start_detector(
    input wire clk,
	 input Done,
    input wire reset,
	 input wire rx_complete,
    input wire [7:0] data_in,     // Byte received from UART_RX
    output reg robot_enabled      // Output signal to enable the robot
);
    reg [7:0] command_buffer [0:4]; // Buffer to store the last 5 received bytes
    integer i;                      

    always @(posedge clk or posedge reset) begin
        if (reset) begin
           
            for (i = 0; i < 5; i = i + 1) begin
                command_buffer[i] <= 8'b0;
            end
            robot_enabled <= 0;
        end else begin
            
				if(rx_complete) begin
					for (i = 4; i > 0; i = i - 1) begin   
						command_buffer[i] <= command_buffer[i - 1];
					end
					command_buffer[0] <= data_in;
				end

            // Check for "START" in the buffer
            if (command_buffer[4] == "S" &&
                command_buffer[3] == "T" &&
                command_buffer[2] == "A" &&
                command_buffer[1] == "R" &&
                command_buffer[0] == "T") begin
                robot_enabled <= 1; // Enable robot
            end
				if (Done) robot_enabled <= 0;
        end
    end
endmodule