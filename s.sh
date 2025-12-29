#!/data/data/com.termux/files/usr/bin/bash

echo "@configfars - telegram"

# گرفتن مدل و پیام
read -r -p "Please enter ID_MODEL: " ID_MODEL
read -r -p "Enter your message: " PROMPT

WORKER_URL="https://configfars-model.sitema.workers.dev"

# اجرای کل جریان با Python تا requests و encoding درست باشند
ANSWER=$(python3 - <<END
import requests
import urllib.parse
import arabic_reshaper

WORKER_URL = "$WORKER_URL"
ID_MODEL = "$ID_MODEL"
PROMPT = "$PROMPT"

try:
    # 1. گرفتن token
    token_response = requests.get(f"{WORKER_URL}/get-token")
    token_response.raise_for_status()
    token = token_response.json()['token']

    # 2. گرفتن small_wave_url
    data = {"id_model": ID_MODEL, "token": token}
    worker_response = requests.post(f"{WORKER_URL}/query", json=data)
    worker_response.raise_for_status()
    small_wave_url = worker_response.json().get("small_wave_url")
    if not small_wave_url:
        print("Error: small_wave_url not found")
        exit()

    # 3. ساخت full URL با پیام URL-encoded
    full_url = f"{small_wave_url}{urllib.parse.quote(PROMPT)}"

    # 4. GET روی full_url
    response = requests.get(full_url)
    response.raise_for_status()
    text = response.text

    # 5. فارسی‌سازی با arabic_reshaper و RTL
    if text:
        reshaped = arabic_reshaper.reshape(text)
        print(reshaped[::-1])
except Exception as e:
    print("Error:", e)
END
)

echo "Answer:"
echo "$ANSWER"
