#!/usr/bin/env bash

run_essential_packages() {
    step_start "Installing essential CLI packages"

    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        htop \
        jq \
        ripgrep \
        tree \
        unzip \
        wget \
        zsh

    step_done "Essential CLI packages installed"
}

register_step "essential_packages" "Essential CLI packages" "run_essential_packages"
