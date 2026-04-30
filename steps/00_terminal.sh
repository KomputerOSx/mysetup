#!/usr/bin/env bash

install_zellij_from_github() {
    local arch
    local target
    local tmp_dir
    local download_url

    arch="$(uname -m)"
    case "$arch" in
        x86_64) target="x86_64-unknown-linux-musl" ;;
        aarch64|arm64) target="aarch64-unknown-linux-musl" ;;
        *)
            step_error "Unsupported architecture for Zellij release install: $arch"
            return 1
            ;;
    esac

    tmp_dir="$(mktemp -d)"
    download_url="$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest \
        | sed -n "s/.*\"browser_download_url\": \"\\(.*zellij-${target}\\.tar\\.gz\\)\".*/\\1/p" \
        | head -n 1)"

    if [ -z "$download_url" ]; then
        step_error "Could not find a Zellij release for $target"
        return 1
    fi

    curl -fL "$download_url" -o "$tmp_dir/zellij.tar.gz"
    tar -xzf "$tmp_dir/zellij.tar.gz" -C "$tmp_dir"
    sudo install -m 755 "$tmp_dir/zellij" /usr/local/bin/zellij
    rm -rf "$tmp_dir"
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
    sudo apt-get install -y alacritty

    if ! command -v zellij &> /dev/null; then
        sudo apt-get install -y zellij || install_zellij_from_github
    fi

    mkdir -p ~/.config/alacritty ~/.config/zellij
    cp -R "$SCRIPT_DIR/config/alacritty/." ~/.config/alacritty/
    cp -R "$SCRIPT_DIR/config/zellij/." ~/.config/zellij/
    choose_terminal_theme

    step_done "Alacritty, Zellij, and terminal configs installed"
}

register_step "terminal" "Alacritty and Zellij terminal setup" "run_terminal"
