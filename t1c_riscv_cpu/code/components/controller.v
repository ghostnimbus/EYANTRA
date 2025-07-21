
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, lt, ltu,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jalr,
    output [1:0] ImmSrc,
    output [2:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch, Jump;

main_decoder    md (op, funct3, Zero, lt, ltu, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
assign PCSrc = Branch | Jump;

endmodule

