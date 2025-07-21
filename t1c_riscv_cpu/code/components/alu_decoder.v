
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000;             // addition
        2'b01: ALUControl = 3'b001;             // subtraction
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract
                    if   (funct7b5 & opb5) ALUControl = 3'b001; //sub
                    else ALUControl = 3'b000; // add, addi
                end
                3'b001:  ALUControl = 3'b110; // slli
                3'b010, 3'b011:  ALUControl = 3'b001; // slt, slti, sltu, sltiu
                3'b100:  ALUControl = 3'b111; // xor, xori
                3'b101: begin
                    if(funct7b5) begin 
								ALUControl = 3'b100; //sra, srai
						  end
                    else begin
								ALUControl = 3'b101; // srl, srli
						  end
                end
                3'b110:  ALUControl = 3'b011; // or, ori
                3'b111:  ALUControl = 3'b010; // and, andi
                default: ALUControl = 3'bxxx; // ???
            endcase
    endcase
end

endmodule

