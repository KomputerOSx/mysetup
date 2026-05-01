#!/usr/bin/env bash

LOGOUT_NOTICES=()
RESTART_NOTICES=()

command_exists() {
    command -v "$1" &> /dev/null
}

backup_path() {
    local path="$1"
    local timestamp
    local backup

    if [ ! -e "$path" ]; then
        return
    fi

    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup="${path}.bak.${timestamp}"
    cp -a "$path" "$backup"
    step_warn "Backed up $path to $backup"
}

add_logout_notice() {
    LOGOUT_NOTICES+=("$1")
}

add_restart_notice() {
    RESTART_NOTICES+=("$1")
}

print_restart_notices() {
    local notice

    if [ "${#LOGOUT_NOTICES[@]}" -gt 0 ]; then
        echo -e "${YELLOW}Logout required:${NC}"
        for notice in "${LOGOUT_NOTICES[@]}"; do
            echo "  - $notice"
        done
        echo ""
    fi

    if [ "${#RESTART_NOTICES[@]}" -gt 0 ]; then
        echo -e "${YELLOW}Restart recommended:${NC}"
        for notice in "${RESTART_NOTICES[@]}"; do
            echo "  - $notice"
        done
        echo ""
    fi
}
