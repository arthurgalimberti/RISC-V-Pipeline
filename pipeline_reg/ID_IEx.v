// Pipeline Register entre IF e ID
module IF_ID (
    input clk, reset, clear, enable,
    input  [31:0] InstrF, PCF, PCPlus4F,

    output reg [31:0] InstrD, PCD, PCPlus4D
);

  always @(posedge clk or posedge reset) begin
      if (reset) begin
          InstrD    <= 32'b0;
          PCD       <= 32'b0;
          PCPlus4D  <= 32'b0;
      end else if (enable) begin
          if (clear) begin
              InstrD    <= 32'b0;
              PCD       <= 32'b0;
              PCPlus4D  <= 32'b0;
          end else begin
              InstrD    <= InstrF;
              PCD       <= PCF;
              PCPlus4D  <= PCPlus4F;
          end
      end
  end

endmodule