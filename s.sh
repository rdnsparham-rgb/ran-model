#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# Get ID_MODEL from the user
read -p "Please enter ID_MODEL: " ID_MODEL

# Get user's message
read -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# Get token
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error getting token!"
    exit 1
fi

# Send request to worker
RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "Error getting small_wave_url!"
    exit 1
fi

# Send message and get answer
FULL_URL="${SMALL_WAVE_URL}$(python3 -c "import requests, urllib.parse; print(urllib.parse.quote('$PROMPT'))")"
ANSWER=$(curl -s "$FULL_URL")

echo "Answer:"
echo "$ANSWER"
