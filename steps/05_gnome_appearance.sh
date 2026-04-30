#!/usr/bin/env bash

run_gnome_appearance() {
    step_start "Configuring GNOME appearance preferences"

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

    step_done "GNOME appearance preferences configured"
}

register_step "gnome_appearance" "GNOME appearance preferences" "run_gnome_appearance"
