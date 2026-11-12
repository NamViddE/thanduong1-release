#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 1.0.25 - Android ARM64. Keeps the existing config and menu.
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.25'
CHECKSUM='SHA256SUMS_v1.0.25'
EXPECTED_BINARY_SHA='59cf3ec7d863ea653de4dfc075aa129a41436b77c5e8e7db66719750fd78b525'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"
SOURCE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: hay chay trong Termux.' >&2; exit 1
fi
case "$(uname -m)" in aarch64|arm64) ;; *) echo 'Loi: chi ho tro Android ARM64.' >&2; exit 1;; esac
for cmd in curl sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Thieu $cmd. Cai bang pkg install curl coreutils" >&2; exit 1; }
done
fetch() {
  file="$1"
  if [ -f "$SOURCE_DIR/$file" ]; then
    cp "$SOURCE_DIR/$file" "$file"
    return 0
  fi
  for base in "$RAW" "$CDN"; do
    echo "Dang tai: $file"
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$file" "$base/$file"; then return 0; fi
  done
  echo 'Chua tai duoc. Can upload du 3 file V1.0.25 len GitHub Code/main, hoac dat chung mot thu muc.' >&2
  return 1
}
work="$(mktemp -d)"
staged="$PREFIX/bin/.thanduong1-new-$$"
cleanup() { rm -rf "$work"; rm -f "$staged"; }
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
cd "$work"
fetch "$ASSET"
printf '%s  %s\n' "$EXPECTED_BINARY_SHA" "$ASSET" | sha256sum -c -
fetch "$CHECKSUM"
if [ "$(cat "$CHECKSUM")" != "$EXPECTED_BINARY_SHA  $ASSET" ]; then
  echo 'Checksum khong dung bo V1.0.25. Khong thay the ban cu.' >&2; exit 1
fi
chmod 700 "$ASSET"
cp "$ASSET" "$staged"
chmod 700 "$staged"
if [ "$("$staged" -version)" != 'THANDUONG1 V1.0.25' ]; then
  echo 'Binary khong chay dung phien ban. Khong thay the ban cu.' >&2; exit 1
fi
mv -f "$staged" "$PREFIX/bin/thanduong1"
echo 'Da cai THANDUONG1 V1.0.25: Disconnect qua UI + OCR + LOGCAT. Giu cau hinh cu.'
cd "$HOME"
cleanup
trap - EXIT HUP INT TERM
exec "$PREFIX/bin/thanduong1"
