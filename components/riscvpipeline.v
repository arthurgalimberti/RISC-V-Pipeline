module riscvpipeline(input        clk, reset,
                   output [31:0] PC,
                   input  [31:0] Instr,
                   output       MemWrite,
                   output [31:0] ALUResult, WriteData,
                   input  [31:0] ReadData);

  wire       RegWriteD, ALUSrcD, MemWriteD, JumpD, BranchD;
  wire [1:0] ResultSrcD, ImmSrcD;
  wire [2:0] ALUControlD;
  wire [6:0] opD;
  wire [2:0] funct3D;
  wire       funct7b5D;

  controller c(opD, funct3D, funct7b5D, 1'b0,
               ResultSrcD, MemWriteD, ,
               ALUSrcD, RegWriteD, JumpD, BranchD,
               ImmSrcD, ALUControlD);

  datapath dp(clk, reset,
              ResultSrcD, ALUSrcD, RegWriteD,
              ImmSrcD, ALUControlD,
              MemWriteD, JumpD, BranchD,
              opD, funct3D, funct7b5D,
              PC, Instr, ALUResult, WriteData, ReadData, MemWrite);
endmodule