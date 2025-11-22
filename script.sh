#!/bin/bash

# ============================================
# Ubuntu/GNOME Configuration Script
# ============================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Clear screen
clear

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Ubuntu/GNOME Configuration Script${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ============================================
# COLLECT ALL INPUTS UPFRONT
# ============================================
echo -e "${YELLOW}First, let's collect necessary information...${NC}"
echo ""

# Get sudo password and keep it cached
echo -e "${BLUE}Enter sudo password (will be cached for the session):${NC}"
sudo -v
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to authenticate. Exiting.${NC}"
    exit 1
fi

# Keep sudo alive in background
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get GitHub email
read -p "Enter your GitHub email (press Enter to skip): " GITHUB_EMAIL

echo ""
echo -e "${GREEN}✓ Information collected${NC}"
echo ""

# ============================================
# INTERACTIVE MENU SELECTION
# ============================================

# Check if whiptail is installed
if ! command -v whiptail &> /dev/null; then
    echo -e "${YELLOW}Installing whiptail for interactive menu...${NC}"
    sudo apt-get update && sudo apt-get install -y whiptail
fi

# Set custom colors for whiptail (Matrix theme - black background, neon green)
# Format: root=fg,bg window=fg,bg border=fg,bg textbox=fg,bg button=fg,bg
export NEWT_COLORS='
root=,black
window=green,black
border=green,black
textbox=green,black
button=black,green
checkbox=green,black
checkboxsel=black,green
title=green,black
entry=green,black
label=green,black
actcheckbox=black,green
actbutton=green,white
compactbutton=green,black
listbox=green,black
actlistbox=black,green
actsellistbox=black,green
'

# First, ask user if they want to select all, deselect all, or customize
PRESET=$(whiptail --title "Quick Selection" --menu \
"Choose a preset or customize your selection:" 15 78 3 \
"1" "Select All (run everything)" \
"2" "Deselect All (choose manually)" \
"3" "Custom (default: all selected)" \
3>&1 1>&2 2>&3)

# Check if user cancelled
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Configuration cancelled.${NC}"
    exit 0
fi

# Handle preset choice
if [ "$PRESET" = "1" ]; then
    # Select All - run everything without showing checklist
    SELECTIONS='"1" "2" "3" "4" "5" "6" "7" "8"'
else
    # Set defaults based on preset choice
    case $PRESET in
        2)
            DEFAULT_STATE="OFF"
            ;;
        3)
            DEFAULT_STATE="ON"
            ;;
    esac

    # Create checklist menu with selected defaults
    SELECTIONS=$(whiptail --title "Configuration Options" --checklist \
    "Use ↑↓ arrows to navigate, SPACE to select/deselect, TAB to switch to buttons:" 22 78 8 \
    "1" "Keyboard settings" $DEFAULT_STATE \
    "2" "Workspace keybindings" $DEFAULT_STATE \
    "3" "Application launcher keybindings" $DEFAULT_STATE \
    "4" "Starship prompt installation" $DEFAULT_STATE \
    "5" "GitHub SSH authentication" $DEFAULT_STATE \
    "6" "Claude Code installation" $DEFAULT_STATE \
    "7" "Wallpaper setup" $DEFAULT_STATE \
    "8" "ngrok installation" $DEFAULT_STATE \
    3>&1 1>&2 2>&3)

    # Check if user cancelled
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Configuration cancelled.${NC}"
        exit 0
    fi
fi

# Parse selections
RUN_KEYBOARD=false
RUN_WORKSPACES=false
RUN_LAUNCHERS=false
RUN_STARSHIP=false
RUN_GITHUB=false
RUN_CLAUDE=false
RUN_WALLPAPER=false
RUN_NGROK=false

for selection in $SELECTIONS; do
    # Remove quotes
    selection=$(echo "$selection" | tr -d '"')
    case $selection in
        1) RUN_KEYBOARD=true ;;
        2) RUN_WORKSPACES=true ;;
        3) RUN_LAUNCHERS=true ;;
        4) RUN_STARSHIP=true ;;
        5) RUN_GITHUB=true ;;
        6) RUN_CLAUDE=true ;;
        7) RUN_WALLPAPER=true ;;
        8) RUN_NGROK=true ;;
    esac
done

clear
echo -e "${BLUE}Starting selected configurations...${NC}"
echo ""

# ============================================
# 1. KEYBOARD SETTINGS
# ============================================
if [ "$RUN_KEYBOARD" = true ]; then
    echo -e "${YELLOW}Configuring keyboard settings...${NC}"

    # Remap Caps Lock to Escape
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

    # Set keyboard repeat rate
    gsettings set org.gnome.desktop.peripherals.keyboard delay 200
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 40

    # Configure Alacritty font size
    mkdir -p ~/.config/alacritty
    cat > ~/.config/alacritty/font-size.toml <<EOF
[font]
size = 16
EOF

    echo -e "${GREEN}✓ Keyboard settings and Alacritty font configured${NC}"
    echo ""
fi

# ============================================
# 2. WORKSPACE KEYBINDINGS
# ============================================
if [ "$RUN_WORKSPACES" = true ]; then
    echo -e "${YELLOW}Configuring workspace keybindings...${NC}"

    # Disable application switcher (Alt+Number)
    gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-7 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-8 "[]"
    gsettings set org.gnome.shell.keybindings switch-to-application-9 "[]"

    # Map Alt+Number and Super+Number to workspaces
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1', '<Alt>1']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2', '<Alt>2']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3', '<Alt>3']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4', '<Alt>4']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5', '<Alt>5']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6', '<Alt>6']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<Super>7', '<Alt>7']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<Super>8', '<Alt>8']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-9 "['<Super>9', '<Alt>9']"

    echo -e "${GREEN}✓ Workspace keybindings configured${NC}"
    echo ""
fi

# ============================================
# 3. APPLICATION LAUNCHER KEYBINDINGS
# ============================================
if [ "$RUN_LAUNCHERS" = true ]; then
    echo -e "${YELLOW}Configuring application launcher keybindings...${NC}"

    # Setup custom keybindings array
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"

    # Super + Enter = Alacritty
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Launch Alacritty"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "alacritty"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>Return"

    # Super + B = Google Chrome
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Launch Chrome"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "google-chrome"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super>b"

    # Super + Shift + B = Firefox
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "Launch Firefox"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "firefox"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "<Super><Shift>b"

    # Super + C = VS Code
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name "Launch VS Code"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command "code"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding "<Super>c"

    # Super + Shift + F = Files (Nautilus)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name "Launch Files"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command "nautilus"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding "<Super><Shift>f"

    # Super + F = Fullscreen
    gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

    # Configure Ulauncher hotkey (Ctrl + Space)
    if command -v ulauncher &> /dev/null; then
        mkdir -p ~/.config/ulauncher
        ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

        if [ -f "$ULAUNCHER_SETTINGS" ]; then
            # Update existing settings
            sed -i 's/"hotkey-show-app": *"[^"]*"/"hotkey-show-app": "<Primary>space"/' "$ULAUNCHER_SETTINGS"
        else
            # Create new settings file with hotkey
            cat > "$ULAUNCHER_SETTINGS" <<'UEOF'
{
    "hotkey-show-app": "<Primary>space",
    "show-indicator-icon": true,
    "show-recent-apps": "0",
    "theme-name": "dark"
}
UEOF
        fi

        # Restart ulauncher to apply settings
        pkill -f ulauncher
        nohup ulauncher --hide-window > /dev/null 2>&1 &
    fi

    echo -e "${GREEN}✓ Application launcher keybindings configured${NC}"
    echo ""
fi

# ============================================
# 4. STARSHIP PROMPT INSTALLATION
# ============================================
if [ "$RUN_STARSHIP" = true ]; then
    echo -e "${YELLOW}Installing and configuring Starship prompt...${NC}"

    # Install Starship
    curl -sS https://starship.rs/install.sh | sh

    # Add Starship to bashrc
    if ! grep -q "starship init bash" ~/.bashrc; then
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
    fi

    # Apply Catppuccin Powerline preset
    starship preset catppuccin-powerline -o ~/.config/starship.toml

    echo -e "${GREEN}✓ Starship prompt configured${NC}"
    echo ""

    # Ask if user wants to edit the starship config
    read -p "Do you want to open starship.toml in VS Code to customize it? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Opening starship.toml in VS Code...${NC}"
        echo -e "${BLUE}Tip: Add an extra '\$line_break\\' before '\$character' for extra spacing${NC}"
        code ~/.config/starship.toml
        read -p "Press Enter when you're done editing..."
    fi
    echo ""
fi

# ============================================
# 5. GITHUB SSH AUTHENTICATION
# ============================================
if [ "$RUN_GITHUB" = true ]; then
    if [ -z "$GITHUB_EMAIL" ]; then
        echo -e "${YELLOW}Skipping GitHub SSH setup (no email provided)${NC}"
        echo ""
    else
        echo -e "${YELLOW}Setting up GitHub SSH authentication...${NC}"

        # Update and install GitHub CLI
        sudo apt update && sudo apt install gh -y

        # Authenticate with GitHub
        gh auth login --git-protocol ssh --web

        # Generate new SSH key if it doesn't exist
        if [ ! -f ~/.ssh/id_ed25519 ]; then
            ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f ~/.ssh/id_ed25519 -N ""
        fi

        # Add SSH key to ssh-agent
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519

        # Add SSH key to GitHub
        gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-$(date +%Y%m%d)"

        # Test connection
        ssh -T git@github.com

        echo -e "${GREEN}✓ GitHub SSH authentication configured${NC}"
        echo ""
    fi
fi

# ============================================
# 6. CLAUDE CODE INSTALLATION
# ============================================
if [ "$RUN_CLAUDE" = true ]; then
    echo -e "${YELLOW}Installing Claude Code...${NC}"

    # Install Claude Code
    curl -fsSL https://claude.ai/install.sh | bash

    echo -e "${GREEN}✓ Claude Code installed${NC}"
    echo ""
fi

# ============================================
# 7. WALLPAPER SETUP
# ============================================
if [ "$RUN_WALLPAPER" = true ]; then
    echo -e "${YELLOW}Setting up Catppuccin wallpapers...${NC}"

    # Create wallpapers directory and clone repo
    mkdir -p ~/Pictures/Wallpapers
    cd ~/Pictures/Wallpapers
    git clone https://github.com/zhichaoh/catppuccin-wallpapers.git
    cd catppuccin-wallpapers/landscapes

    # Install gnome-background-properties for wallpaper cycling
    sudo apt install -y gnome-backgrounds

    # Create a script to cycle wallpapers in order
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/cycle-wallpaper.sh <<'EOF'
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/catppuccin-wallpapers/landscapes"
INDEX_FILE="$HOME/.wallpaper_index"

# Get sorted list of wallpapers
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort))
TOTAL=${#WALLPAPERS[@]}

# Read current index, default to 0
if [ -f "$INDEX_FILE" ]; then
    INDEX=$(cat "$INDEX_FILE")
else
    INDEX=0
fi

# Get current wallpaper
WALLPAPER="${WALLPAPERS[$INDEX]}"

# Set wallpaper
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"

# Increment index and wrap around
INDEX=$(( (INDEX + 1) % TOTAL ))
echo "$INDEX" > "$INDEX_FILE"
EOF

    chmod +x ~/.local/bin/cycle-wallpaper.sh

    # Set initial wallpaper
    ~/.local/bin/cycle-wallpaper.sh

    # Add cron job to cycle wallpaper every hour
    (crontab -l 2>/dev/null; echo "0 * * * * $HOME/.local/bin/cycle-wallpaper.sh") | crontab -

    # Add keybinding for manual wallpaper cycling (Super + Alt + Space)
    # Check if launcher keybindings were also configured
    if [ "$RUN_LAUNCHERS" = true ]; then
        # Include all launcher keybindings + wallpaper keybinding
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/']"
    else
        # Only include wallpaper keybinding
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/']"
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ name "Cycle Wallpaper"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ command "$HOME/.local/bin/cycle-wallpaper.sh"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ binding "<Super><Alt>space"

    echo -e "${GREEN}✓ Catppuccin wallpapers configured with hourly cycling and Super+Alt+Space hotkey${NC}"
    echo ""
fi

# ============================================
# 8. NGROK INSTALLATION
# ============================================
if [ "$RUN_NGROK" = true ]; then
    echo -e "${YELLOW}Installing ngrok...${NC}"

    # Add ngrok repository and install
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
      | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
      && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
      | sudo tee /etc/apt/sources.list.d/ngrok.list \
      && sudo apt update \
      && sudo apt install -y ngrok

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ngrok installed successfully${NC}"
        echo ""

        # Ask for auth token
        echo -e "${BLUE}Please enter your ngrok auth token:${NC}"
        echo -e "${YELLOW}(You can get this from https://dashboard.ngrok.com/get-started/your-authtoken)${NC}"
        read -p "Auth token: " NGROK_TOKEN

        if [ -n "$NGROK_TOKEN" ]; then
            ngrok config add-authtoken "$NGROK_TOKEN"
            echo -e "${GREEN}✓ ngrok authenticated successfully${NC}"
        else
            echo -e "${YELLOW}⚠ Skipping authentication (no token provided)${NC}"
            echo -e "${YELLOW}You can authenticate later with: ngrok config add-authtoken <YOUR_TOKEN>${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to install ngrok${NC}"
    fi

    echo ""
fi

# ============================================
# COMPLETION
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✓ Configuration Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}All selected settings have been applied successfully.${NC}"
echo -e "${YELLOW}Restarting terminal to apply changes...${NC}"
echo ""

# Reset the terminal by replacing current shell with a fresh bash instance
exec bash
