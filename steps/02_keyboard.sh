#!/usr/bin/env bash

run_keyboard() {
    step_start "Configuring keyboard settings"

    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
    gsettings set org.gnome.desktop.peripherals.keyboard delay 200
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 40

    step_done "Keyboard settings configured"
}

register_step "keyboard" "Keyboard settings" "run_keyboard"
