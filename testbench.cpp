#include "Vtop.h"
#include "verilated.h"
#include <iostream>

vluint64_t main_time = 0;

// Função para avançar o clock uma vez (uma borda baixa + alta)
void tick(Vtop* top) {
    // Clock baixo
    top->clk = 0;
    top->eval();
    main_time++;

    // Clock alto
    top->clk = 1;
    top->eval();
    main_time++;
}

// Função para aplicar reset por um tempo
void apply_reset(Vtop* top, vluint64_t duration) {
    top->reset = 1;
    for (vluint64_t i = 0; i < duration; i++) {
        tick(top);
    }
    top->reset = 0;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtop* top = new Vtop;

    // Inicializa sinais
    top->clk = 0;
    top->reset = 1;

    const vluint64_t MAX_TIME = 1000;
    const vluint64_t RESET_DURATION = 20;

    // Aplica reset inicial
    apply_reset(top, RESET_DURATION);

    // Loop principal de simulação
    while (!Verilated::gotFinish() && main_time < MAX_TIME) {

        tick(top); // avança clock

        // Monitoramento de escrita na memória
        if (top->MemWrite) {
            if (top->DataAdr == 100 && top->WriteData == 25) {
                std::cout << "Simulation succeeded" << std::endl;
                break; // termina simulação limpa
            } else if (top->DataAdr != 96) {
                std::cout << "Simulation failed" << std::endl;
                break; // termina simulação limpa
            }
        }
    }

    // Limpeza
    top->final();
    delete top;

    return 0;
}