#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 V1.0.5 for Android ARM64 / Termux.
# Downloads a fixed version from the user's public repository and validates SHA256.
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.5'
CHECKSUM='SHA256SUMS_v1.0.5'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"
if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: hay chay trong Termux, khong chay trong Android shell.' >&2
  exit 1
fi
case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Loi: chi ho tro ARM64; thiet bi nay: $(uname -m)" >&2; exit 1 ;;
esac
for cmd in curl sha256sum; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Thieu $cmd. Hay chay: pkg install -y curl coreutils tesseract" >&2
    exit 1
  fi
done
fetch() {
  file="$1"
  for base in "$RAW" "$CDN"; do
    echo "Dang tai: ${file}"
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$file" "$base/$file"; then
      return 0
    fi
  done
  echo "Khong tai duoc $file. Kiem tra 3 file da upload vao GitHub Code/main chua." >&2
  return 1
}
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT HUP INT TERM
cd "$work"
fetch "$ASSET"
fetch "$CHECKSUM"
sha256sum -c "$CHECKSUM"
chmod 700 "$ASSET"
staged="$PREFIX/bin/.thanduong1-new-$$"
cp "$ASSET" "$staged"
chmod 700 "$staged"
mv -f "$staged" "$PREFIX/bin/thanduong1"
echo 'THANDUONG1 V1.0.5: kiem tra Root va moi truong ...'
"$PREFIX/bin/thanduong1" -check
echo 'Da cai dat. Tool se mo giao dien menu.'
echo 'Chon [2] de quan ly package, [3] de bat/tat Roblox, [1] bat dau.'
cd "$HOME"
rm -rf "$work"
trap - EXIT HUP INT TERM
exec "$PREFIX/bin/thanduong1"
