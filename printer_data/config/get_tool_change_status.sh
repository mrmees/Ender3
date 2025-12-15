#!/bin/bash
# Reads the current tool change progress from JSON and updates color_tracker.cfg

set -eu  # Exit on error, undefined variables

JSON_FILE="/tmp/tool_change_data.json"
COLOR_FILE="/home/matt/printer_data/config/color_tracker.cfg"

# Check if JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "ERROR: No tool change data found at $JSON_FILE" >&2
    exit 1
fi

# Validate JSON file is readable
if ! jq empty "$JSON_FILE" 2>/dev/null; then
    echo "ERROR: Invalid JSON in $JSON_FILE" >&2
    exit 1
fi


current_change=$(jq -r '.current_change // 0' "$JSON_FILE")
total_changes=$(jq -r '.total_changes // 0' "$JSON_FILE")
remaining_changes=$((total_changes - current_change))

# Check if completed
if [ "$current_change" -ge "$total_changes" ]; then
    echo "✓ Tool changes completed ($total_changes/$total_changes)"
    # Update all variables for completion state
    sed -i 's/^variable_next_color: .*$/variable_next_color: "COMPLETE"/' "$COLOR_FILE"
    sed -i "s/^variable_total_changes: .*$/variable_total_changes: $total_changes/" "$COLOR_FILE"
    sed -i "s/^variable_current_change: .*$/variable_current_change: $current_change/" "$COLOR_FILE"
    sed -i "s/^variable_remaining_changes: .*$/variable_remaining_changes: 0/" "$COLOR_FILE"
    exit 0
fi

# Extract current change details with validation
tool_number=$(jq -r ".changes[$current_change].tool_number // \"Unknown\"" "$JSON_FILE")
color=$(jq -r ".changes[$current_change].color // \"Unknown\"" "$JSON_FILE")
line=$(jq -r ".changes[$current_change].line // \"Unknown\"" "$JSON_FILE")

# Validate we got real data
if [ "$color" = "Unknown" ] || [ "$color" = "null" ]; then
    echo "ERROR: Could not read color data for change $current_change" >&2
    exit 1
fi

# Update all variables in the config file
sed -i "s/^variable_next_color: .*$/variable_next_color: \"$color\"/" "$COLOR_FILE"
sed -i "s/^variable_total_changes: .*$/variable_total_changes: $total_changes/" "$COLOR_FILE"
sed -i "s/^variable_current_change: .*$/variable_current_change: $current_change/" "$COLOR_FILE"
sed -i "s/^variable_remaining_changes: .*$/variable_remaining_changes: $remaining_changes/" "$COLOR_FILE"


# Display progress with better formatting
echo "═══════════════════════════════════════════"
echo "Tool Change: $((current_change + 1))/$total_changes"
echo "Color: $color"
echo "Tool: T$tool_number"
echo "G-code Line: $line"
echo "Remaining: $remaining_changes"
echo "═══════════════════════════════════════════"