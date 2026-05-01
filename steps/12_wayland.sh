#!/usr/bin/env bash

run_wayland() {
    step_start "Installing Wayland session support"

    sudo apt-get update
    sudo apt-get install -y \
        gnome-session \
        ubuntu-session \
        wayland-protocols \
        xwayland

    add_logout_notice "Log out, select the Ubuntu Wayland session from the login screen, then sign back in."

    step_done "Wayland session support installed"
}

register_step "wayland" "Wayland session support" "run_wayland"
