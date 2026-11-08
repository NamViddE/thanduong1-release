#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 V1.0.10 for Android ARM64 / Termux.
# Downloads a fixed version from the user's public repository and validates SHA256.
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.10'
CHECKSUM='SHA256SUMS_v1.0.10'
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
staged="$PREFIX/bin/.thanduong1-new-$$"
cleanup() {
  rm -rf "$work"
  rm -f "$staged"
}
trap cleanup EXIT HUP INT TERM
cd "$work"
fetch "$ASSET"
fetch "$CHECKSUM"
sha256sum -c "$CHECKSUM"
chmod 700 "$ASSET"
cp "$ASSET" "$staged"
chmod 700 "$staged"
echo 'THANDUONG1 V1.0.10: kiem tra truoc khi thay the ban dang cai ...'
# Important: run preflight BEFORE replacing the existing binary. If Root/exec
# fails (including a SIGSYS crash), preserve the previous version.
if ! "$staged" -check; then
  echo 'Kiem tra that bai. Ban THANDUONG1 dang cai da duoc giu nguyen.' >&2
  exit 1
fi
mv -f "$staged" "$PREFIX/bin/thanduong1"
echo 'Da cap nhat THANDUONG1 V1.0.10. Tool se mo giao dien menu.'
echo 'Chon [2] quan ly package, [3] ON/OFF, [4] QT/VNG cho tung tab, [1] bat dau.'
cd "$HOME"
cleanup
trap - EXIT HUP INT TERM
exec "$PREFIX/bin/thanduong1"
