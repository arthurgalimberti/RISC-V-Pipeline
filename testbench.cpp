#include "Vtop.h"
#include "verilated.h"
#include <iostream>

static vluint64_t main_time = 0;

void tick(Vtop* top) {
    top->eval();
    main_time++;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vtop* top = new Vtop;

    top->clk   = 0;
    top->reset = 1;

    const vluint64_t MAX_TIME = 1000;
    const vluint64_t RESET_RELEASE_TIME = 20;

    while (!Verilated::gotFinish() && main_time < MAX_TIME) {
        top->clk = 0;
        tick(top);

        // Libera reset após um tempo
        if (main_time > RESET_RELEASE_TIME) {
            top->reset = 0;
        }

        top->clk = 1;
        tick(top);
    }

    top->final();
    delete top;
    return 0;
}