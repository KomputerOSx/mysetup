#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

# ============================================
# Ubuntu/GNOME Configuration Script
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/steps.sh"

for step_file in "$SCRIPT_DIR"/steps/*.sh; do
    source "$step_file"
done

clear
print_header

echo -e "${YELLOW}First, let's collect necessary information...${NC}"
echo ""

echo -e "${BLUE}Enter sudo password (will be cached for the session):${NC}"
sudo -v
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to authenticate. Exiting.${NC}"
    exit 1
fi

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo ""
echo -e "${GREEN}Information collected${NC}"
echo ""

ensure_whiptail
configure_whiptail_theme
collect_step_selections

if step_selected "github"; then
    read -p "Enter your GitHub email (press Enter to skip): " GITHUB_EMAIL
fi

clear
echo -e "${BLUE}Starting selected configurations...${NC}"
echo ""

run_selected_steps

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}All selected settings have been applied successfully.${NC}"
echo -e "${YELLOW}Restarting terminal to apply changes...${NC}"
echo ""

exec bash
