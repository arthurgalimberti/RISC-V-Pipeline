// Pipeline Register entre ID e EX
module ID_IEx (
    input clk, reset, clear,
    input [31:0] RD1D, RD2D, PCD,
    input [4:0]  Rs1D, Rs2D, RdD,
    input [31:0] ImmExtD, PCPlus4D,

    output reg [31:0] RD1E, RD2E, PCE,
    output reg [4:0]  Rs1E, Rs2E, RdE,
    output reg [31:0] ImmExtE, PCPlus4E
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        RD1E <= 32'b0;
        RD2E <= 32'b0;
        PCE <= 32'b0;
        Rs1E <= 5'b0;
        Rs2E <= 5'b0;
        RdE <= 5'b0;
        ImmExtE <= 32'b0;
        PCPlus4E <= 32'b0;
    end
    else if (clear) begin
        RD1E <= 32'b0;
        RD2E <= 32'b0;
        PCE <= 32'b0;
        Rs1E <= 5'b0;
        Rs2E <= 5'b0;
        RdE <= 5'b0;
        ImmExtE <= 32'b0;
        PCPlus4E <= 32'b0;
    end
    else begin
        RD1E <= RD1D;
        RD2E <= RD2D;
        PCE <= PCD;
        Rs1E <= Rs1D;
        Rs2E <= Rs2D;
        RdE <= RdD;
        ImmExtE <= ImmExtD;
        PCPlus4E <= PCPlus4D;
    end
end
endmodule