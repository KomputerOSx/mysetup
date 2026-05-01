#!/usr/bin/env bash

install_jetbrains_nerd_font() {
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    local tmp_dir
    local download_url

    if find "$font_dir" -type f -name '*Nerd Font*.ttf' 2>/dev/null | grep -q .; then
        step_warn "JetBrainsMono Nerd Font already installed"
        return
    fi

    tmp_dir="$(mktemp -d)"
    download_url="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | sed -n 's/.*"browser_download_url": "\(.*JetBrainsMono.zip\)".*/\1/p' \
        | head -n 1)"

    if [ -z "$download_url" ]; then
        step_error "Could not find latest JetBrainsMono Nerd Font release"
        rm -rf "$tmp_dir"
        return 1
    fi

    mkdir -p "$font_dir"
    curl -fL "$download_url" -o "$tmp_dir/JetBrainsMono.zip"
    unzip -oq "$tmp_dir/JetBrainsMono.zip" -d "$font_dir"
    fc-cache -f "$font_dir"
    rm -rf "$tmp_dir"
}

run_fonts() {
    step_start "Installing development fonts"

    sudo apt-get update
    sudo apt-get install -y fontconfig unzip
    install_jetbrains_nerd_font
    add_restart_notice "Restart terminal/editor apps to pick up newly installed fonts."

    step_done "Development fonts installed"
}

register_step "fonts" "Development fonts" "run_fonts"
