#!/usr/bin/env bash
set -e
# Install Flutter for Vercel (repo root). Used by root vercel.json when building app in app/.

FLUTTER_DIR="${FLUTTER_DIR:-./flutter}"

if [ -d "$FLUTTER_DIR" ]; then
  (cd "$FLUTTER_DIR" && git pull --depth 1 || true)
else
  git clone --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

"$FLUTTER_DIR/bin/flutter" config --enable-web
"$FLUTTER_DIR/bin/flutter" precache --web

export PATH="$PWD/$FLUTTER_DIR/bin:$PATH"
echo "Flutter installed at $FLUTTER_DIR"
