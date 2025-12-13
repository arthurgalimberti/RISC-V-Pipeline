
// Unidade de Hazard
module hazardunit(
    input  [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
    input  [4:0] RdE, RdM, RdW,
    input        RegWriteM, RegWriteW,
    input        ResultSrcE0, PCSrcE,

    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output            StallD, StallF,
    output            FlushD, FlushE
);

wire lwStall;

// ---------------------------
// Forwarding Unit
// ---------------------------
always @(*) begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forward A
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0))
        ForwardAE = 2'b10;
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0))
        ForwardAE = 2'b01;

    // Forward B
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0))
        ForwardBE = 2'b10;
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0))
        ForwardBE = 2'b01;
end

// ---------------------------
// Load-Use Hazard Stall
// ---------------------------
assign lwStall = ResultSrcE0 & ((RdE == Rs1D) | (RdE == Rs2D));

assign StallF = lwStall;
assign StallD = lwStall;

// ---------------------------
// Control Hazard (branch taken)
// ---------------------------
assign FlushE = lwStall | PCSrcE;
assign FlushD = PCSrcE;

endmodule