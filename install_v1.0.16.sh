#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 V1.0.16 — Android ARM64 / Termux.
# Public installation files contain no account credentials.
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.16'
CHECKSUM='SHA256SUMS_v1.0.16'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"
if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: hay chay bang Termux.' >&2
  exit 1
fi
case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Loi: chi ho tro Android ARM64. May nay: $(uname -m)" >&2; exit 1 ;;
esac
for cmd in curl sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Thieu $cmd. Chay: pkg install -y curl coreutils tesseract" >&2; exit 1; }
done
fetch() {
  file="$1"
  for base in "$RAW" "$CDN"; do
    echo "Dang tai: $file"
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$file" "$base/$file"; then
      return 0
    fi
  done
  echo "Loi tai $file. Kiem tra file da upload len GitHub Code/main." >&2
  return 1
}
work="$(mktemp -d)"
staged="$PREFIX/bin/.thanduong1-new-$$"
cleanup() { rm -rf "$work"; rm -f "$staged"; }
trap cleanup EXIT HUP INT TERM
cd "$work"
fetch "$ASSET"
fetch "$CHECKSUM"
sha256sum -c "$CHECKSUM"
chmod 700 "$ASSET"
cp "$ASSET" "$staged"
chmod 700 "$staged"
echo 'Kiem tra THANDUONG1 V1.0.16 truoc khi thay ban cu...'
if ! "$staged" -check; then
  echo 'Kiem tra that bai: KHONG ghi de ban dang cai.' >&2
  exit 1
fi
mv -f "$staged" "$PREFIX/bin/thanduong1"
echo 'Da cap nhat V1.0.16. Luon mo MAIN MENU dau tien. Dung [2] quet prefix va [3] chon Roblox.'
cd "$HOME"
cleanup
trap - EXIT HUP INT TERM
exec "$PREFIX/bin/thanduong1"
