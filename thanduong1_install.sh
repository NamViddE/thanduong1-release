#!/data/data/com.termux/files/usr/bin/sh
# THANDUONG1 installer: public repository (not GitHub Releases).
# Repository must contain install.sh, thanduong1-android-arm64, and SHA256SUMS on main.
set -eu

REPO='NamViddE/thanduong1-release'
BRANCH='main'
ASSET='thanduong1-android-arm64'
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CDN="https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}"

if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo 'Loi: Hay chay trong Termux.' >&2
  exit 1
fi

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Loi: Ban nay chi ho tro ARM64; may hien tai: $(uname -m)" >&2; exit 1 ;;
esac

if ! command -v curl >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1; then
  echo 'Loi: Can curl va coreutils. Chay: pkg install -y curl coreutils' >&2
  exit 1
fi

fetch() {
  name="$1"
  dest="$2"
  for base in "$RAW" "$CDN"; do
    echo "Dang tai ${name} tu ${base}..."
    if curl -fL --retry 2 --connect-timeout 15 --max-time 180 -o "$dest" "${base}/${name}"; then
      return 0
    fi
  done
  echo "Loi: Khong tai duoc ${name}. Kiem tra ket noi mang/duong dan." >&2
  return 1
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
cd "$tmpdir"

fetch "$ASSET" "$ASSET"
fetch 'SHA256SUMS' 'SHA256SUMS'

grep "  ${ASSET}\$" SHA256SUMS | sha256sum -c -
chmod 700 "$ASSET"
cp "$ASSET" "$PREFIX/bin/thanduong1"
chmod 700 "$PREFIX/bin/thanduong1"
echo 'THANDUONG1 da cai xong. Dang khoi dong...'
exec "$PREFIX/bin/thanduong1"
