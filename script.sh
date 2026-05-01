#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

# ============================================
# Ubuntu/GNOME Configuration Script
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        -h|--help)
            echo "Usage: $0 [--dry-run]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/steps.sh"

for step_file in "$SCRIPT_DIR"/steps/*.sh; do
    source "$step_file"
done

clear
print_header

if [ "$DRY_RUN" = true ]; then
    step_warn "Dry-run mode enabled. No setup steps will be executed."
    echo ""
fi

ensure_whiptail "$DRY_RUN"
configure_whiptail_theme
collect_step_selections
print_selected_steps

echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}Dry run complete. No changes were made.${NC}"
    exit 0
fi

confirm_selected_steps

echo -e "${YELLOW}First, let's collect necessary information...${NC}"
echo ""

echo -e "${BLUE}Enter sudo password (will be cached for the session):${NC}"
sudo -v
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to authenticate. Exiting.${NC}"
    exit 1
fi

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
print_step_results
print_restart_notices
echo -e "${BLUE}Selected settings have finished running.${NC}"
echo ""
