#!/usr/bin/env bash
set -euo pipefail

APP_ID="${MAESTRO_APP_ID:-com.a-know.pixelaButtons}"
APP_PATH="${MAESTRO_APP_PATH:-build/ios/iphonesimulator/Runner.app}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "App bundle not found: ${APP_PATH}" >&2
  exit 1
fi

if ! command -v maestro >/dev/null 2>&1; then
  echo "Maestro is not installed or not on PATH" >&2
  exit 1
fi

device_id="${MAESTRO_DEVICE_ID:-}"
if [[ -z "${device_id}" ]]; then
  device_id="$(
    xcrun simctl list devices available --json | ruby -rjson -e '
      devices = JSON.parse(STDIN.read).fetch("devices").values.flatten
      device = devices.find { |item| item["name"].include?("iPhone") && item["isAvailable"] }
      abort "No available iPhone simulator found" unless device
      puts device.fetch("udid")
    '
  )"
fi

echo "Using simulator: ${device_id}"

xcrun simctl shutdown all >/dev/null 2>&1 || true
xcrun simctl boot "${device_id}"
xcrun simctl bootstatus "${device_id}" -b

xcrun simctl spawn "${device_id}" defaults write NSGlobalDomain AppleLanguages -array ja
xcrun simctl spawn "${device_id}" defaults write NSGlobalDomain AppleLocale ja_JP

xcrun simctl uninstall "${device_id}" "${APP_ID}" >/dev/null 2>&1 || true
xcrun simctl install "${device_id}" "${APP_PATH}"

MAESTRO_APP_ID="${APP_ID}" scripts/maestro_test.sh
