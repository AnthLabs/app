#!/usr/bin/env bash
set -euo pipefail

ASSET="${1:-}"
TTL_SECONDS="${2:-3600}"

if [[ -z "$ASSET" ]]; then
  echo "usage: $0 <asset> [ttl_seconds]" >&2
  exit 2
fi

if [[ ! "$ASSET" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "invalid asset name: use only letters, numbers, _ or -" >&2
  exit 2
fi

if ! [[ "$TTL_SECONDS" =~ ^[0-9]+$ ]]; then
  echo "invalid ttl: ttl_seconds must be a positive integer" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/../docker/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/../docker/.env"
  set +a
fi

python3 "$SCRIPT_DIR/../docker/key-server/token.py" "$ASSET" "$TTL_SECONDS"