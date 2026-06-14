#!/bin/sh
set -e

SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application: Joseph Dombroski (A693T94WP5)}"

# Clean previous builds
rm -rf .build
rm -rf CoreLocationCLI.app

# Build for both architectures
swift build -c release --arch arm64 --arch x86_64

# Package as app bundle
mkdir -p CoreLocationCLI.app/Contents/MacOS/
cp ./.build/apple/Products/Release/CoreLocationCLI CoreLocationCLI.app/Contents/MacOS/
cp Info.plist CoreLocationCLI.app/Contents

# Sign with Developer ID
echo "Signing with: $SIGNING_IDENTITY"
codesign --force --deep --options runtime --sign "$SIGNING_IDENTITY" CoreLocationCLI.app

# Verify signature
echo "Verifying signature..."
codesign --verify --verbose=2 CoreLocationCLI.app

echo "Build complete: CoreLocationCLI.app"