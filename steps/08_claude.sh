#!/usr/bin/env bash

run_claude() {
    step_start "Installing Claude Code"

    curl -fsSL https://claude.ai/install.sh | bash

    step_done "Claude Code installed"
}

register_step "claude" "Claude Code installation" "run_claude"
