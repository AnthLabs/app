import base64
import hashlib
import hmac
import json
import time


def _b64_encode(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def _b64_decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def create_token(asset: str, ttl_seconds: int, secret: str) -> str:
    payload = {
        "asset": asset,
        "exp": int(time.time()) + ttl_seconds,
    }

    payload_part = _b64_encode(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    signature = hmac.new(
        secret.encode("utf-8"),
        payload_part.encode("ascii"),
        hashlib.sha256,
    ).digest()

    return f"{payload_part}.{_b64_encode(signature)}"


def validate_token(token: str, expected_asset: str, secret: str) -> tuple[bool, str]:
    try:
        payload_part, signature_part = token.split(".", 1)
    except ValueError:
        return False, "malformed token"

    expected_signature = hmac.new(
        secret.encode("utf-8"),
        payload_part.encode("ascii"),
        hashlib.sha256,
    ).digest()

    try:
        actual_signature = _b64_decode(signature_part)
    except ValueError:
        return False, "invalid signature encoding"

    if not hmac.compare_digest(actual_signature, expected_signature):
        return False, "invalid signature"

    try:
        payload = json.loads(_b64_decode(payload_part))
    except (ValueError, json.JSONDecodeError):
        return False, "invalid payload"

    if payload.get("asset") != expected_asset:
        return False, "asset mismatch"

    try:
        exp = int(payload.get("exp", 0))
    except (TypeError, ValueError):
        return False, "invalid expiration"

    if exp < int(time.time()):
        return False, "expired token"

    return True, "ok"


if __name__ == "__main__":
    import os
    import sys

    if len(sys.argv) != 3:
        print("usage: token.py <asset> <ttl_seconds>", file=sys.stderr)
        raise SystemExit(2)

    secret = os.environ.get("KEY_TOKEN_SECRET", "hackathon-dev-secret-change-me")
    print(create_token(sys.argv[1], int(sys.argv[2]), secret))