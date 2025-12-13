module datapath(
    input              clk,
    input              reset,
    input      [1:0]   ResultSrcD,
    input              ALUSrcD,
    input              RegWriteD,
    input      [1:0]   ImmSrcD,
    input      [2:0]   ALUControlD,
    input              MemWriteD,
    input              JumpD,
    input              BranchD,
    output     [6:0]   OpD,
    output     [2:0]   Funct3D,
    output             Funct7b5D,
    output     [31:0]  PCF,
    input      [31:0]  InstrF,
    output     [31:0]  ALUResultM,
    output     [31:0]  WriteDataM,
    input      [31:0]  ReadDataM,
    output             MemWriteM
);

  // Hazard Detection & Forwarding

  wire [1:0] ForwardA;
  wire [1:0] ForwardB;
  wire       Stall_Fetch;
  wire       Stall_Decode;
  wire       Flush_Decode;
  wire       Flush_Execute;

  hazard_unit hazard_control(
      Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
      RegWriteM, RegWriteW, ResultSrcE[0],
      PCSrcE, ForwardA, ForwardB,
      Stall_Fetch, Stall_Decode, Flush_Decode, Flush_Execute
  );

  // IF - Instruction Fetch
  
  wire [31:0] PCPlus4_IF;
  wire [31:0] PC_Next;

  mux2 #(32) pc_mux(
      PCPlus4_IF, PCTargetE, PCSrcE, PC_Next
  );

  flipflop #(32) pc_reg(
      clk, reset, ~Stall_Fetch, PC_Next, PCF
  );

  adder pc_adder(
      PCF, 32'd4, PCPlus4_IF
  );

  reg_if_id if_id_reg(
      clk, reset, ~Stall_Decode, Flush_Decode,
      InstrF, PCF, PCPlus4_IF,
      InstrD, PCD, PCPlus4D
  );

  // ID - Instruction Decode
  
  wire [31:0] InstrD;
  wire [31:0] PCD;
  wire [31:0] PCPlus4D;
  wire [31:0] RD1D;
  wire [31:0] RD2D;
  wire [31:0] Imm_ExtD;
  wire [4:0]  Rs1D;
  wire [4:0]  Rs2D;
  wire [4:0]  RdD;

  assign OpD       = InstrD[6:0];
  assign Funct3D   = InstrD[14:12];
  assign Funct7b5D = InstrD[30];
  assign Rs1D      = InstrD[19:15];
  assign Rs2D      = InstrD[24:20];
  assign RdD       = InstrD[11:7];

  regfile reg_file(
      clk, RegWriteW,
      Rs1D, Rs2D, RdW,
      ResultW,
      RD1D, RD2D
  );

  extend imm_extender(
      InstrD[31:7], ImmSrcD, Imm_ExtD
  );

  reg_id_ex id_ex_reg(
      clk, reset, Flush_Execute,
      RegWriteD, MemWriteD, JumpD, BranchD,
      ALUSrcD, ResultSrcD, ALUControlD,
      RD1D, RD2D, PCD, Imm_ExtD, PCPlus4D,
      RdD, Rs1D, Rs2D,

      RegWriteE, MemWriteE, JumpE, BranchE,
      ALUSrcE, ResultSrcE, ALUControlE,
      RD1E, RD2E, PCE, Imm_ExtE, PCPlus4E,
      RdE, Rs1E, Rs2E
  );
  
  // EX - Execute
  
  wire [31:0] RD1E;
  wire [31:0] RD2E;
  wire [31:0] PCE;
  wire [31:0] Imm_ExtE;
  wire [31:0] PCPlus4E;
  wire [31:0] SrcA_E;
  wire [31:0] SrcB_E;
  wire [31:0] ALUResult_E;
  wire [31:0] PCTargetE;
  wire [31:0] WriteData_E;
  wire [4:0]  RdE;
  wire [4:0]  Rs1E;
  wire [4:0]  Rs2E;
  wire [2:0]  ALUControlE;
  wire [1:0]  ResultSrcE;
  wire         RegWriteE;
  wire         MemWriteE;
  wire         JumpE;
  wire         BranchE;
  wire         ALUSrcE;
  wire         ZeroE;
  wire         PCSrcE;

  mux3 #(32) src_a_mux(
      RD1E, ResultW, ALUResultM,
      ForwardA, SrcA_E
  );

  mux3 #(32) src_b_mux_intermediate(
      RD2E, ResultW, ALUResultM,
      ForwardB, WriteData_E
  );

  mux2 #(32) src_b_mux(
      WriteData_E, Imm_ExtE, ALUSrcE, SrcB_E
  );

  alu alu_unit(
      SrcA_E, SrcB_E, ALUControlE,
      ALUResult_E, ZeroE
  );

  adder pc_add_branch(
      PCE, Imm_ExtE, PCTargetE
  );

  assign PCSrcE = (BranchE & ZeroE) | JumpE;

  reg_ex_mem ex_mem_reg(
      clk, reset,
      RegWriteE, MemWriteE, ResultSrcE,
      ALUResult_E, WriteData_E, PCPlus4E, RdE,

      RegWriteM, MemWriteM, ResultSrcM,
      ALUResultM, WriteDataM, PCPlus4M, RdM
  );

  // MEM - Memory Access
  
  wire [31:0] PCPlus4M;
  wire [4:0]  RdM;
  wire [1:0]  ResultSrcM;
  wire         RegWriteM;

  reg_mem_wb mem_wb_reg(
      clk, reset,
      RegWriteM, ResultSrcM,
      ALUResultM, ReadDataM, PCPlus4M, RdM,

      RegWriteW, ResultSrcW,
      ALUResultW, ReadDataW, PCPlus4W, RdW
  );
  
  // WB - Writeback
  
  wire [31:0] ALUResultW;
  wire [31:0] ReadDataW;
  wire [31:0] PCPlus4W;
  wire [31:0] ResultW;
  wire [4:0]  RdW;
  wire [1:0]  ResultSrcW;
  wire         RegWriteW;

  mux3 #(32) result_mux(
      ALUResultW, ReadDataW, PCPlus4W,
      ResultSrcW, ResultW
  );

endmodule