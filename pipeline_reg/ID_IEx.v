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