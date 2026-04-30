#!/usr/bin/env bash

run_ngrok() {
    step_start "Installing ngrok"

    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
      | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
      && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
      | sudo tee /etc/apt/sources.list.d/ngrok.list \
      && sudo apt update \
      && sudo apt install -y ngrok

    if [ $? -eq 0 ]; then
        step_done "ngrok installed successfully"

        echo -e "${BLUE}Please enter your ngrok auth token:${NC}"
        echo -e "${YELLOW}(You can get this from https://dashboard.ngrok.com/get-started/your-authtoken)${NC}"
        read -p "Auth token: " NGROK_TOKEN

        if [ -n "$NGROK_TOKEN" ]; then
            ngrok config add-authtoken "$NGROK_TOKEN"
            step_done "ngrok authenticated successfully"
        else
            step_warn "Skipping authentication (no token provided)"
            step_warn "You can authenticate later with: ngrok config add-authtoken <YOUR_TOKEN>"
        fi
    else
        step_error "Failed to install ngrok"
    fi

    echo ""
}

register_step "ngrok" "ngrok installation" "run_ngrok"
