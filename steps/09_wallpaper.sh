#!/usr/bin/env bash

run_wallpaper() {
    step_start "Setting up Catppuccin wallpapers"

    mkdir -p ~/Pictures/Wallpapers
    cd ~/Pictures/Wallpapers || return

    if [ ! -d catppuccin-wallpapers ]; then
        git clone https://github.com/zhichaoh/catppuccin-wallpapers.git
    fi

    sudo apt install -y gnome-backgrounds

    mkdir -p ~/.local/bin
    cat > ~/.local/bin/cycle-wallpaper.sh <<'EOF'
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/catppuccin-wallpapers/landscapes"
INDEX_FILE="$HOME/.wallpaper_index"

WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort))
TOTAL=${#WALLPAPERS[@]}

if [ "$TOTAL" -eq 0 ]; then
    exit 0
fi

if [ -f "$INDEX_FILE" ]; then
    INDEX=$(cat "$INDEX_FILE")
else
    INDEX=0
fi

WALLPAPER="${WALLPAPERS[$INDEX]}"

gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"

INDEX=$(( (INDEX + 1) % TOTAL ))
echo "$INDEX" > "$INDEX_FILE"
EOF

    chmod +x ~/.local/bin/cycle-wallpaper.sh
    ~/.local/bin/cycle-wallpaper.sh

    (crontab -l 2>/dev/null; echo "0 * * * * $HOME/.local/bin/cycle-wallpaper.sh") | crontab -

    if step_selected "launchers"; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/']"
    else
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/']"
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ name "Cycle Wallpaper"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ command "$HOME/.local/bin/cycle-wallpaper.sh"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ binding "<Super><Alt>space"

    step_done "Catppuccin wallpapers configured with hourly cycling and Super+Alt+Space hotkey"
}

register_step "wallpaper" "Wallpaper setup" "run_wallpaper"
