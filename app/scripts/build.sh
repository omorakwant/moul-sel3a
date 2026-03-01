#!/usr/bin/env bash
set -e
# Single script: install Flutter (if needed) then build web. Run from app/.

FLUTTER_DIR="${FLUTTER_DIR:-./flutter}"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Installing Flutter..."
  if [ -d "$FLUTTER_DIR" ]; then
    (cd "$FLUTTER_DIR" && git pull --depth 1 || true)
  else
    git clone --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  "$FLUTTER_DIR/bin/flutter" config --enable-web
  "$FLUTTER_DIR/bin/flutter" precache --web
fi

echo "Building Flutter web..."
"$FLUTTER_DIR/bin/flutter" pub get
"$FLUTTER_DIR/bin/flutter" build web --release

echo "Build done: build/web"
