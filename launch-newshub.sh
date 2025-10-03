#!/bin/bash

# Quick launcher for NewsHub on iPhone 16 (iOS 26)
# This script always uses the correct simulator UDID

# iPhone 16 with iOS 26 UDID
SIMULATOR_UDID="1327A774-72AF-47FB-8835-A99F80B1F28D"

# Export for the launch script
export NEWSHUB_SIMULATOR_UDID="$SIMULATOR_UDID"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Pass all arguments to the main launch script
"$SCRIPT_DIR/launch-with-deeplink.sh" "$@"
