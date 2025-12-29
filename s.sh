#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# تابع ساده برای برعکس کردن فارسی
reverse_farsi_light() {
    python3 -c "import sys; text=sys.stdin.read(); print(''.join(text[::-1]))"
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

# چاپ جواب به صورت برعکس
echo "Answer:"
echo "$ANSWER" | reverse_farsi_light
