#!/usr/bin/env bash

install_vscode() {
    step_start "Installing VS Code"

    if command_exists code; then
        step_warn "VS Code already installed"
        echo ""
        return
    fi

    if [ ! -f /usr/share/keyrings/microsoft.gpg ]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
            | gpg --dearmor \
            | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
    fi

    if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y code

    step_done "VS Code installed"
}

install_lazyvim() {
    step_start "Installing LazyVim"

    if [ -d "$HOME/.config/nvim" ]; then
        step_warn "Skipping LazyVim install because ~/.config/nvim already exists"
        echo ""
        return
    fi

    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"

    add_restart_notice "Open Neovim once to let LazyVim finish bootstrapping plugins."
    step_done "LazyVim installed"
}

install_lazydocker() {
    step_start "Installing Lazydocker"

    if command_exists lazydocker; then
        step_warn "Lazydocker already installed"
        echo ""
        return
    fi

    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

    step_done "Lazydocker installed"
}

install_google_chrome() {
    step_start "Installing Google Chrome"

    if command_exists google-chrome || command_exists google-chrome-stable; then
        step_warn "Google Chrome already installed"
        echo ""
        return
    fi

    if [ ! -f /usr/share/keyrings/google-chrome.gpg ]; then
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
            | gpg --dearmor \
            | sudo tee /usr/share/keyrings/google-chrome.gpg > /dev/null
    fi

    if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
            | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y google-chrome-stable

    step_done "Google Chrome installed"
}

install_thunderbird() {
    step_start "Installing Thunderbird mail"

    if command_exists thunderbird; then
        step_warn "Thunderbird already installed"
        echo ""
        return
    fi

    sudo apt-get install -y thunderbird

    step_done "Thunderbird mail installed"
}

run_essential_packages() {
    step_start "Installing essential CLI packages"

    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        gpg \
        git \
        htop \
        jq \
        neovim \
        ripgrep \
        software-properties-common \
        tree \
        unzip \
        wget \
        zsh

    step_done "Essential CLI packages installed"

    install_vscode
    install_lazyvim
    install_lazydocker
    install_google_chrome
    install_thunderbird
}

register_step "essential_packages" "Essential CLI packages" "run_essential_packages"
