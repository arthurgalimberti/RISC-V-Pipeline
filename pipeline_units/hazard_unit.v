module hazard_unit(
    input  [4:0] Rs1D, Rs2D,
    input  [4:0] Rs1E, Rs2E,
    input  [4:0] RdE, RdM, RdW,
    input        RegWriteM, RegWriteW,
    input        ResultSrcE0,
    input        PCSrcE,          // Sinal do Branch
    output reg [1:0] ForwardAE, ForwardBE,
    output       StallF, StallD,
    output       FlushD, FlushE
);

  wire loadStall;

  // Lógica de Forwarding
  always @(*) begin
    // ForwardAE
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 5'b0))
      ForwardAE = 2'b10;
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 5'b0))
      ForwardAE = 2'b01;
    else
      ForwardAE = 2'b00;

    // ForwardBE
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 5'b0))
      ForwardBE = 2'b10;
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 5'b0))
      ForwardBE = 2'b01;
    else
      ForwardBE = 2'b00;
  end

  // Load Hazard: parar F e D, zerar E
  assign loadStall = ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE));

  assign StallF = loadStall;
  assign StallD = loadStall;

  assign FlushD = PCSrcE;              // Limpa IF/ID se errou a predição
  assign FlushE = loadStall | PCSrcE;  // Limpa ID/EX se load hazard ou branch

endmodule
