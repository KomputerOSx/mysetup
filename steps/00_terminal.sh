#!/usr/bin/env bash

install_zellij_from_github() {
    local arch
    local os
    local filename
    local tmp_dir
    local url

    arch="$(uname -m)"
    os="$(uname -s)"
    case "$os" in
        Darwin)
            filename="zellij-${arch}-apple-darwin.tar.gz"
            ;;
        Linux)
            filename="zellij-${arch}-unknown-linux-musl.tar.gz"
            ;;
        *)
            step_error "Unsupported OS for Zellij release install: $os"
            return 1
            ;;
    esac

    tmp_dir="$(mktemp -d)"
    url="https://github.com/zellij-org/zellij/releases/latest/download/$filename"

    curl -fL "$url" -o "$tmp_dir/$filename"
    tar -xf "$tmp_dir/$filename" -C "$tmp_dir"
    sudo install -m 755 "$tmp_dir/zellij" /bin/zellij
    rm -rf "$tmp_dir"

    if [ -f "/bin/zellij" ]; then
        step_done "Zellij binary installed successfully"
    else
        step_error "Zellij binary not installed successfully"
        return 1
    fi
}

apply_terminal_theme() {
    local theme="$1"
    local alacritty_theme="$SCRIPT_DIR/config/alacritty/themes/$theme.toml"
    local zellij_config="$HOME/.config/zellij/config.kdl"

    if [ -f "$alacritty_theme" ]; then
        cp "$alacritty_theme" ~/.config/alacritty/theme.toml
    fi

    if grep -q '^theme "' "$zellij_config"; then
        sed -i "s#^theme \".*\"#theme \"$theme\"#" "$zellij_config"
    else
        printf '\ntheme "%s"\n' "$theme" >> "$zellij_config"
    fi
}

choose_terminal_theme() {
    local theme

    theme=$(whiptail --notags --title "Terminal Theme" --menu \
        "Choose a theme for Alacritty and Zellij:" 17 78 7 \
        "keep" "Keep the copied config theme" \
        "kanagawa" "Kanagawa" \
        "catppuccin" "Catppuccin" \
        "gruvbox" "Gruvbox" \
        "rose-pine" "Rose Pine" \
        "tokyo-night" "Tokyo Night" \
        "ristretto" "Ristretto" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ] || [ "$theme" = "keep" ]; then
        return
    fi

    apply_terminal_theme "$theme"
    step_done "Terminal theme set to $theme"
}

run_terminal() {
    step_start "Installing Alacritty and Zellij"

    sudo apt-get update
    if ! command_exists alacritty; then
        sudo apt-get install -y alacritty
    else
        step_warn "Alacritty already installed"
    fi

    if ! command_exists zellij; then
        sudo apt-get install -y zellij || install_zellij_from_github
    else
        step_warn "Zellij already installed"
    fi

    backup_path ~/.config/alacritty
    backup_path ~/.config/zellij

    mkdir -p ~/.config/alacritty ~/.config/zellij
    cp -R "$SCRIPT_DIR/config/alacritty/." ~/.config/alacritty/
    cp -R "$SCRIPT_DIR/config/zellij/." ~/.config/zellij/
    choose_terminal_theme
    add_restart_notice "Open a new terminal window for Alacritty/Zellij config changes."

    step_done "Alacritty, Zellij, and terminal configs installed"
}

register_step "terminal" "Alacritty and Zellij terminal setup" "run_terminal"
