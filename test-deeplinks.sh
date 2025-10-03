#!/bin/bash

# NewsHub Deep Link Test Script
# Usage: ./test-deeplinks.sh [home|search|bookmarks|profile|all]

echo "🚀 NewsHub Deep Link Testing"
echo "================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Bundle ID
BUNDLE_ID="com.karthick.NewsHub"

# Function to check if app is running
check_app_running() {
    if xcrun simctl spawn booted launchctl list | grep -q "$BUNDLE_ID"; then
        echo -e "${GREEN}✅ App is running${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  App is not running${NC}"
        return 1
    fi
}

# Function to launch app
launch_app() {
    echo -e "${BLUE}📱 Launching app...${NC}"
    xcrun simctl launch --console booted "$BUNDLE_ID"
    sleep 2
    echo -e "${GREEN}✅ App launched${NC}"
}

# Function to test deep link
test_deeplink() {
    local url=$1
    local description=$2
    
    echo ""
    echo -e "${BLUE}🔗 Testing: ${url}${NC}"
    echo "   Description: ${description}"
    xcrun simctl openurl booted "${url}"
    sleep 1.5
    echo -e "${GREEN}✅ Deep link sent${NC}"
}

# Main script
echo "Checking app status..."
if ! check_app_running; then
    launch_app
fi

echo ""
echo "Ready to test deep links!"
echo ""

# Determine which tests to run
TEST_TYPE=${1:-all}

case $TEST_TYPE in
    home)
        test_deeplink "newshub://home" "Navigate to Home tab"
        ;;
    search)
        test_deeplink "newshub://search" "Navigate to Search tab"
        ;;
    bookmarks)
        test_deeplink "newshub://bookmarks" "Navigate to Bookmarks tab"
        ;;
    profile)
        test_deeplink "newshub://profile" "Navigate to Profile tab"
        ;;
    all)
        test_deeplink "newshub://home" "Navigate to Home tab"
        test_deeplink "newshub://search" "Navigate to Search tab"
        test_deeplink "newshub://bookmarks" "Navigate to Bookmarks tab"
        test_deeplink "newshub://profile" "Navigate to Profile tab"
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 [home|search|bookmarks|profile|all]${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Deep link test complete!${NC}"
echo ""
echo "Available deep links:"
echo "  • newshub://home       - Home tab"
echo "  • newshub://search     - Search tab"
echo "  • newshub://bookmarks  - Bookmarks tab"
echo "  • newshub://profile    - Profile tab"
