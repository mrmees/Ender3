#!/bin/bash
# Reads the current tool change progress from JSON and prints it.

JSON_FILE="/tmp/tool_change_data.json"
COLOR_FILE="/tmp/current_tool_color.txt"
GCODE_OUTPUT="/tmp/klipper_set_color.gcode"
MOONRAKER_URL="http://localhost:7125"

if [ ! -f "$JSON_FILE" ]; then
    echo "ERROR: No tool change data found."
    exit 1
fi

current_change=$(jq -r '.current_change // 0' "$JSON_FILE")
total_changes=$(jq -r '.total_changes // 0' "$JSON_FILE")

if [ "$current_change" -ge "$total_changes" ]; then
    echo "Tool changes completed."
    echo "COMPLETE" > "$COLOR_FILE"
    exit 0
fi

# Extract the tool number and color for the current change
tool_number=$(jq -r ".changes[$current_change].tool_number // \"Unknown\"" "$JSON_FILE")
color=$(jq -r ".changes[$current_change].color // \"Unknown\"" "$JSON_FILE")
line=$(jq -r ".changes[$current_change].line // \"Unknown\"" "$JSON_FILE")

# Save color to file for Klipper to read
echo "$color" > "$COLOR_FILE"

# Display info
echo "Tool Change $((current_change + 1)) of $total_changes - $color (T$tool_number) at line $line"

if [ -f "$COLOR_FILE" ]; then
    color=$(cat "$COLOR_FILE" | tr -d '\n\r')
    echo "SET_GCODE_VARIABLE MACRO=TOOL_STATE VARIABLE=current_color VALUE='\"$color\"'" > "$GCODE_OUTPUT"
else
    echo "SET_GCODE_VARIABLE MACRO=TOOL_STATE VARIABLE=current_color VALUE='\"Test\"'" > "$GCODE_OUTPUT"
fi

curl -X POST "${MOONRAKER_URL}/printer/gcode/script" \
    -H "Content-Type: application/json" \
    -d "{\"script\": \"SET_GCODE_VARIABLE MACRO=SHOW_TOOL_CHANGE_COLOR VARIABLE=current_color VALUE='\\\"${color}\\\"'\"}"
