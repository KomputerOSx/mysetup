#!/usr/bin/env bash

run_tailscale() {
    step_start "Installing Tailscale"

    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up

    step_done "Tailscale installed and started"
}

register_step "tailscale" "Tailscale installation" "run_tailscale"
