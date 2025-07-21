// EcoMender Bot : Task 1B : Color Detection using State Machines
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will detect colors red, green, and blue using state machine and frequency detection.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Color Detection
//Inputs : clk_1MHz, cs_out
//Output : filter, color

// Module Declaration
module color_sensor (
    input  clk_1MHz, cs_out,
    output reg [1:0] filter, color
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

initial begin // editing this initial block is allowed
    filter = 3; 
    color = 0;
end

// Declaring registers
reg [13:0] counter = 0;   // Counter to track time cycles
reg [15:0] red_count = 0;    // Red frequency count
reg [15:0] green_count = 0;  // Green frequency count
reg [15:0] blue_count = 0;   // Blue frequency count

// Defining state machine parameters for different color states
parameter ST_RED=2'b00, ST_BLUE=2'b01, ST_CLEAR=2'b10, ST_GREEN=2'b11;

// Thresholds for color detection
parameter WHITE_THRESHOLD = 350; // Minimum count for white detection
parameter COLOR_THRESHOLD = 50;  // Minimum count for colored patch detection

always @(posedge clk_1MHz) begin  // State machine runs on the rising edge of 1 MHz clock

    // Change filter after 500 clock cycles or if filter is 2
    if (counter == 15000) begin
        case (filter)
            ST_GREEN: begin
                filter = ST_RED; // After green, switch to red filter
            end
            ST_RED: begin
                filter = ST_BLUE; // After red, switch to blue filter
            end
            ST_BLUE: begin
                filter = ST_CLEAR; // After blue, switch to clear state
                
                // White detection logic
                if (red_count > WHITE_THRESHOLD && green_count > WHITE_THRESHOLD && blue_count > WHITE_THRESHOLD) begin
                    color = 0; // White is detected
                end else begin
                    // Color detection logic
                    if (red_count > COLOR_THRESHOLD && red_count > green_count && red_count > blue_count)
                        color = 1; // Red is dominant
                    else if (green_count > COLOR_THRESHOLD && green_count > red_count && green_count > blue_count)
                        color = 2; // Green is dominant
                    else if (blue_count > COLOR_THRESHOLD && blue_count > red_count && blue_count > green_count)
                        color = 3; // Blue is dominant
                    else
                        color = 0; // Default to white if no dominant color
                end
            end
            ST_CLEAR: begin
                filter = ST_GREEN; // After clear, switch to green filter
            end
        endcase
        counter = 0;  // Reset counter after each filter cycle
    end
    counter = counter + 1;  // Increment counter for clock cycles tracking
end

// Logic triggered by cs_out
always @(posedge cs_out) begin
    // Increment counts for the active filter
    red_count = (filter == ST_RED) ? red_count + 1 : red_count;
    green_count = (filter == ST_GREEN) ? green_count + 1 : green_count;
    blue_count = (filter == ST_BLUE) ? blue_count + 1 : blue_count;

    // Reset counts when in CLEAR filter state
    if (filter == ST_CLEAR) begin
        red_count = 0;
        green_count = 0;
        blue_count = 0;
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
