#!/usr/bin/env bash

install_google_chrome() {
    local deb_path="/tmp/google-chrome-stable_current_amd64.deb"

    if [ "$(dpkg --print-architecture)" != "amd64" ]; then
        step_warn "Skipping Google Chrome: official Linux Chrome package is amd64 only"
        return
    fi

    step_start "Installing Google Chrome"

    curl -fL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o "$deb_path"
    sudo apt-get install -y "$deb_path"
    rm -f "$deb_path"
}

install_vscode() {
    step_start "Installing Visual Studio Code"

    sudo apt-get install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft.gpg
    rm -f /tmp/microsoft.gpg

    sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

    sudo apt-get update
    sudo apt-get install -y code
}

install_mise_and_languages() {
    local ruby_version
    local node_version
    local python_version
    local mise_bin="$HOME/.local/bin/mise"

    step_start "Installing mise"

    curl https://mise.run | sh

    if ! grep -q 'mise activate bash' ~/.bashrc; then
        echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> ~/.bashrc
    fi

    if [ -f ~/.zshrc ] && ! grep -q 'mise activate zsh' ~/.zshrc; then
        echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> ~/.zshrc
    fi

    echo ""
    read -p "Ruby version for mise (press Enter for latest): " ruby_version
    read -p "Node.js version for mise (press Enter for latest): " node_version
    read -p "Python version for mise (press Enter for latest): " python_version

    ruby_version="${ruby_version:-latest}"
    node_version="${node_version:-latest}"
    python_version="${python_version:-latest}"

    "$mise_bin" use -g "ruby@$ruby_version" "node@$node_version" "python@$python_version"
    "$mise_bin" install
}

install_docker() {
    step_start "Installing Docker and Docker Compose"

    sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
}

install_github_release_binary() {
    local repo="$1"
    local binary_name="$2"
    local archive_pattern="$3"
    local extract_name="$4"
    local arch
    local version
    local url
    local tmp_dir

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            step_error "Unsupported architecture for $binary_name: $arch"
            return 1
            ;;
    esac

    version="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n 1)"
    if [ -z "$version" ]; then
        step_error "Could not determine latest $binary_name version"
        return 1
    fi

    url="$(printf "$archive_pattern" "$version" "$version" "$arch")"
    tmp_dir="$(mktemp -d)"

    curl -fL "$url" -o "$tmp_dir/$binary_name.tar.gz"
    tar -xzf "$tmp_dir/$binary_name.tar.gz" -C "$tmp_dir" "$extract_name"
    sudo install -m 755 "$tmp_dir/$extract_name" "/usr/local/bin/$binary_name"
    rm -rf "$tmp_dir"
}

install_lazydocker() {
    step_start "Installing lazydocker"

    install_github_release_binary \
        "jesseduffield/lazydocker" \
        "lazydocker" \
        "https://github.com/jesseduffield/lazydocker/releases/download/v%s/lazydocker_%s_Linux_%s.tar.gz" \
        "lazydocker"
}

install_lazygit() {
    step_start "Installing lazygit"

    if sudo apt-get install -y lazygit; then
        return
    fi

    install_github_release_binary \
        "jesseduffield/lazygit" \
        "lazygit" \
        "https://github.com/jesseduffield/lazygit/releases/download/v%s/lazygit_%s_Linux_%s.tar.gz" \
        "lazygit"
}

install_ngrok_dev() {
    local arch
    local tmp_dir

    step_start "Installing ngrok"

    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            step_error "Unsupported architecture for ngrok: $(uname -m)"
            return 1
            ;;
    esac

    tmp_dir="$(mktemp -d)"
    curl -fL "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz" -o "$tmp_dir/ngrok.tgz"
    sudo tar xzf "$tmp_dir/ngrok.tgz" -C /usr/local/bin
    rm -rf "$tmp_dir"

    echo -e "${BLUE}Please enter your ngrok auth token:${NC}"
    echo -e "${YELLOW}(Press Enter to skip. You can get this from https://dashboard.ngrok.com/get-started/your-authtoken)${NC}"
    read -p "Auth token: " NGROK_TOKEN

    if [ -n "$NGROK_TOKEN" ]; then
        ngrok config add-authtoken "$NGROK_TOKEN"
        step_done "ngrok authenticated successfully"
    else
        step_warn "Skipping ngrok authentication"
        step_warn "You can authenticate later with: ngrok config add-authtoken <YOUR_TOKEN>"
    fi
}

run_dev_setup() {
    step_start "Installing development tools"

    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        gpg \
        libbz2-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libyaml-dev \
        pkg-config \
        tar \
        unzip \
        wget \
        zlib1g-dev

    install_google_chrome
    install_vscode
    install_mise_and_languages
    install_docker
    install_lazydocker
    install_lazygit
    install_ngrok_dev

    step_done "Development tools installed. Log out and back in for Docker group access."
}

register_step "dev_setup" "Development tools setup" "run_dev_setup"
