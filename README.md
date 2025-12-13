**Para executar a simulação é necessário ter o simulator Verilator, caso não tenha em Linux:**
sudo apt-get install verilator build-essential

**Para converter os arquivos de Verilog para C++, execute:**
verilator -cc --Mdir build -f riscv.f --top-module top --exe testbench.cpp

**Para compilar os arquivos gerados em C++:**
make -j -C build -f Vtop.mk Vtop

**Para executar a simulação:**
./build/Vtop