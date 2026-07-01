#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-}"
ASSET="${2:-}"
TTL_SECONDS="${3:-3600}"

if [[ -z "$INPUT" || -z "$ASSET" ]]; then
  echo "usage: $0 <input-video> <asset> [token-ttl-seconds]" >&2
  exit 2
fi

if [[ ! -f "$INPUT" ]]; then
  echo "input video not found: $INPUT" >&2
  exit 1
fi

if [[ ! "$ASSET" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "invalid asset name: use only letters, numbers, _ or -" >&2
  exit 2
fi

if ! [[ "$TTL_SECONDS" =~ ^[0-9]+$ ]]; then
  echo "invalid ttl: ttl_seconds must be a positive integer" >&2
  exit 2
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to package encrypted HLS" >&2
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to generate HLS keys and IV" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -f "$ROOT_DIR/infra/docker/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/infra/docker/.env"
  set +a
fi

KEY_DIR="$ROOT_DIR/media/keys"
HLS_DIR="$ROOT_DIR/media/hls/$ASSET"
KEY_FILE="$KEY_DIR/$ASSET.key"
KEY_INFO="$(mktemp)"
KEY_SERVER_PORT="${KEY_SERVER_PORT:-8090}"
HLS_CDN_PORT="${HLS_CDN_PORT:-8080}"

cleanup() {
  rm -f "$KEY_INFO"
}
trap cleanup EXIT

mkdir -p "$KEY_DIR" "$HLS_DIR"

if [[ ! -f "$KEY_FILE" ]]; then
  openssl rand 16 > "$KEY_FILE"
fi

TOKEN="$("$ROOT_DIR/infra/scripts/create-key-token.sh" "$ASSET" "$TTL_SECONDS")"
IV="$(openssl rand -hex 16)"

cat > "$KEY_INFO" <<EOF
http://localhost:$KEY_SERVER_PORT/keys/$ASSET.key?token=$TOKEN
$KEY_FILE
$IV
EOF

ffmpeg -y -i "$INPUT" \
  -c:v libx264 -preset veryfast -crf 23 \
  -c:a aac -b:a 128k \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_key_info_file "$KEY_INFO" \
  -hls_segment_filename "$HLS_DIR/segment_%03d.ts" \
  "$HLS_DIR/master.m3u8"

echo "HLS playlist: http://localhost:$HLS_CDN_PORT/media/hls/$ASSET/master.m3u8"
echo "Key endpoint validates token before returning: http://localhost:$KEY_SERVER_PORT/keys/$ASSET.key?token=<token>"