module led_logic (
    input clk_1MHz, 
    input Done,       // Done signal to start toggling LEDs
    input [1:0] color, // Detected color (1: Red, 2: Green, 3: Blue, 0: No color)
    input MI_led,     // Trigger signal from CSL_Decoder
    output reg patch_enable,  // Signal to trigger color detection and latch color to LED
    output reg [2:0] rgb1,    // RGB output for LED 1
    output reg [2:0] rgb2,    // RGB output for LED 2
    output reg [2:0] rgb3,    // RGB output for LED 3
    output reg [2:0] rgb_mi   // RGB output for MI LED (yellow for 2 seconds)
);

    reg [1:0] led_no = 0;  // 0: rgb1, 1: rgb2, 2: rgb3
    reg [19:0] counter = 0;  // 1-second counter (1 MHz clock, count to 1,000,000)
    reg toggle = 0;  // Toggle flag for Done signal
    reg [20:0] mi_counter = 0; // Counter for MI LED duration
    reg mi_active = 0;  // Flag to keep track of MI LED state

    initial begin
        rgb1 = 3'b000;
        rgb2 = 3'b000;
        rgb3 = 3'b000;
        rgb_mi = 3'b000;
        patch_enable = 0;
        led_no = 0;
        counter = 0;
        toggle = 0;
        mi_counter = 0;
        mi_active = 0;
    end

    always @(posedge clk_1MHz) begin
        if (MI_led) begin
            mi_active <= 1;
        end else begin
				mi_counter <= 0;
		  end
        
        if (mi_active) begin
            
            if (mi_counter < 2000000) begin
                mi_counter <= mi_counter + 1;
					 rgb_mi <= 3'b011; // Yellow (Red + Green)
            end else begin
                rgb_mi <= 3'b000;
                mi_active <= 0;
            end
        end

        if (color == 0) begin
            patch_enable <= 0;
        end else begin
            patch_enable <= 1;
            case (led_no)
                0: if (rgb1 == 3'b000) begin
                        case (color)
                            1: rgb1 <= 3'b001;
                            2: rgb1 <= 3'b010;
                            3: rgb1 <= 3'b100;
                        endcase   
                    end else if (patch_enable == 0) led_no <= 1;
                
                1: if (rgb2 == 3'b000) begin
                        case (color)
                            1: rgb2 <= 3'b001;
                            2: rgb2 <= 3'b010;
                            3: rgb2 <= 3'b100;
                        endcase
                    end else if (patch_enable == 0) led_no <= 2;
                
                2: if (rgb3 == 3'b000) begin
                        case (color)
                            1: rgb3 <= 3'b001;
                            2: rgb3 <= 3'b010;
                            3: rgb3 <= 3'b100;
                        endcase
                    end else if (patch_enable == 0) begin
                        led_no <= 0;
                        rgb1 <= 3'b000;
                        rgb2 <= 3'b000;
                        rgb3 <= 3'b000;
                    end
            endcase
        end

        if (Done) begin
            if (counter < 1000000) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                toggle <= ~toggle;
            end

            if (toggle) begin
                rgb1 <= 3'b010;
                rgb2 <= 3'b010;
                rgb3 <= 3'b010;
            end else begin
                rgb1 <= 3'b000;
                rgb2 <= 3'b000;
                rgb3 <= 3'b000;
            end
        end
    end
endmodule