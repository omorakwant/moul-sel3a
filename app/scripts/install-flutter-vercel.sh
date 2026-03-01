#!/usr/bin/env bash
set -e
# Install Flutter when Vercel Root Directory = app. Clones into app/flutter.

FLUTTER_DIR="${FLUTTER_DIR:-./flutter}"

if [ -d "$FLUTTER_DIR" ]; then
  (cd "$FLUTTER_DIR" && git pull --depth 1 || true)
else
  git clone --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

"$FLUTTER_DIR/bin/flutter" config --enable-web
"$FLUTTER_DIR/bin/flutter" precache --web
echo "Flutter installed at $FLUTTER_DIR"
