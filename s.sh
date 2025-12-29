#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# گرفتن مدل
read -r -p "Please enter ID_MODEL: " ID_MODEL

# گرفتن پیام کاربر
read -r -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# دریافت توکن
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error: failed to get token!"
    exit 1
fi

# ارسال POST ساده برای گرفتن small_wave_url
RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "Error: failed to get small_wave_url!"
    exit 1
fi

# urlencode کردن پیام فارسی
ENCODED_PROMPT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROMPT'))")

# GET روی small_wave_url با پیام
ANSWER=$(curl -s "${SMALL_WAVE_URL}${ENCODED_PROMPT}")

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
