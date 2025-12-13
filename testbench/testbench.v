module testbench();

  reg clk;
  reg reset;

  wire [31:0] WriteData, DataAdr;
  wire MemWrite;

  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  initial begin
    reset <= 1; #22; reset <= 0;
  end

  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 && WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end

  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, testbench);
  end
endmodule