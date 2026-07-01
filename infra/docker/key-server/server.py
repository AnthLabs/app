import os
import re
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from token import validate_token


HOST = "0.0.0.0"
PORT = int(os.environ.get("KEY_SERVER_PORT", "8090"))
KEY_ROOT = Path(os.environ.get("KEY_ROOT", "/run/hls-keys")).resolve()
SECRET = os.environ.get("KEY_TOKEN_SECRET", "hackathon-dev-secret-change-me")
CORS_ORIGIN = os.environ.get("CORS_ORIGIN", "http://localhost:5173")

ASSET_PATTERN = re.compile(r"^[a-zA-Z0-9_-]+$")


class KeyHandler(BaseHTTPRequestHandler):
    server_version = "VSecureKeyServer/0.1"

    def do_OPTIONS(self):
        self._send_cors(HTTPStatus.NO_CONTENT)

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/health":
            self._send_json(HTTPStatus.OK, '{"status":"ok","service":"key-server"}')
            return

        if not parsed.path.startswith("/keys/") or not parsed.path.endswith(".key"):
            self._send_text(HTTPStatus.NOT_FOUND, "not found")
            return

        asset = Path(parsed.path).name.removesuffix(".key")

        if not ASSET_PATTERN.fullmatch(asset):
            self._send_text(HTTPStatus.BAD_REQUEST, "invalid asset")
            return

        token = parse_qs(parsed.query).get("token", [""])[0]
        ok, reason = validate_token(token, asset, SECRET)

        if not ok:
            self._send_text(HTTPStatus.FORBIDDEN, reason)
            return

        key_path = (KEY_ROOT / f"{asset}.key").resolve()
        if KEY_ROOT not in key_path.parents or not key_path.is_file():
            self._send_text(HTTPStatus.NOT_FOUND, "key not found")
            return

        key = key_path.read_bytes()

        self.send_response(HTTPStatus.OK)
        self.send_header("Access-Control-Allow-Origin", CORS_ORIGIN)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(len(key)))
        self.end_headers()
        self.wfile.write(key)

    def _send_json(self, status, body):
        raw = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Access-Control-Allow-Origin", CORS_ORIGIN)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def _send_cors(self, status):
        self.send_response(status)
        self.send_header("Access-Control-Allow-Origin", CORS_ORIGIN)
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()

    def _send_text(self, status, body):
        raw = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Access-Control-Allow-Origin", CORS_ORIGIN)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)


if __name__ == "__main__":
    KEY_ROOT.mkdir(parents=True, exist_ok=True)
    print(f"key server listening on {HOST}:{PORT}, key root={KEY_ROOT}")
    ThreadingHTTPServer((HOST, PORT), KeyHandler).serve_forever()