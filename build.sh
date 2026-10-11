#!/bin/bash
set -e

# Run from repo root (where vercel runs the build)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "==> Repo root: $REPO_ROOT"

# Flutter SDK
if [ ! -d "flutter" ]; then
  echo "==> Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "==> Using cached Flutter"
fi

FLUTTER_BIN="$REPO_ROOT/flutter/bin/flutter"
export PATH="$REPO_ROOT/flutter/bin:$PATH"

echo "==> Flutter: $FLUTTER_BIN"
"$FLUTTER_BIN" --version

echo "==> Enabling web..."
"$FLUTTER_BIN" config --enable-web

echo "==> Building (app/)..."
cd "$REPO_ROOT/app"
"$FLUTTER_BIN" clean
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build web --release --base-href /prototype/

echo "==> Build complete. Output in app/build/web"
ls -la build/web/

echo "==> Syncing Flutter build to landing public/prototype directory..."
mkdir -p "$REPO_ROOT/lcarnet-b2b-landing/public/prototype"
cp -r build/web/* "$REPO_ROOT/lcarnet-b2b-landing/public/prototype/"

echo "==> Unified assets synced successfully!"
