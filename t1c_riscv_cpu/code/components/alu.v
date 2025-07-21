
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input [WIDTH-1:0] a,
	 input [WIDTH-1:0] b,       // operands
    input       [2:0] alu_ctrl, funct3,         // ALU control
    input opb4,
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output zero, lt, ltu                    // zero flag
);

always @(*) begin
    case (alu_ctrl)
        3'b000, 001:  alu_out = a + (alu_ctrl[0] == 1'b0 ? b : ~b + 1); // ADD, SUB
        3'b010:  alu_out = a & b;       // AND
        3'b011:  alu_out = a | b;       // OR
        3'b100:  alu_out = $signed(a) >>> b[4:0];   // ASR
        3'b101:  alu_out = a >> b[4:0];      // LSR
        3'b110:  alu_out = a << b[4:0];      // LSL or ASL
        3'b111:  alu_out = a ^ b; // XOR
        default: alu_out = 0;
    endcase

    if(opb4) begin
        case(funct3)
            3'b010: alu_out = lt;
            3'b011: alu_out = ltu;
        endcase
    end
end

assign lt = (a[31] != b[31]) ? a[31] : alu_out[31];
assign ltu = (a[31] != b[31]) ? ~a[31] : alu_out[31];
assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

