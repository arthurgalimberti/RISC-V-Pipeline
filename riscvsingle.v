module top(
    input        clk,
    input        reset,
    output [31:0] WriteData,
    output [31:0] DataAdr,
    output        MemWrite
);

  wire [31:0] PC;
  wire [31:0] Instr;
  wire [31:0] ReadData;

  // Processador e Memórias
  riscvsingle rvsingle(
      clk,
      reset,
      PC,
      Instr,
      MemWrite,
      DataAdr,
      WriteData,
      ReadData
  );

  imem imem(
      PC,
      Instr
  );

  dmem dmem(
      clk,
      MemWrite,
      DataAdr,
      WriteData,
      ReadData
  );

  // DEBUG
  always @(posedge clk) begin
    if (!reset) begin
      $display(
        "PC: %h | Instr: %h | MemWrite: %b | DataAdr: %h | WriteData: %h | ReadData: %h",
        PC, Instr, MemWrite, DataAdr, WriteData, ReadData
      );
    end

    if (MemWrite) begin
      if ((DataAdr == 32'd100) && (WriteData == 32'd25)) begin
        // se escrever 25 na posição 100, deu bom
        $display("Simulation succeeded");
        $stop;
      end
      else if (DataAdr != 32'd96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end

endmodule

module riscvsingle(
    input        clk,
    input        reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWrite,
    output [31:0] ALUResult,
    output [31:0] WriteData,
    input  [31:0] ReadData
);

  wire       ALUSrc;
  wire       RegWrite;
  wire       Jump;
  wire       Zero;
  wire       PCSrc;
  wire [1:0] ResultSrc;
  wire [1:0] ImmSrc;
  wire [2:0] ALUControl;

  wire [6:0] opD;
  wire [2:0] funct3D;
  wire       funct7b5D;
  wire       RegWriteD;
  wire       ALUSrcD;
  wire       MemWriteD;
  wire       JumpD;
  wire       BranchD;
  wire [1:0] ResultSrcD;
  wire [1:0] ImmSrcD;
  wire [2:0] ALUControlD;

  // Unidade de controle
  controller c(
      opD,
      funct3D,
      funct7b5D,
      Zero,
      ResultSrcD,
      MemWriteD,
      PCSrc,
      ALUSrcD,
      RegWriteD,
      JumpD,
      BranchD,
      ImmSrcD,
      ALUControlD
  );

  // Datapath
  datapath dp(
      clk,
      reset,
      ResultSrcD,
      ALUSrcD,
      RegWriteD,
      ImmSrcD,
      ALUControlD,
      MemWriteD,
      JumpD,
      BranchD,
      opD,
      funct3D,
      funct7b5D,
      PC,
      Instr,
      ALUResult,
      WriteData,
      ReadData,
      MemWrite
  );

endmodule


