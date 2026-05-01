#!/usr/bin/env bash

run_launchers() {
    step_start "Configuring application launcher keybindings"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Launch Chrome"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "google-chrome"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>b"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Launch Firefox"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "firefox"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super><Shift>b"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "Launch VS Code"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "code"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "<Super>c"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name "Launch Files"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command "nautilus"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding "<Super>e"

    gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

    if command -v ulauncher &> /dev/null; then
        mkdir -p ~/.config/ulauncher
        ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

        if [ -f "$ULAUNCHER_SETTINGS" ]; then
            sed -i 's/"hotkey-show-app": *"[^"]*"/"hotkey-show-app": "<Primary>space"/' "$ULAUNCHER_SETTINGS"
        else
            cat > "$ULAUNCHER_SETTINGS" <<'EOF'
{
    "hotkey-show-app": "<Primary>space",
    "show-indicator-icon": true,
    "show-recent-apps": "0",
    "theme-name": "dark"
}
EOF
        fi

        pkill -f ulauncher
        nohup ulauncher --hide-window > /dev/null 2>&1 &
    fi

    step_done "Application launcher keybindings configured"
}

register_step "launchers" "Application launcher keybindings" "run_launchers"
