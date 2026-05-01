#!/usr/bin/env bash

run_github() {
    local machine_name
    local key_name
    local key_path
    local ssh_config
    local tmp_config

    if [ -z "$GITHUB_EMAIL" ]; then
        step_warn "Skipping GitHub SSH setup (no email provided)"
        echo ""
        return
    fi

    step_start "Setting up GitHub SSH authentication"

    machine_name="$(hostname)"
    key_name="gh-cli-${machine_name}"
    key_path="$HOME/.ssh/$key_name"
    ssh_config="$HOME/.ssh/config"

    sudo apt update && sudo apt install gh -y
    gh auth login --git-protocol ssh --web

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    if [ ! -f "$key_path" ]; then
        ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$key_path" -N ""
    fi

    tmp_config="$(mktemp)"
    if [ -f "$ssh_config" ]; then
        awk '
            /^# BEGIN mysetup github ssh$/ { skip = 1; next }
            /^# END mysetup github ssh$/ { skip = 0; next }
            !skip { print }
        ' "$ssh_config" > "$tmp_config"
    fi

    {
        printf '# BEGIN mysetup github ssh\n'
        printf 'Host github.com\n'
        printf '    HostName github.com\n'
        printf '    User git\n'
        printf '    IdentityFile %s\n' "$key_path"
        printf '    IdentitiesOnly yes\n'
        printf '# END mysetup github ssh\n'
        printf '\n'
        cat "$tmp_config"
    } > "$ssh_config"
    rm -f "$tmp_config"
    chmod 600 "$ssh_config"

    eval "$(ssh-agent -s)"
    ssh-add "$key_path"
    gh ssh-key add "$key_path.pub" --title "$key_name"
    ssh -T git@github.com

    step_done "GitHub SSH authentication configured"
}

register_step "github" "GitHub SSH authentication" "run_github"
