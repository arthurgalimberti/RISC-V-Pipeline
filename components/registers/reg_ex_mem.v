module reg_ex_mem(input        clk, reset,
                  input        RegWriteE, MemWriteE,
                  input  [1:0] ResultSrcE,
                  input  [31:0] ALUResultE, WriteDataE, PCPlus4E,
                  input  [4:0]  RdE,
                  output reg        RegWriteM, MemWriteM,
                  output reg [1:0]  ResultSrcM,
                  output reg [31:0] ALUResultM, WriteDataM, PCPlus4M,
                  output reg [4:0]  RdM);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteM <= 0; MemWriteM <= 0; ResultSrcM <= 0;
      ALUResultM <= 0; WriteDataM <= 0; PCPlus4M <= 0; RdM <= 0;
    end else begin
      RegWriteM <= RegWriteE; MemWriteM <= MemWriteE; ResultSrcM <= ResultSrcE;
      ALUResultM <= ALUResultE; WriteDataM <= WriteDataE; PCPlus4M <= PCPlus4E; RdM <= RdE;
    end
  end
endmodule