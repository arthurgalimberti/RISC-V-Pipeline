**Para compilar:**
iverilog -o riscv.tb riscvsingle.v .\riscv\riscv_fd.v .\modules\adder.v .\modules\alu.v .\modules\extend.v .\modules\floppenr.v .\modules\mux2.v .\modules\mux3.v .\modules\regfile.v .\testbench\testbench.v .\modules\aludec.v .\modules\maindec.v .\modules\memorias.v

**Para executar:**
vvp riscv.tb
(finish)

**Para depurar:**
gtkwave dump.vcd
