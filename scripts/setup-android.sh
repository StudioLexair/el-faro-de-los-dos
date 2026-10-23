#!/usr/bin/env bash
set -euo pipefail
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/.android-faro-sdk}}"
if [[ -d "$SDK" && ! -w "$SDK" ]]; then SDK="$HOME/.android-faro-sdk"; fi
mkdir -p "$SDK/cmdline-tools"
SDKMANAGER="$SDK/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "$SDKMANAGER" ]]; then
  FOUND=$(find "$SDK/cmdline-tools" -type f -path '*/bin/sdkmanager' 2>/dev/null | sort -V | tail -n 1)
  if [[ -n "$FOUND" ]]; then SDKMANAGER="$FOUND"; fi
fi
if [[ ! -x "$SDKMANAGER" ]]; then
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT
  curl --fail --location --retry 3 https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o "$TEMP_DIR/tools.zip"
  unzip -q "$TEMP_DIR/tools.zip" -d "$TEMP_DIR/extracted"
  mv "$TEMP_DIR/extracted/cmdline-tools" "$SDK/cmdline-tools/latest"
  SDKMANAGER="$SDK/cmdline-tools/latest/bin/sdkmanager"
fi
export ANDROID_HOME="$SDK" ANDROID_SDK_ROOT="$SDK"
export PATH="$(dirname "$SDKMANAGER"):$SDK/platform-tools:$PATH"
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "ANDROID_HOME=$SDK" >> "$GITHUB_ENV"
  echo "ANDROID_SDK_ROOT=$SDK" >> "$GITHUB_ENV"
  echo "$(dirname "$SDKMANAGER")" >> "$GITHUB_PATH"
  echo "$SDK/platform-tools" >> "$GITHUB_PATH"
fi
# yes can receive SIGPIPE after the accepted-license prompt; package install below
# still fails normally if any required license or download is unavailable.
yes | "$SDKMANAGER" --sdk_root="$SDK" --licenses >/dev/null || true
"$SDKMANAGER" --sdk_root="$SDK" 'platform-tools' 'platforms;android-35' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;28.2.13676358' 'cmake;3.22.1'
flutter config --android-sdk "$SDK"
