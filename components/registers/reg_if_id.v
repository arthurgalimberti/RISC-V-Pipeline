module reg_if_id(input        clk, reset,
                 input        en, clear,
                 input  [31:0] InstrF, PCF, PCPlus4F,
                 output reg [31:0] InstrD, PCD, PCPlus4D);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrD <= 0; PCD <= 0; PCPlus4D <= 0;
    end else if (en) begin
      if (clear) begin
        InstrD <= 0; PCD <= 0; PCPlus4D <= 0;
      end else begin
        InstrD <= InstrF; PCD <= PCF; PCPlus4D <= PCPlus4F;
      end
    end
  end
endmodule