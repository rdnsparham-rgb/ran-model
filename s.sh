#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# دریافت ID_MODEL از کاربر
read -p "لطفاً ID_MODEL رو وارد کن: " ID_MODEL

# دریافت پیام کاربر
read -p "پیام خودت رو وارد کن: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# دریافت توکن
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "خطا در دریافت توکن!"
    exit 1
fi

# ارسال درخواست به ورکر
RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "خطا در دریافت small_wave_url!"
    exit 1
fi

# ارسال پیام و دریافت جواب
FULL_URL="${SMALL_WAVE_URL}$(python3 -c "import requests, urllib.parse; print(urllib.parse.quote('$PROMPT'))")"
ANSWER=$(curl -s "$FULL_URL")

echo "جواب:"
echo "$ANSWER"
