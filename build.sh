#!/bin/bash
set -e
echo "Installing Flutter..."
# Clone the stable Flutter channel (skip if already present for cache)
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

echo "Running Flutter build..."
cd app
flutter precache --web
flutter clean
flutter pub get
flutter build web --web-renderer canvaskit --release
echo "Build complete. Output in app/build/web"