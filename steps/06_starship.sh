#!/usr/bin/env bash

run_starship() {
    step_start "Installing and configuring Starship prompt"

    curl -sS https://starship.rs/install.sh | sh

    if ! grep -q "starship init bash" ~/.bashrc; then
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
    fi

    starship preset catppuccin-powerline -o ~/.config/starship.toml

    step_done "Starship prompt configured"

    read -p "Do you want to open starship.toml in VS Code to customize it? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        step_start "Opening starship.toml in VS Code"
        echo -e "${BLUE}Tip: Add an extra '\$line_break\\' before '\$character' for extra spacing${NC}"
        code ~/.config/starship.toml
        read -p "Press Enter when you're done editing..."
    fi
    echo ""
}

register_step "starship" "Starship prompt installation" "run_starship"
