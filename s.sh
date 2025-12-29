#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

read -r -p "Please enter ID_MODEL: " ID_MODEL
read -r -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# دریافت توکن
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error: failed to get token!"
    exit 1
fi

# ارسال پیام به worker به صورت POST JSON
ANSWER=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\",\"prompt\":\"$PROMPT\"}" | \
    grep -oP '(?<="response_text":")[^"]*')

# فارسی‌سازی با arabic_reshaper
farsi_reshape() {
python3 - <<END
import sys
import arabic_reshaper

text = sys.stdin.read().strip()
if text:
    reshaped = arabic_reshaper.reshape(text)
    print(reshaped[::-1])
END
}

echo "Answer:"
echo "$ANSWER" | farsi_reshape
