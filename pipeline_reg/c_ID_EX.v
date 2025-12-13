
// Pipeline Register entre ID e EX para sinais de controle
module c_ID_IEx (
    input clk, reset, clear,
    input RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcAD,
    input [1:0] ALUSrcBD,
    input [1:0] ResultSrcD,
    input [3:0] ALUControlD,

    output reg RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcAE,
    output reg [1:0] ALUSrcBE,
    output reg [1:0] ResultSrcE,
    output reg [3:0] ALUControlE
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        RegWriteE   <= 1'b0;
        MemWriteE   <= 1'b0;
        JumpE       <= 1'b0;
        BranchE     <= 1'b0;
        ALUSrcAE    <= 1'b0;
        ALUSrcBE    <= 2'b00;
        ResultSrcE  <= 2'b00;
        ALUControlE <= 4'b0000;
    end
    else if (clear) begin
        RegWriteE   <= 1'b0;
        MemWriteE   <= 1'b0;
        JumpE       <= 1'b0;
        BranchE     <= 1'b0;
        ALUSrcAE    <= 1'b0;
        ALUSrcBE    <= 2'b00;
        ResultSrcE  <= 2'b00;
        ALUControlE <= 4'b0000;
    end
    else begin
        RegWriteE   <= RegWriteD;
        MemWriteE   <= MemWriteD;
        JumpE       <= JumpD;
        BranchE     <= BranchD;
        ALUSrcAE    <= ALUSrcAD;
        ALUSrcBE    <= ALUSrcBD;
        ResultSrcE  <= ResultSrcD;
        ALUControlE <= ALUControlD;
    end
end

endmodule