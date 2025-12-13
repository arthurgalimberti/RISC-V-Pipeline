module regfile(input        clk,
               input        we3,
               input  [4:0] a1, a2, a3,
               input  [31:0] wd3,
               output reg [31:0] rd1, rd2);
  reg [31:0] rf[31:0];
  always @(posedge clk)
    if (we3) rf[a3] <= wd3;

  always @(*) begin
    if (a1 == 0) rd1 = 0;
    else if (a1 == a3 && we3) rd1 = wd3;
    else rd1 = rf[a1];

    if (a2 == 0) rd2 = 0;
    else if (a2 == a3 && we3) rd2 = wd3;
    else rd2 = rf[a2];
  end
endmodule