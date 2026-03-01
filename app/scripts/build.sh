#!/usr/bin/env bash
set -e
# Single script: install Flutter (if needed) then build web. Run from app/.
# Clone a release tag so Flutter reports a real version (avoids 0.0.0-unknown for pub solve).

FLUTTER_DIR="${FLUTTER_DIR:-./flutter}"
# Pin to a stable tag so version is set (shallow clone of branch can yield 0.0.0-unknown)
FLUTTER_TAG="${FLUTTER_TAG:-3.29.0}"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_TAG..."
  rm -rf "$FLUTTER_DIR"
  git clone --depth 1 --branch "$FLUTTER_TAG" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  "$FLUTTER_DIR/bin/flutter" config --enable-web
  "$FLUTTER_DIR/bin/flutter" precache --web
fi

echo "Building Flutter web..."
"$FLUTTER_DIR/bin/flutter" pub get
"$FLUTTER_DIR/bin/flutter" build web --release

echo "Build done: build/web"
