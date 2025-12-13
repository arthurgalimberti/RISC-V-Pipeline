module adder(
  input wire [31:0] a, b, 
  output wire [31:0] y
);
  assign y = a + b;
endmodule
// Unidade Lógica e Aritmética (ALU)
module alu(
  input wire [31:0] a, b,
  input wire [2:0] alucontrol,
  output reg [31:0] result,
  output wire zero
);

  wire [31:0] condinvb, sum;
  wire v;
  wire isAddSub;

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];

  assign isAddSub = (~alucontrol[2] & ~alucontrol[1]) |
                    (~alucontrol[1] & alucontrol[0]);

  always @(*) begin
    case (alucontrol)
      3'b000: result = sum;
      3'b001: result = sum;
      3'b010: result = a & b;
      3'b011: result = a | b;
      3'b100: result = a ^ b;
      3'b101: result = sum[31] ^ v;
      3'b110: result = a << b[4:0];
      3'b111: result = a >> b[4:0];
      default: result = 32'b0;
    endcase
  end

  assign zero = (result == 0);

  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) &
             (a[31] ^ sum[31]) & isAddSub;

endmodule
// Decodificador ALU, gera sinais de controle ALU com base em funct3, funct7 e ALUOp
module aludec(
  input wire opb5,
  input wire [2:0] funct3,
  input wire funct7b5,
  input wire [1:0] ALUOp,
  output reg [2:0] ALUControl
);

  wire RtypeSub;
  assign RtypeSub = funct7b5 & opb5;

  always @(*) begin
    case (ALUOp)
      2'b00: ALUControl = 3'b000;
      2'b01: ALUControl = 3'b001;
      default:
        case (funct3)
          3'b000: ALUControl = RtypeSub ? 3'b001 : 3'b000;
          3'b010: ALUControl = 3'b101;
          3'b110: ALUControl = 3'b011;
          3'b111: ALUControl = 3'b010;
          default: ALUControl = 3'b000;
        endcase
    endcase
  end
endmodule
// Extensor de imediato
module extend(
  input wire [31:7] instr,
  input wire [1:0] immsrc,
  output reg [31:0] immext
);

  always @(*) begin
    case (immsrc)
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};
      2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      2'b10: immext = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
      2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      default: immext = 32'b0;
    endcase
  end

endmodule
// Flip-flop com enable e reset síncrono
module flopenr #(parameter WIDTH = 8)(
  input wire clk, reset, en,
  input wire [WIDTH-1:0] d,
  output reg [WIDTH-1:0] q
);

  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else if (en)  q <= d;

endmodule
// Decodificador principal, gera sinais de controle com base no opcode
module maindec(
  input wire [6:0] op,
  output reg [1:0] ResultSrc,
  output reg MemWrite,
  output reg Branch, ALUSrc,
  output reg RegWrite, Jump,
  output reg [1:0] ImmSrc,
  output reg [1:0] ALUOp
);

  reg [10:0] controls;

  always @(*) begin
    case (op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      default:    controls = 11'b0_00_0_0_00_0_00_0;
    endcase
  end

  always @(*) begin
    {RegWrite, ImmSrc, ALUSrc, MemWrite,
     ResultSrc, Branch, ALUOp, Jump} = controls;
  end

endmodule
// Memória de instruções
module imem(input wire [31:0] a, output wire [31:0] rd);

  reg [31:0] RAM[63:0];

  initial begin
    $readmemh("riscvtest.txt", RAM);
  end

  assign rd = RAM[a[31:2]];

endmodule

// Memória de dados
module dmem(
  input wire clk, we,
  input wire [31:0] a, wd,
  output wire [31:0] rd
);

  reg [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]];

  always @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;

endmodule
// Multiplexador de 2 para 1
module mux2 #(parameter WIDTH = 8)(
  input wire [WIDTH-1:0] d0, d1,
  input wire s,
  output wire [WIDTH-1:0] y
);
  assign y = s ? d1 : d0;
endmodule

// Multiplexador de 3 para 1
module mux3 #(parameter WIDTH = 8)(
  input wire [WIDTH-1:0] d0, d1, d2,
  input wire [1:0] s,
  output wire [WIDTH-1:0] y
);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule
// Banco de registradores
module regfile(
  input wire clk,
  input wire we3,
  input wire [4:0] a1, a2, a3,
  input wire [31:0] wd3,
  output wire [31:0] rd1, rd2
);

  reg [31:0] rf[31:0];

  always @(posedge clk)
    if (we3) rf[a3] <= wd3;

  assign rd1 = (a1 != 0) ? rf[a1] : 32'b0;
  assign rd2 = (a2 != 0) ? rf[a2] : 32'b0;

endmodule
// Pipeline Register entre ID e EX
module reg_id_ex(
    input        clk,
    input        reset,
    input        clear,
    // Controle
    input        RegWriteD,
    input        MemWriteD,
    input        JumpD,
    input        BranchD,
    input        ALUSrcD,
    input  [1:0] ResultSrcD,
    input  [2:0] ALUControlD,
    // Dados
    input  [31:0] RD1D,
    input  [31:0] RD2D,
    input  [31:0] PCD,
    input  [31:0] ImmExtD,
    input  [31:0] PCPlus4D,
    input  [4:0]  RdD,
    input  [4:0]  Rs1D,
    input  [4:0]  Rs2D,
    // Saídas
    output reg        RegWriteE,
    output reg        MemWriteE,
    output reg        JumpE,
    output reg        BranchE,
    output reg        ALUSrcE,
    output reg [1:0]  ResultSrcE,
    output reg [2:0]  ALUControlE,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] PCE,
    output reg [31:0] ImmExtE,
    output reg [31:0] PCPlus4E,
    output reg [4:0]  RdE,
    output reg [4:0]  Rs1E,
    output reg [4:0]  Rs2E
);

  always @(posedge clk or posedge reset) begin
    if (reset || clear) begin
      RegWriteE  <= 1'b0;
      MemWriteE  <= 1'b0;
      JumpE      <= 1'b0;
      BranchE    <= 1'b0;
      ALUSrcE    <= 1'b0;
      ResultSrcE <= 2'b00;
      ALUControlE<= 3'b000;

      RD1E       <= 32'b0;
      RD2E       <= 32'b0;
      PCE        <= 32'b0;
      ImmExtE    <= 32'b0;
      PCPlus4E   <= 32'b0;

      RdE        <= 5'b0;
      Rs1E       <= 5'b0;
      Rs2E       <= 5'b0;
    end else begin
      // Passa os valores do estágio ID para EX
      RegWriteE  <= RegWriteD;
      MemWriteE  <= MemWriteD;
      JumpE      <= JumpD;
      BranchE    <= BranchD;
      ALUSrcE    <= ALUSrcD;

      ResultSrcE <= ResultSrcD;
      ALUControlE<= ALUControlD;

      RD1E       <= RD1D;
      RD2E       <= RD2D;
      PCE        <= PCD;
      ImmExtE    <= ImmExtD;
      PCPlus4E   <= PCPlus4D;

      RdE        <= RdD;
      Rs1E       <= Rs1D;
      Rs2E       <= Rs2D;
    end
  end

endmodule
// Pipeline Register entre EX e MEM
module reg_ex_mem(
    input        clk,
    input        reset,
    // Controle
    input        RegWriteE,
    input        MemWriteE,
    input  [1:0] ResultSrcE,
    // Dados
    input  [31:0] ALUResultE,
    input  [31:0] WriteDataE,
    input  [31:0] PCPlus4E,
    input  [4:0]  RdE,
    // Saídas
    output reg        RegWriteM,
    output reg        MemWriteM,
    output reg [1:0]  ResultSrcM,
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] PCPlus4M,
    output reg [4:0]  RdM
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteM  <= 1'b0;
      MemWriteM  <= 1'b0;
      ResultSrcM <= 2'b00;
      ALUResultM <= 32'b0;
      WriteDataM <= 32'b0;
      PCPlus4M   <= 32'b0;
      RdM        <= 5'b0;
    end else begin
      // Passa os valores do estágio EX para MEM
      RegWriteM  <= RegWriteE;
      MemWriteM  <= MemWriteE;
      ResultSrcM <= ResultSrcE;
      ALUResultM <= ALUResultE;
      WriteDataM <= WriteDataE;
      PCPlus4M   <= PCPlus4E;
      RdM        <= RdE;
    end
  end

endmodule
// Pipeline Register entre IF e ID
module reg_if_id(
    input        clk,
    input        reset,
    input        en,
    input        clear,
    input  [31:0] InstrF,
    input  [31:0] PCF,
    input  [31:0] PCPlus4F,
    output reg [31:0] InstrD,
    output reg [31:0] PCD,
    output reg [31:0] PCPlus4D
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrD   <= 32'b0;
      PCD      <= 32'b0;
      PCPlus4D <= 32'b0;
    end else if (en) begin
      if (clear) begin
        InstrD   <= 32'b0;
        PCD      <= 32'b0;
        PCPlus4D <= 32'b0;
      end else begin
        // Passa os valores do estágio IF para ID
        InstrD   <= InstrF;
        PCD      <= PCF;
        PCPlus4D <= PCPlus4F;
      end
    end
    // se en == 0: mantém o valor (stall)
  end

endmodule
// Pipeline Register entre MEM e WB
module reg_mem_wb(
    input        clk,
    input        reset,
    // Controle
    input        RegWriteM,
    input  [1:0] ResultSrcM,
    // Dados
    input  [31:0] ALUResultM,
    input  [31:0] ReadDataM,
    input  [31:0] PCPlus4M,
    input  [4:0]  RdM,
    // Saídas
    output reg        RegWriteW,
    output reg [1:0]  ResultSrcW,
    output reg [31:0] ALUResultW,
    output reg [31:0] ReadDataW,
    output reg [31:0] PCPlus4W,
    output reg [4:0]  RdW
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteW  <= 1'b0;
      ResultSrcW <= 2'b00;
      ALUResultW <= 32'b0;
      ReadDataW  <= 32'b0;
      PCPlus4W   <= 32'b0;
      RdW        <= 5'b0;
    end else begin
      // Passa os valores do estágio MEM para WB
      RegWriteW  <= RegWriteM;
      ResultSrcW <= ResultSrcM;
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadDataM;
      PCPlus4W   <= PCPlus4M;
      RdW        <= RdM;
    end
  end

endmodule
module hazard_unit(
    input  BranchE,
    input  [4:0] Rs1D, Rs2D,
    input  [4:0] Rs1E, Rs2E,
    input  [4:0] RdE, RdM, RdW,
    input        RegWriteM, RegWriteW,
    input        ResultSrcE0,
    input        PCSrcE,          // Sinal do Branch
    output reg [1:0] ForwardAE, ForwardBE,
    output       StallF, StallD,
    output       FlushD, FlushE
);

  wire loadStall;

  // Lógica de Forwarding
  always @(*) begin
    // ForwardAE
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 5'b0))
      ForwardAE = 2'b10;
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 5'b0))
      ForwardAE = 2'b01;
    else
      ForwardAE = 2'b00;

    // ForwardBE
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 5'b0))
      ForwardBE = 2'b10;
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 5'b0))
      ForwardBE = 2'b01;
    else
      ForwardBE = 2'b00;
  end

  // Load Hazard: parar F e D, zerar E
  assign loadStall = ResultSrcE0 & (RdE != 5'b0) &
                   ((Rs1D == RdE) | (Rs2D == RdE));


//   assign StallF = loadStall | BranchE;
//   assign StallD = loadStall | BranchE;
  assign StallF = loadStall;
  assign StallD = loadStall;

  assign FlushD = PCSrcE & ~StallD;
  assign FlushE = loadStall | PCSrcE;  // Limpa ID/EX se load hazard ou branch

endmodule
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
  riscv_pipeline rvsingle(
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

module riscv_pipeline(
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
      ImmSrcD,
      ALUControlD,
      BranchD
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
      BranchE, Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
      RegWriteM, RegWriteW, ResultSrcE[0],
      PCSrcE, ForwardA, ForwardB,
      Stall_Fetch, Stall_Decode, Flush_Decode, Flush_Execute
  );

  // IF - Instruction Fetch
  
  wire [31:0] PCPlus4_IF;
  wire [31:0] PC_Next;
   wire PCSrcE_safe;
   assign PCSrcE_safe = PCSrcE & ~Flush_Execute;     
   mux2 #(32) pc_mux(
       PCPlus4_IF, PCTargetE, PCSrcE_safe, PC_Next
   );

//   mux2 #(32) pc_mux(
//       PCPlus4_IF, PCTargetE, PCSrcE, PC_Next
//   );

  flopenr #(32) pc_reg(
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

  wire [31:0] ImmPC_E;
  assign ImmPC_E = (BranchE | JumpE) ? Imm_ExtE : 32'b0;
  adder pc_add_branch(
      PCE, ImmPC_E, PCTargetE
  );
  wire PCSrcE_raw;
  assign PCSrcE_raw = (BranchE & ZeroE) | JumpE;
  assign PCSrcE     = PCSrcE_raw & ~Flush_Execute;


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
module controller(
  input wire [6:0] op,
  input wire [2:0] funct3,
  input wire funct7b5,
  input wire Zero,
  output wire [1:0] ResultSrc,
  output wire MemWrite,
  output wire PCSrc, ALUSrc,
  output wire RegWrite, Jump,
  output wire [1:0] ImmSrc,
  output wire [2:0] ALUControl,
  output wire Branch
);

  wire [1:0] ALUOp;

  maindec md(
    op, ResultSrc, MemWrite, Branch,
    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp
  );

  aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

  assign PCSrc = (Branch & Zero) | Jump;

endmodule