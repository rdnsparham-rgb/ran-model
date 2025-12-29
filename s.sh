#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

read -p "Please enter ID_MODEL: " ID_MODEL
read -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# دریافت توکن
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error: failed to get token!"
    exit 1
fi

# ارسال درخواست به ورکر
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

# تابع فارسی‌ساز با arabic_reshaper
farsi_reshape() {
python3 - <<END
import sys
import arabic_reshaper

text = sys.stdin.read().strip()
reshaped = arabic_reshaper.reshape(text)
rtl_text = reshaped[::-1]
print(rtl_text)
END
}

echo "Answer:"
echo "$ANSWER" | farsi_reshape
