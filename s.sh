#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# گرفتن مدل و پیام کاربر
read -r -p "Please enter ID_MODEL: " ID_MODEL
read -r -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# اگر پیام فارسی است، فارسی‌سازی و RTL برای ارسال به مدل
PROMPT_FARSI=$(python3 - <<END
import arabic_reshaper
text = """$PROMPT"""
if text:
    print(arabic_reshaper.reshape(text)[::-1])
END
)

# دریافت توکن
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error getting token!"
    exit 1
fi

# دریافت small_wave_url
RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "Error getting small_wave_url!"
    exit 1
fi

# URL-encode کردن پیام فارسی قبل از ارسال
ENCODED_PROMPT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROMPT_FARSI'))")

# GET روی small_wave_url با پیام
ANSWER=$(curl -s "${SMALL_WAVE_URL}${ENCODED_PROMPT}")

# فارسی‌سازی جواب مدل
ANSWER_FARSI=$(python3 - <<END
import arabic_reshaper
text = """$ANSWER"""
if text:
    print(arabic_reshaper.reshape(text)[::-1])
END
)

echo "Answer:"
echo "$ANSWER_FARSI"
