#!/usr/bin/env bash

run_claude() {
    step_start "Installing Claude Code"

    if command_exists claude; then
        step_warn "Claude Code already installed"
    else
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    step_done "Claude Code installed"
}

register_step "claude" "Claude Code installation" "run_claude"
