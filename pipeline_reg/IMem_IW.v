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
