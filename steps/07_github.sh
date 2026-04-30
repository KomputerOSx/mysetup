#!/usr/bin/env bash

run_github() {
    if [ -z "$GITHUB_EMAIL" ]; then
        step_warn "Skipping GitHub SSH setup (no email provided)"
        echo ""
        return
    fi

    step_start "Setting up GitHub SSH authentication"

    sudo apt update && sudo apt install gh -y
    gh auth login --git-protocol ssh --web

    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f ~/.ssh/id_ed25519 -N ""
    fi

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-$(date +%Y%m%d)"
    ssh -T git@github.com

    step_done "GitHub SSH authentication configured"
}

register_step "github" "GitHub SSH authentication" "run_github"
