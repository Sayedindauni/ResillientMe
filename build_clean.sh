#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Print status
echo "Cleaning project..."

# Remove Derived Data (if permissions allow)
rm -rf ~/Library/Developer/Xcode/DerivedData/ResilientMe-* 2>/dev/null

# Clean build artifacts
xcodebuild clean -project Digitalrejection/ResilientMe.xcodeproj -scheme ResilientMe

echo "Done cleaning. Please restart Xcode and rebuild the project." 