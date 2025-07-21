module led_logic (
    input clk_1MHz, 
    input Done, // Done signal to start toggling LEDs
	 input lap_done,
    input [1:0] color,  // Detected color (1: Red, 2: Green, 3: Blue, 0: No color)
    output reg patch_enable,  // Signal to trigger color detection and latch the color to LED
    output reg [2:0] rgb1,    // RGB output for LED 1
    output reg [2:0] rgb2,    // RGB output for LED 2
    output reg [2:0] rgb3     // RGB output for LED 3
);

    // Register to track which LED should be updated next
    reg [1:0] led_no = 0;  // 0: rgb1, 1: rgb2, 2: rgb3

    // Counter for 1-second delay (1 MHz clock, need to count to 1,000,000)
    reg [19:0] counter = 0;  // 20-bit counter can count up to 1 million
    reg toggle = 0;  // Flag to toggle LEDs on and off

    // Initialization
    initial begin
        rgb1 = 3'b000;  // All LEDs off initially
        rgb2 = 3'b000;
        rgb3 = 3'b000;
        patch_enable = 0;
        led_no = 0;
        counter = 0;
        toggle = 0;
    end

    // LED update logic
    always @(posedge clk_1MHz) begin
        if (color == 0) begin
            patch_enable <= 0;  // No color detected, turn off patch enable
        end else begin
            patch_enable <= 1;  // Color detected, enable patch

            // Update LEDs sequentially based on led_no
            case (led_no)
                0: begin
                    if (rgb1 == 3'b000) begin  // Update LED 1 only if it's off
                        case (color)
                            1: rgb1 <= 3'b001;  // Red detected, update LED 1
                            2: rgb1 <= 3'b010;  // Green detected, update LED 1
                            3: rgb1 <= 3'b100;  // Blue detected, update LED 1
                        endcase   
                    end
                    if (rgb1 != 3'b000 && patch_enable == 0) begin
                        led_no <= 1;  // Move to next LED
                    end
                end

                1: begin
                    if (rgb2 == 3'b000) begin  // Update LED 2 only if it's off
                        case (color)
                            1: rgb2 <= 3'b001;  // Red detected, update LED 2
                            2: rgb2 <= 3'b010;  // Green detected, update LED 2
                            3: rgb2 <= 3'b100;  // Blue detected, update LED 2
                        endcase
                    end
                    if (rgb2 != 3'b000 && patch_enable == 0) begin
                        led_no <= 2;  // Move to next LED
                    end
                end

                2: begin
                    if (rgb3 == 3'b000) begin  // Update LED 3 only if it's off
                        case (color)
                            1: rgb3 <= 3'b001;  // Red detected, update LED 3
                            2: rgb3 <= 3'b010;  // Green detected, update LED 3
                            3: rgb3 <= 3'b100;  // Blue detected, update LED 3
                        endcase
                    end
                    if (rgb3 != 3'b000 && patch_enable == 0) begin
                        led_no <= 0;  // Reset to first LED after all are updated
								        rgb1 <= 3'b000;  // All LEDs off initially
										  rgb2 <= 3'b000;
										  rgb3 <= 3'b000;
                    end
                end
            endcase
        end
		  
		  if(lap_done) begin
				    rgb1 <= 3'b000;  // Turn off LED 1
                rgb2 <= 3'b000;  // Turn off LED 2
                rgb3 <= 3'b000;  // Turn off LED 3
			end
				

        // If Done signal is high, toggle the LEDs between green and off every 1 second
        if (Done) begin
            if (counter < 1000000) begin
                counter <= counter + 1;  // Increment the counter
            end else begin
                counter <= 0;  // Reset counter after 1 second
                toggle <= ~toggle;  // Toggle the green LED state
            end

            // Set LEDs to green or off based on the toggle flag
            if (toggle) begin
                rgb1 <= 3'b010;  // Set LED 1 to green
                rgb2 <= 3'b010;  // Set LED 2 to green
                rgb3 <= 3'b010;  // Set LED 3 to green
            end else begin
                rgb1 <= 3'b000;  // Turn off LED 1
                rgb2 <= 3'b000;  // Turn off LED 2
                rgb3 <= 3'b000;  // Turn off LED 3
            end
        end
 end
endmodule
