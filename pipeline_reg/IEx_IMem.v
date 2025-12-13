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
