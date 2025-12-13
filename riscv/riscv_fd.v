// Fluxo de dados
module datapath(
  input wire clk,
  input wire reset,
  input wire [1:0] ResultSrc,
  input wire PCSrc,
  input wire ALUSrc,
  input wire RegWrite,
  input wire [1:0] ImmSrc,
  input wire [2:0] ALUControl,
  output wire Zero,
  output wire [31:0] PC,
  input wire [31:0] Instr,
  output wire [31:0] ALUResult,
  output wire [31:0] WriteData,
  input wire [31:0] ReadData
);

  wire [31:0] PCNext;
  wire [31:0] PCPlus4;
  wire [31:0] PCTarget;
  wire [31:0] ImmExt;
  wire [31:0] SrcA;
  wire [31:0] SrcB;
  wire [31:0] Result;

  // PC Register
  flopenr #(.WIDTH(32)) pcreg (
    .clk(clk),
    .reset(reset),
    .en(1'b1),
    .d(PCNext),
    .q(PC)
  );

  // PC + 4 Adder
  adder pcadd4 (
    .a(PC),
    .b(32'd4),
    .y(PCPlus4)
  );

  // Branch Target Adder
  adder pcaddbranch (
    .a(PC),
    .b(ImmExt),
    .y(PCTarget)
  );

  // PC Mux
  mux2 #(.WIDTH(32)) pcmux (
    .d0(PCPlus4),
    .d1(PCTarget),
    .s(PCSrc),
    .y(PCNext)
  );

  // Register File
  regfile rf (
    .clk(clk),
    .we(RegWrite),
    .ra1(Instr[19:15]),
    .ra2(Instr[24:20]),
    .wa(Instr[11:7]),
    .wd(Result),
    .rd1(SrcA),
    .rd2(WriteData)
  );

  // Immediate Extension
  extend ext (
    .instr(Instr[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
  );

  // ALU Source B Mux
  mux2 #(.WIDTH(32)) srcbmux (
    .d0(WriteData),
    .d1(ImmExt),
    .s(ALUSrc),
    .y(SrcB)
  );

  // ALU
  alu alu (
    .a(SrcA),
    .b(SrcB),
    .control(ALUControl),
    .result(ALUResult),
    .zero(Zero)
  );

  // Result Mux
  mux3 #(.WIDTH(32)) resultmux (
    .d0(ALUResult),
    .d1(ReadData),
    .d2(PCPlus4),
    .s(ResultSrc),
    .y(Result)
  );

endmodule