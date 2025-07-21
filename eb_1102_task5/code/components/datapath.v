
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [2:0]   ALUControl,
    input         Jalr,
    output        Zero, lt, ltu,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCjalr;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult, AuiPC, lAuiPC;

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCjalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
mux2 #(32)     pcjalrmux(PCNext, ALUResult, Jalr, PCjalr);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, Instr[14:12], Instr[4], ALUResult, Zero, lt, ltu);
adder				auipcadder({Instr[31:12], 12'b0}, PC, AuiPC);
mux2 #(32)		lauipcmux(AuiPC, {Instr[31:12], 12'b0}, Instr[5], lAuiPC);

// Result source
mux4 #(32)     resultmux(ALUResult, ReadData, PCPlus4, lAuiPC, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule

