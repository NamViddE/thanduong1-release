#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 V1.0.1 – experimental Android ARM64 release installer
set -eu
REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64-v1.0.1'
CHECKSUM='SHA256SUMS_v1.0.1'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"

if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: can chay trong Termux.' >&2
  exit 1
fi
case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Loi: ban nay chi ho tro Android ARM64; may: $(uname -m)" >&2; exit 1 ;;
esac
for prog in curl sha256sum; do
  if ! command -v "$prog" >/dev/null 2>&1; then
    echo "Loi: thieu $prog. Chay: pkg install -y curl coreutils tesseract" >&2
    exit 1
  fi
done

fetch() {
  name="$1"; dest="$2"
  for base in "$RAW" "$CDN"; do
    echo "Dang tai $name ..."
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$dest" "${base}/${name}"; then
      return 0
    fi
  done
  echo "Khong tai duoc: $name" >&2
  return 1
}
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
cd "$tmpdir"
fetch "$ASSET" "$ASSET"
fetch "$CHECKSUM" "$CHECKSUM"
sha256sum -c "$CHECKSUM"
chmod 700 "$ASSET"
cp "$ASSET" "$PREFIX/bin/thanduong1"
chmod 700 "$PREFIX/bin/thanduong1"
echo 'THANDUONG1 V1.0.1: dang kiem tra root va OCR...'
"$PREFIX/bin/thanduong1" -check
echo 'Kiem tra thanh cong. Bat dau giam sat Roblox... (Ctrl+C de dung)'
exec "$PREFIX/bin/thanduong1"
