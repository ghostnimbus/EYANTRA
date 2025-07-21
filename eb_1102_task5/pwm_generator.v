module pwm_generator(
    input clk_50MHz,
    output reg clk_1MHz,
    output reg pwm_f, pwm_b
);

reg clk_500Hz = 1;
reg [4:0] counter_50MHz = 0;
reg [10:0] counter_1MHz = 0;
reg [10:0] pwm_counter = 0;

initial begin
    clk_500Hz = 1;
    pwm_f = 1;
    pwm_b = 1;
end

always @(posedge clk_50MHz) begin
    if (counter_50MHz == 25) begin
        clk_1MHz = ~clk_1MHz;
        counter_50MHz = 0;
    end else begin
        counter_50MHz = counter_50MHz + 1;
    end
end

always @(posedge clk_1MHz) begin
    if (counter_1MHz == 1000) begin
        clk_500Hz = ~clk_500Hz;
    end else if (counter_1MHz == 2000) begin
        clk_500Hz = ~clk_500Hz;
        counter_1MHz = 0;
    end else begin
        counter_1MHz = counter_1MHz + 1;
    end
end

always @(posedge clk_500Hz) begin
    if (pwm_counter < 500) begin
        pwm_counter = pwm_counter + 1;
    end else begin
        pwm_counter = 0;
    end

    if (pwm_counter < 315) begin
        pwm_f = 1;
    end else begin
        pwm_f = 0;
    end

    if (pwm_counter < 305) begin
        pwm_b = 1;
    end else begin
        pwm_b = 0;
    end
end

endmodule
