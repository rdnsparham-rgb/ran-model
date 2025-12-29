#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - Telegram Chat (Type 'exit' to quit)"

# گرفتن مدل
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

while true; do
    # گرفتن پیام کاربر
    read -r -p "You: " USER_MSG
    if [ "$USER_MSG" = "exit" ]; then
        echo "Exiting chat."
        break
    fi

    # URL encode پیام کاربر (فارسی و انگلیسی بدون تغییر)
    ENCODED_MSG=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$USER_MSG'''))")

    # GET روی small_wave_url با پیام
    ANSWER=$(curl -s "${SMALL_WAVE_URL}${ENCODED_MSG}")

    # چاپ جواب مدل بدون تغییر
    echo "Bot: $ANSWER"
done
