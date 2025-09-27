#!/bin/bash

INPUT_FILE="example.json"
SERVICE_URL="https://your-service-url/service/generate"

# Validate JSON
if ! jq empty "$INPUT_FILE" 2>/dev/null; then
  echo "Invalid JSON in $INPUT_FILE" >&2
  exit 1
fi

# Filter objects with "private": false
FILTERED_JSON=$(jq '[.[] | select(.private == false)]' "$INPUT_FILE")
if [ -z "$FILTERED_JSON" ]; then
  echo "No objects with private == false found." >&2
  exit 1
fi

# POST to service
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$FILTERED_JSON" "$SERVICE_URL")
if [ $? -ne 0 ]; then
  echo "Failed to POST to $SERVICE_URL" >&2
  exit 1
fi

# Print keys with child attribute "valid": true
echo "$RESPONSE" | jq -r 'to_entries[] | select(.value.valid == true) | .key'
