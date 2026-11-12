#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 1.0.24 ARM64 installer - requires three files uploaded to GitHub main.
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.24'
CHECKSUM='SHA256SUMS_v1.0.24'
EXPECTED_BINARY_SHA='7b20274161857664068f90cb4aa5e95093f2e56e4da8af0362c29b719ca80eb1'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"
if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: hay chay trong Termux.' >&2; exit 1
fi
case "$(uname -m)" in aarch64|arm64) ;; *) echo 'Loi: chi ho tro Android ARM64.' >&2; exit 1;; esac
for cmd in curl sha256sum; do command -v "$cmd" >/dev/null 2>&1 || { echo "Thieu $cmd. Cai bang pkg install curl coreutils" >&2; exit 1; }; done
fetch() {
  file="$1"
  for base in "$RAW" "$CDN"; do
    echo "Dang tai: $file"
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$file" "$base/$file"; then return 0; fi
  done
  echo "Khong tai duoc $file tu GitHub Code/main." >&2; return 1
}
work="$(mktemp -d)"
staged="$PREFIX/bin/.thanduong1-new-$$"
cleanup() { rm -rf "$work"; rm -f "$staged"; }
trap cleanup EXIT HUP INT TERM
cd "$work"
fetch "$ASSET"
printf '%s  %s\n' "$EXPECTED_BINARY_SHA" "$ASSET" | sha256sum -c -
fetch "$CHECKSUM"
sha256sum -c "$CHECKSUM"
chmod 700 "$ASSET"
cp "$ASSET" "$staged"
chmod 700 "$staged"
if ! "$staged" -check; then echo 'Tu kiem tra that bai; khong thay the ban cu.' >&2; exit 1; fi
mv -f "$staged" "$PREFIX/bin/thanduong1"
echo 'Da cai THANDUONG1 V1.0.24: menu [13] nhan USERNAME hoac USER ID.'
cd "$HOME"
cleanup
trap - EXIT HUP INT TERM
exec "$PREFIX/bin/thanduong1"
