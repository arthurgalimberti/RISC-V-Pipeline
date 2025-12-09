module testbench();

  reg clk;
  reg reset;

  wire [31:0] WriteData, DataAdr;
  wire MemWrite;

  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  initial begin
    reset <= 1; #22; reset <= 0;
  end

  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 && WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end

  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, testbench);
  end
endmodule

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

module datapath(
  input wire clk, reset,
  input wire [1:0] ResultSrc,
  input wire PCSrc, ALUSrc,
  input wire RegWrite,
  input wire [1:0] ImmSrc,
  input wire [2:0] ALUControl,
  output wire Zero,
  output wire [31:0] PC,
  input wire [31:0] Instr,
  output wire [31:0] ALUResult, WriteData,
  input wire [31:0] ReadData
);

  wire [31:0] PCNext, PCPlus4, PCTarget;
  wire [31:0] ImmExt;
  wire [31:0] SrcA, SrcB;
  wire [31:0] Result;

  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder pcadd4(PC, 32'd4, PCPlus4);
  adder pcaddbranch(PC, ImmExt, PCTarget);

  mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

  regfile rf(
    clk, RegWrite, Instr[19:15], Instr[24:20],
    Instr[11:7], Result, SrcA, WriteData
  );

  extend ext(Instr[31:7], ImmSrc, ImmExt);

  mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

  alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero);

  mux3 #(32) resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

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

module adder(
  input wire [31:0] a, b, 
  output wire [31:0] y
);
  assign y = a + b;
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
      2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
      2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      default: immext = 32'b0;
    endcase
  end

endmodule

// Flip-flop com reset síncrono
module flopr #(parameter WIDTH = 8)(
  input wire clk, reset,
  input wire [WIDTH-1:0] d,
  output reg [WIDTH-1:0] q
);

  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else       q <= d;

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