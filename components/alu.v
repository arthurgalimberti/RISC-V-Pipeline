module alu(input  [31:0] a, b,
           input  [2:0]  alucontrol,
           output reg [31:0] result,
           output       zero);

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
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
endmodule