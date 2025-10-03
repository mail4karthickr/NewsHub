#!/bin/bash

# NewsHub Deep Link Launcher
# Launch the app with a deep link URL via launch arguments

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
SCHEME="NewsHub"
PROJECT_PATH="NewsHub.xcodeproj"
SIMULATOR="iPhone 16"
DEEP_LINK=""
BUNDLE_ID="com.karthick.NewsHub"
# Allow override via environment variable
SIMULATOR_UDID="${NEWSHUB_SIMULATOR_UDID:-}"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] <deep-link-url>"
    echo ""
    echo "Launch NewsHub with a deep link URL"
    echo ""
    echo "Options:"
    echo "  -s, --simulator <name>    Simulator name (default: iPhone 16)"
    echo "  -u, --udid <udid>         Simulator UDID (overrides auto-detection)"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  NEWSHUB_SIMULATOR_UDID    Set simulator UDID (same as --udid)"
    echo ""
    echo "Deep Link URLs:"
    echo "  newshub://home           Navigate to Home tab"
    echo "  newshub://search         Navigate to Search tab"
    echo "  newshub://bookmarks      Navigate to Bookmarks tab"
    echo "  newshub://profile        Navigate to Profile tab"
    echo ""
    echo "Examples:"
    echo "  $0 newshub://search"
    echo "  $0 --simulator 'iPhone 15 Pro' newshub://profile"
    echo "  $0 --udid 1327A774-72AF-47FB-8835-A99F80B1F28D newshub://home"
    echo "  NEWSHUB_SIMULATOR_UDID=1327A774-72AF-47FB-8835-A99F80B1F28D $0 newshub://home"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--simulator)
            SIMULATOR="$2"
            shift 2
            ;;
        -u|--udid)
            SIMULATOR_UDID="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        newshub://*)
            DEEP_LINK="$1"
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
    esac
done

# Validate deep link
if [ -z "$DEEP_LINK" ]; then
    echo -e "${RED}Error: Deep link URL is required${NC}"
    usage
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        NewsHub Deep Link Launcher                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Deep Link:${NC} $DEEP_LINK"
echo -e "${GREEN}Simulator:${NC} $SIMULATOR"
echo ""

# Step 1: Get simulator UDID - specifically target iPhone 16 with iOS 26
if [ -z "$SIMULATOR_UDID" ]; then
    echo -e "${YELLOW}▶ Finding simulator...${NC}"
    
    # Hardcode iPhone 16 with iOS 26.0
    SIMULATOR_UDID="1327A774-72AF-47FB-8835-A99F80B1F28D"
    
    # Verify simulator exists
    if ! xcrun simctl list devices | grep -q "$SIMULATOR_UDID"; then
        echo -e "${RED}✗ Error: iPhone 16 (iOS 26) simulator not found${NC}"
        echo -e "${YELLOW}Expected UDID: $SIMULATOR_UDID${NC}"
        echo ""
        echo "Available iOS simulators:"
        xcrun simctl list devices | grep "iPhone 16"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Using iPhone 16 (iOS 26): $SIMULATOR_UDID${NC}"
else
    echo -e "${YELLOW}▶ Using specified simulator UDID...${NC}"
fi

# Get simulator details
SIMULATOR_INFO=$(xcrun simctl list devices available | grep "$SIMULATOR_UDID")
echo -e "${GREEN}✓ Found simulator: $SIMULATOR_INFO${NC}"
echo -e "${GREEN}  UDID: $SIMULATOR_UDID${NC}"

# Step 2: Boot simulator if not already booted
echo -e "${YELLOW}▶ Booting simulator...${NC}"
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || echo -e "${GREEN}✓ Simulator already booted${NC}"

# Wait for simulator to be ready
sleep 2

# Step 3: Open Simulator app
echo -e "${YELLOW}▶ Opening Simulator app...${NC}"
open -a Simulator

# Wait for Simulator to open
sleep 2

# Step 4: Build the app
echo -e "${YELLOW}▶ Building NewsHub...${NC}"
xcodebuild -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -derivedDataPath .build \
    build 2>&1 | grep -E "BUILD SUCCEEDED|error:" || true

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build succeeded${NC}"

# Step 5: Get app bundle path
APP_PATH=$(find .build/Build/Products/Debug-iphonesimulator -name "NewsHub.app" -maxdepth 1 | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}✗ Error: Could not find app bundle${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found app: $APP_PATH${NC}"

# Step 6: Install app
echo -e "${YELLOW}▶ Installing app...${NC}"
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"
echo -e "${GREEN}✓ App installed${NC}"

# Step 7: Terminate app if running (to ensure fresh launch)
echo -e "${YELLOW}▶ Terminating any running instance...${NC}"
xcrun simctl terminate "$SIMULATOR_UDID" "$BUNDLE_ID" 2>/dev/null || echo -e "${GREEN}✓ App was not running${NC}"

# Step 8: Launch app
echo -e "${YELLOW}▶ Launching app...${NC}"
xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"
echo -e "${GREEN}✓ App launched${NC}"

# Step 9: Wait for app to be ready
echo -e "${YELLOW}▶ Waiting for app to initialize...${NC}"
sleep 3

# Step 10: Send deep link to running app
echo -e "${YELLOW}▶ Sending deep link to app...${NC}"
xcrun simctl openurl "$SIMULATOR_UDID" "$DEEP_LINK"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ App launched successfully with deep link!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Deep Link: ${BLUE}$DEEP_LINK${NC}"
echo ""
echo "The app should now be navigating to the correct tab."
echo ""
