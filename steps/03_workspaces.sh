#!/usr/bin/env bash

run_workspaces() {
    step_start "Configuring workspace keybindings"

    for index in {1..9}; do
        gsettings set org.gnome.shell.keybindings "switch-to-application-$index" "[]"
        gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$index" "['<Super>$index', '<Alt>$index']"
    done

    step_done "Workspace keybindings configured"
}

register_step "workspaces" "Workspace keybindings" "run_workspaces"
