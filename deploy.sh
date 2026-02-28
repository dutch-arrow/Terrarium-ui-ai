#!/bin/bash
# Deploy script for Terrarium UI to Android tablet
# Builds the APK and installs it on a connected device

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLUTTER_PATH="/home/tom/flutter/bin/flutter"
USE_MOCK="false"  # Set to "true" for mock mode, "false" for real WebSocket
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Terrarium UI - Android Deploy Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Flutter is available
if [ ! -f "$FLUTTER_PATH" ]; then
    echo -e "${RED}Error: Flutter not found at $FLUTTER_PATH${NC}"
    exit 1
fi

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB not found. Please install Android SDK platform-tools.${NC}"
    exit 1
fi

# Check for connected devices
echo -e "${YELLOW}Checking for connected devices...${NC}"
DEVICE_COUNT=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: No Android devices connected.${NC}"
    echo ""
    echo "Please connect your tablet via USB and ensure:"
    echo "  1. USB debugging is enabled on the tablet"
    echo "  2. The device is authorized (check for popup on tablet)"
    echo ""
    echo "Run 'adb devices' to see connected devices."
    exit 1
fi

echo -e "${GREEN}Found $DEVICE_COUNT connected device(s)${NC}"
adb devices | grep "device$"
echo ""

# Build the APK
echo -e "${YELLOW}Building APK (USE_MOCK=$USE_MOCK)...${NC}"
$FLUTTER_PATH build apk \
    --release \
    --dart-define=USE_MOCK=$USE_MOCK \
    --android-skip-build-dependency-validation

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: APK build failed${NC}"
    exit 1
fi

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Error: APK not found at $APK_PATH${NC}"
    exit 1
fi

# Get APK size
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}APK built successfully: $APK_SIZE${NC}"
echo ""

# Install APK
echo -e "${YELLOW}Installing APK on connected device...${NC}"
adb install -r "$APK_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: APK installation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "The Terrarium app has been installed on your tablet."
echo ""
if [ "$USE_MOCK" = "true" ]; then
    echo -e "${YELLOW}Note: App is running in MOCK mode${NC}"
else
    echo -e "${GREEN}App is configured to use real WebSocket connection${NC}"
    echo "Default server: ws://192.168.50.200:8765"
fi
echo ""
