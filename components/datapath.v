module datapath(input        clk, reset,
                input  [1:0] ResultSrcD,
                input        ALUSrcD, RegWriteD,
                input  [1:0] ImmSrcD,
                input  [2:0] ALUControlD,
                input        MemWriteD, JumpD, BranchD,
                output [6:0] OpD,
                output [2:0] Funct3D,
                output       Funct7b5D,
                output [31:0] PCF,
                input  [31:0] InstrF,
                output [31:0] ALUResultM, WriteDataM,
                input  [31:0] ReadDataM,
                output       MemWriteM);

  wire [31:0] PCPlus4F, PCNextF;
  wire [31:0] InstrD, PCD, PCPlus4D, RD1D, RD2D, ImmExtD;
  wire [4:0]  Rs1D, Rs2D, RdD;

  wire [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E, SrcAE, SrcBE, ALUResultE, PCTargetE, WriteDataE;
  wire [4:0]  RdE, Rs1E, Rs2E;
  wire [2:0]  ALUControlE;
  wire [1:0]  ResultSrcE;
  wire        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ZeroE, PCSrcE;

  wire [31:0] PCPlus4M;
  wire [4:0]  RdM;
  wire [1:0]  ResultSrcM;
  wire        RegWriteM;

  wire [31:0] ALUResultW, ReadDataW, PCPlus4W, ResultW;
  wire [4:0]  RdW;
  wire [1:0]  ResultSrcW;
  wire        RegWriteW;

  wire [1:0] ForwardAE, ForwardBE;
  wire       StallF, StallD, FlushD, FlushE;

  hazard_unit hu(Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
                 RegWriteM, RegWriteW, ResultSrcE[0],
                 PCSrcE, ForwardAE, ForwardBE,
                 StallF, StallD, FlushD, FlushE);

  mux2 #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNextF);
  flopenr #(32) pcreg(clk, reset, ~StallF, PCNextF, PCF);
  adder pcadd4(PCF, 32'd4, PCPlus4F);

  reg_if_id if_id(clk, reset, ~StallD, FlushD,
                  InstrF, PCF, PCPlus4F,
                  InstrD, PCD, PCPlus4D);

  assign OpD       = InstrD[6:0];
  assign Funct3D   = InstrD[14:12];
  assign Funct7b5D = InstrD[30];
  assign Rs1D      = InstrD[19:15];
  assign Rs2D      = InstrD[24:20];
  assign RdD       = InstrD[11:7];

  regfile rf(clk, RegWriteW, Rs1D, Rs2D, RdW, ResultW, RD1D, RD2D);
  extend  ext(InstrD[31:7], ImmSrcD, ImmExtD);

  reg_id_ex id_ex(clk, reset, FlushE,
                  RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD, ResultSrcD, ALUControlD,
                  RD1D, RD2D, PCD, ImmExtD, PCPlus4D, RdD, Rs1D, Rs2D,
                  RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ResultSrcE, ALUControlE,
                  RD1E, RD2E, PCE, ImmExtE, PCPlus4E, RdE, Rs1E, Rs2E);

  mux3 #(32) srcamux(RD1E, ResultW, ALUResultM, ForwardAE, SrcAE);
  mux3 #(32) srcbmux_inter(RD2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
  mux2 #(32) srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcBE);

  alu alu1(SrcAE, SrcBE, ALUControlE, ALUResultE, ZeroE);
  adder pcaddbranch(PCE, ImmExtE, PCTargetE);

  assign PCSrcE = (BranchE & ZeroE) | JumpE;

  reg_ex_mem ex_mem(clk, reset,
                    RegWriteE, MemWriteE, ResultSrcE,
                    ALUResultE, WriteDataE, PCPlus4E, RdE,
                    RegWriteM, MemWriteM, ResultSrcM,
                    ALUResultM, WriteDataM, PCPlus4M, RdM);

  reg_mem_wb mem_wb(clk, reset,
                    RegWriteM, ResultSrcM,
                    ALUResultM, ReadDataM, PCPlus4M, RdM,
                    RegWriteW, ResultSrcW,
                    ALUResultW, ReadDataW, PCPlus4W, RdW);

  mux3 #(32) resultmux(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);
endmodule