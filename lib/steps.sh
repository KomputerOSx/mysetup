#!/usr/bin/env bash

STEP_IDS=()
STEP_LABELS=()
STEP_FUNCTIONS=()
SELECTED_STEP_IDS=()

register_step() {
    STEP_IDS+=("$1")
    STEP_LABELS+=("$2")
    STEP_FUNCTIONS+=("$3")
}

step_selected() {
    local id="$1"
    local selected_id

    for selected_id in "${SELECTED_STEP_IDS[@]}"; do
        if [ "$selected_id" = "$id" ]; then
            return 0
        fi
    done

    return 1
}

collect_step_selections() {
    local preset
    local default_state
    local selections
    local option_count
    local checklist_height
    local checklist_args=()
    local index
    local selection

    option_count=${#STEP_IDS[@]}
    checklist_height=$((option_count + 12))

    preset=$(whiptail --notags --title "Quick Selection" --menu \
        "Choose a preset or customize your selection:" 15 78 3 \
        "all" "Select All (run everything)" \
        "none" "Deselect All (choose manually)" \
        "custom" "Custom (default: all selected)" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        step_warn "Configuration cancelled."
        exit 0
    fi

    if [ "$preset" = "all" ]; then
        SELECTED_STEP_IDS=("${STEP_IDS[@]}")
        return
    fi

    case "$preset" in
        none) default_state="OFF" ;;
        custom) default_state="ON" ;;
    esac

    for ((index = 0; index < option_count; index++)); do
        checklist_args+=("${STEP_IDS[$index]}" "${STEP_LABELS[$index]}" "$default_state")
    done

    selections=$(whiptail --notags --title "Configuration Options" --checklist \
        "Use up/down arrows to navigate, SPACE to select/deselect, TAB to switch to buttons:" \
        "$checklist_height" 78 "$option_count" \
        "${checklist_args[@]}" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        step_warn "Configuration cancelled."
        exit 0
    fi

    SELECTED_STEP_IDS=()
    for selection in $selections; do
        selection=$(echo "$selection" | tr -d '"')
        SELECTED_STEP_IDS+=("$selection")
    done
}

run_selected_steps() {
    local index

    for ((index = 0; index < ${#STEP_IDS[@]}; index++)); do
        if step_selected "${STEP_IDS[$index]}"; then
            "${STEP_FUNCTIONS[$index]}"
        fi
    done
}
