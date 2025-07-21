
// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
    input [2:0] funct3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output  reg [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

wire [5:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;

// synchronous write logic
always @(posedge clk) begin

    if (wr_en) begin
        case (funct3)
            3'b000: begin // SB (store byte)
                data_ram[word_addr] <= (data_ram[word_addr] & ~(32'hFF << (wr_addr[1:0] * 8))) | (wr_data[7:0] << (wr_addr[1:0] * 8));
            end
            3'b001: begin // SH (store halfword)
                data_ram[word_addr] <= (data_ram[word_addr] & ~(32'hFFFF << (wr_addr[1] * 16))) | (wr_data[15:0] << (wr_addr[1] * 16));
            end
            3'b010: begin // SW (store word)
                data_ram[word_addr] <= wr_data;
            end
        endcase
    end

end

// combinational read logic

reg [7:0] selected_byte;
reg [15:0] selected_halfword;

always @(*) begin
    // Select the byte and halfword based on wr_addr
    selected_byte = data_ram[word_addr] >> (wr_addr[1:0] * 8);
    selected_halfword = data_ram[word_addr] >> (wr_addr[1] * 16);

    // Choose based on funct3
    case (funct3)
        3'b000: rd_data_mem = {{24{selected_byte[7]}}, selected_byte}; // lb (sign-extended)
        3'b100: rd_data_mem = {24'b0, selected_byte}; // lbu (zero-extended)
        3'b001: rd_data_mem = {{16{selected_halfword[15]}}, selected_halfword}; // lh (sign-extended)
        3'b101: rd_data_mem = {16'b0, selected_halfword}; // lhu (zero-extended)
		  default: rd_data_mem = data_ram[word_addr]; // Default to word load
    endcase

end


endmodule
