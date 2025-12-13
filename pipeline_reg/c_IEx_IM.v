// Pipeline Register entre EX e MEM para sinais de controle
module c_IEx_IM (
    input clk, reset,
    input RegWriteE, MemWriteE,
    input [1:0] ResultSrcE,

    output reg RegWriteM, MemWriteM,
    output reg [1:0] ResultSrcM
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        RegWriteM  <= 1'b0;
        MemWriteM  <= 1'b0;
        ResultSrcM <= 2'b00;
    end
    else begin
        RegWriteM  <= RegWriteE;
        MemWriteM  <= MemWriteE;
        ResultSrcM <= ResultSrcE;
    end
end

endmodule
