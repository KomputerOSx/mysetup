#!/usr/bin/env bash

run_workspaces() {
    step_start "Configuring workspace keybindings"

    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
    gsettings set org.gnome.desktop.wm.preferences workspace-names "['Browsing', 'Programming', 'Communication', 'Music', 'Writing', 'Misc']"

    if gsettings list-schemas | grep -qx 'org.gnome.shell.extensions.dash-to-dock'; then
        gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    fi

    for index in {1..9}; do
        gsettings set org.gnome.shell.keybindings "switch-to-application-$index" "['<Alt>$index']"
    done

    for index in {1..6}; do
        gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$index" "['<Super>$index']"
        gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$index" "['<Super><Shift>$index']"
    done

    step_done "Workspace keybindings configured"
}

register_step "workspaces" "Workspace keybindings" "run_workspaces"
