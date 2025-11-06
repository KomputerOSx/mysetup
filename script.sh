#!/bin/bash

# ============================================
# Ubuntu/GNOME Configuration Script
# ============================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting system configuration...${NC}"
echo ""

# ============================================
# 1. KEYBOARD SETTINGS
# ============================================
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

# ============================================
# 2. WORKSPACE KEYBINDINGS
# ============================================
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

# ============================================
# 3. APPLICATION LAUNCHER KEYBINDINGS
# ============================================
echo -e "${YELLOW}Configuring application launcher keybindings...${NC}"

# Setup custom keybindings array
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"

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

# Super + F = Fullscreen
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"

echo -e "${GREEN}✓ Application launcher keybindings configured${NC}"
echo ""

# ============================================
# 4. STARSHIP PROMPT INSTALLATION
# ============================================
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

# ============================================
# 5. GITHUB SSH AUTHENTICATION
# ============================================
echo -e "${YELLOW}Setting up GitHub SSH authentication...${NC}"

# Update and install GitHub CLI
sudo apt update && sudo apt install gh -y

# Prompt for email
read -p "Enter your GitHub email: " github_email

# Authenticate with GitHub
gh auth login --git-protocol ssh --web

# Generate new SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$github_email" -f ~/.ssh/id_ed25519 -N ""
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

# ============================================
# 6. CLAUDE CODE INSTALLATION
# ============================================
echo -e "${YELLOW}Installing Claude Code...${NC}"

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

echo -e "${GREEN}✓ Claude Code installed${NC}"
echo ""

# ============================================
# 7. WALLPAPER SETUP
# ============================================
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
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name "Cycle Wallpaper"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command "$HOME/.local/bin/cycle-wallpaper.sh"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding "<Super><Alt>space"

echo -e "${GREEN}✓ Catppuccin wallpapers configured with hourly cycling and Super+Alt+Space hotkey${NC}"
echo ""

# ============================================
# COMPLETION
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✓ Configuration Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}Please restart your terminal or run:${NC}"
echo -e "${YELLOW}  source ~/.bashrc${NC}"
echo ""
echo -e "${GREEN}All settings have been applied successfully.${NC}"
