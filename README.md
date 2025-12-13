**Para compilar:**
iverilog -o riscv.tb riscv_pipeline.v .\riscv\riscv_fd.v .\riscv\riscv_uc.v .\modules\adder.v .\modules\alu.v .\modules\extend.v .\modules\flopenr.v .\modules\mux.v .\modules\regfile.v .\modules\aludec.v .\modules\maindec.v .\modules\memorias.v .\pipeline_reg\ID_IEx.v .\pipeline_reg\IEx_IMem.v .\pipeline_reg\IF_ID.v .\pipeline_reg\IMem_IW.v .\pipeline_units\hazard_unit.v .\testbench\testbench.v

**Para executar:**
vvp riscv.tb
(finish)

**Para depurar:**
gtkwave dump.vcd
