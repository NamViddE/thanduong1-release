THANDUONG1 ROOT V1.0.11 — ANDROID ARM64

Changes:
- When selecting [1] Start Auto Rejoin, the program now tries to OPEN each ON package once, one after another, even if Android keeps its background process running.
- Keeps the multi-select packages, QT/VNG labels, Place ID, logging, OCR, retry limits and pidfd workaround from earlier versions.
- Launching an app does NOT guarantee joining a Roblox game. OCR works only for the foreground app.

Files for public repository branch main:
- install_v1.0.11.sh
- thanduong1-android-arm64-v1.0.11
- SHA256SUMS_v1.0.11

Termux install (after uploading all 3 files):
pkg install -y curl coreutils tesseract
curl -fL https://raw.githubusercontent.com/NamViddE/thanduong1-release/main/install_v1.0.11.sh -o install_v1.0.11.sh
sh install_v1.0.11.sh

Requires ARM64 and a supported su root shell.
Not yet tested on Redfinger.
