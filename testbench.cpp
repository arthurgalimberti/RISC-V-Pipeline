#include "Vtop.h"
#include "verilated.h"
#include <iostream>

vluint64_t main_time = 0;

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    Vtop* top = new Vtop;

    top->clk = 0;
    top->reset = 1;

    while (!Verilated::gotFinish() && main_time < 1000) { // Timeout de segurança
        
        // Toggle do Clock
        if ((main_time % 10) == 0) {
            top->clk = !top->clk;
        }

        // Tira o Reset após um tempo
        if (main_time > 20) {
            top->reset = 0;
        }

        // Avalia o circuito
        top->eval();

        main_time++;
    }

    // Limpeza
    top->final();
    delete top;
    return 0;
}