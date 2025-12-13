module top(
  input wire clk,
  input wire reset,
  output wire [31:0] WriteData,
  output wire [31:0] DataAdr,
  output wire MemWrite
);

  wire [31:0] PC, Instr, ReadData;

  riscvsingle rvsingle(
    clk, reset, PC, Instr, MemWrite, DataAdr,
    WriteData, ReadData
  );

  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(
  input wire clk, reset,
  output wire [31:0] PC,
  input wire [31:0] Instr,
  output wire MemWrite,
  output wire [31:0] ALUResult, WriteData,
  input wire [31:0] ReadData
);

  wire ALUSrc, RegWrite, Jump, Zero;
  wire [1:0] ResultSrc, ImmSrc;
  wire [2:0] ALUControl;
  wire PCSrc;

  controller c(
    Instr[6:0], Instr[14:12], Instr[30], Zero,
    ResultSrc, MemWrite, PCSrc,
    ALUSrc, RegWrite, Jump,
    ImmSrc, ALUControl
  );

  datapath dp(
    clk, reset, ResultSrc, PCSrc,
    ALUSrc, RegWrite,
    ImmSrc, ALUControl,
    Zero, PC, Instr,
    ALUResult, WriteData, ReadData
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
  output wire [2:0] ALUControl
);

  wire [1:0] ALUOp;
  wire Branch;

  maindec md(
    op, ResultSrc, MemWrite, Branch,
    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp
  );

  aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

  assign PCSrc = (Branch & Zero) | Jump;

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



