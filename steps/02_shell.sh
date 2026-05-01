#!/usr/bin/env bash

run_shell_setup() {
    local zsh_path

    step_start "Configuring shell"

    sudo apt-get update
    sudo apt-get install -y zsh

    zsh_path="$(command -v zsh)"
    if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
        sudo chsh -s "$zsh_path" "$USER"
        add_logout_notice "Default shell changed to zsh."
    fi

    if [ -f ~/.bashrc ] && ! grep -q 'mise activate bash' ~/.bashrc; then
        echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> ~/.bashrc
    fi

    if [ -f ~/.zshrc ]; then
        backup_path ~/.zshrc
    fi

    if [ ! -f ~/.zshrc ] || ! grep -q 'mise activate zsh' ~/.zshrc; then
        cat >> ~/.zshrc <<'EOF'

if [ -x "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
EOF
    fi

    step_done "Shell configured"
}

register_step "shell_setup" "Shell setup" "run_shell_setup"
