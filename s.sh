#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - Telegram Chat (Type 'exit' to quit)"

read -r -p "Please enter ID_MODEL: " ID_MODEL

WORKER_URL="https://configfars-model.sitema.workers.dev"

# دریافت توکن یکبار
TOKEN=$(curl -s "$WORKER_URL/get-token" | grep -oP '(?<="token":")[^"]+')
if [ -z "$TOKEN" ]; then
    echo "Error getting token!"
    exit 1
fi

# دریافت small_wave_url یکبار
RESPONSE=$(curl -s -X POST "$WORKER_URL/query" \
    -H "Content-Type: application/json" \
    -d "{\"id_model\":\"$ID_MODEL\",\"token\":\"$TOKEN\"}")

SMALL_WAVE_URL=$(echo "$RESPONSE" | grep -oP '(?<="small_wave_url":")[^"]+')
if [ -z "$SMALL_WAVE_URL" ]; then
    echo "Error getting small_wave_url!"
    exit 1
fi

# حافظه موقت برای پیام‌ها
CONTEXT=""

while true; do
    read -r -p "You: " USER_MSG
    if [ "$USER_MSG" = "exit" ]; then
        echo "Exiting chat."
        break
    fi

    # افزودن پیام کاربر به Context
    CONTEXT="$CONTEXT\n$USER_MSG"

    # فقط URL encode پیام برای ارسال به مدل (بدون RTL و reshape)
    ENCODED_MSG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$USER_MSG'''))")

    # GET روی small_wave_url با پیام
    ANSWER=$(curl -s "${SMALL_WAVE_URL}${ENCODED_MSG}")

    # فارسی‌سازی جواب مدل
    ANSWER_FARSI=$(python3 - <<END
import arabic_reshaper
text = """$ANSWER"""
if text:
    print(arabic_reshaper.reshape(text)[::-1])
END
)

    echo "Bot: $ANSWER_FARSI"

    # افزودن جواب مدل به Context
    CONTEXT="$CONTEXT\n$ANSWER_FARSI"
done
