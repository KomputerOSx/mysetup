#!/usr/bin/env bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Ubuntu/GNOME Configuration Script${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

ensure_whiptail() {
    if ! command -v whiptail &> /dev/null; then
        echo -e "${YELLOW}Installing whiptail for interactive menu...${NC}"
        sudo apt-get update && sudo apt-get install -y whiptail
    fi
}

configure_whiptail_theme() {
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
}

step_start() {
    echo -e "${YELLOW}$1...${NC}"
}

step_done() {
    echo -e "${GREEN}$1${NC}"
    echo ""
}

step_warn() {
    echo -e "${YELLOW}$1${NC}"
}

step_error() {
    echo -e "${RED}$1${NC}"
}
