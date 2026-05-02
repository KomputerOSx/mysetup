#!/usr/bin/env bash

run_rxterminal() {
    step_start "Installing RxTerminal"

    curl -fsSL https://packages.strixon.co.uk/install-rxterminal.sh | bash

    step_done "RxTerminal installed"
}

register_step "rxterminal" "RxTerminal installation" "run_rxterminal"
