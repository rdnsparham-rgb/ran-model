#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

fix_farsi() {
    python3 - << 'EOF'
import sys
import arabic_reshaper
from bidi.algorithm import get_display

text = sys.stdin.read()
reshaped = arabic_reshaper.reshape(text)
bidi_text = get_display(reshaped)
print(bidi_text)
EOF
}

read -p "Please enter ID_MODEL: " ID_MODEL
read -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error: failed to get token!"
    exit 1
fi

RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "Error: failed to get small_wave_url!"
    exit 1
fi

FULL_URL="${SMALL_WAVE_URL}$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROMPT'))")"
ANSWER=$(curl -s "$FULL_URL")

echo "Answer:"
echo "$ANSWER" | fix_farsi
