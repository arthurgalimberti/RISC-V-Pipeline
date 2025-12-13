// Flip-flop com enable e reset síncrono
module flopenr #(parameter WIDTH = 8)(
  input wire clk, reset, en,
  input wire [WIDTH-1:0] d,
  output reg [WIDTH-1:0] q
);

  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else if (en)  q <= d;

endmodule