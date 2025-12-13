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