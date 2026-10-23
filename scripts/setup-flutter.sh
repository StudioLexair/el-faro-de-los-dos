#!/usr/bin/env bash
set -euo pipefail
: "${FLUTTER_VERSION:=3.47.8}"
: "${FLUTTER_REVISION:=737ba8f885dc774b53b442759999a312c9461e4e}"
: "${FLUTTER_HOME:=$HOME/.flutter-faro}"
if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
ACTUAL=$(git -C "$FLUTTER_HOME" rev-parse HEAD)
if [[ "$ACTUAL" != "$FLUTTER_REVISION" ]]; then
  echo '::error::La revisión del SDK no coincide con la versión fijada.'
  exit 1
fi
export PATH="$FLUTTER_HOME/bin:$PATH"
if [[ -n "${GITHUB_PATH:-}" ]]; then echo "$FLUTTER_HOME/bin" >> "$GITHUB_PATH"; fi
flutter config --no-analytics
flutter --version
