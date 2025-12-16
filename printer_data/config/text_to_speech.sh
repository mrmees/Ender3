#!/bin/bash
MESSAGE="$*"

# Update the input_text entity
curl -X POST \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5Y2UxYTQzYWVjZGE0ODg3YjBiZDFiNjIwZGM0MjNmNiIsImlhdCI6MTc2NTg5ODA1NywiZXhwIjoyMDgxMjU4MDU3fQ.-YU7DjZyp3-Cdo4bZytk02fAEJ8QgfOC-ktrtOl8aYw" \
  -H "Content-Type: application/json" \
  -d "{\"entity_id\": \"input_text.printer_speech_text\", \"value\": \"$MESSAGE\"}" \
  http://192.168.1.254:8123/api/services/input_text/set_value

# Trigger the automation
curl -X POST \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5Y2UxYTQzYWVjZGE0ODg3YjBiZDFiNjIwZGM0MjNmNiIsImlhdCI6MTc2NTg5ODA1NywiZXhwIjoyMDgxMjU4MDU3fQ.-YU7DjZyp3-Cdo4bZytk02fAEJ8QgfOC-ktrtOl8aYw" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "automation.printer_speech"}' \
  http://192.168.1.254:8123/api/services/automation/trigger