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
"$FLUTTER_BIN" build web --release --base-href /app/

echo "==> Building Next.js landing..."
cd "$REPO_ROOT/lcarnet-b2b-landing"
npm install
npm run build

echo "==> Assembling final output in 'public' directory..."
cd "$REPO_ROOT"
mkdir -p public
cp -r lcarnet-b2b-landing/out/* public/
mkdir -p public/app
cp -r app/build/web/* public/app/

echo "==> Build complete. Output in public/"
