#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Print status
echo "Fixing Swift Package Manager issues..."

# STEP 1: Reset Package Manager state and caches
echo "Clearing package caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ResilientMe-* 2>/dev/null
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null
rm -rf ~/Library/Caches/com.apple.swiftpm 2>/dev/null

# STEP 2: Clean the package resolution file if it exists
echo "Cleaning package resolution files..."
find . -name "Package.resolved" -delete
find . -name "project.xcworkspace" -path "*/xcshareddata/swiftpm/*" -delete

# STEP 3: Reset Xcode's package caches
echo "Resetting Xcode package caches..."
defaults delete com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 2>/dev/null
defaults delete com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 2>/dev/null

# STEP 4: Clean build artifacts
echo "Cleaning project..."
xcodebuild clean -project Digitalrejection/ResilientMe.xcodeproj -scheme ResilientMe 2>/dev/null

echo "✅ Swift Package Manager reset completed!"
echo ""
echo "Please follow these steps:"
echo "1. Quit Xcode completely"
echo "2. Reopen Xcode and your project"
echo "3. In Xcode, go to File > Packages > Reset Package Caches"
echo "4. Build the project again"
echo ""
echo "If the issue persists, you may need to manually remove and re-add the package dependencies in your project settings." 