#!/bin/bash

echo "Performing a complete rebuild of ResilientMe project..."
echo "This will remove all compiled files and caches"

# Remove all object files in all directories
echo "Removing all object files..."
find . -name "*.o" -delete
find ~/Desktop -name "AccessibilityExtensions.o" -delete 2>/dev/null

# Clean DerivedData for ALL Xcode projects (more drastic)
echo "Removing ALL DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Remove module caches which can contain stale references
echo "Removing module caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache

# Remove Xcode build products
echo "Removing build products..."
rm -rf Digitalrejection/build/
rm -rf Digitalrejection/ResilientMe/build/

# Reset Xcode state
echo "Resetting Xcode UI state..."
find . -name "UserInterfaceState.xcuserstate" -delete

# Remove any potential stale symbolication files
echo "Removing symbolication files..."
find . -name "*.dSYM" -exec rm -rf {} \; 2>/dev/null

echo "Done! Please follow these steps:"
echo "1. Completely quit Xcode"
echo "2. Restart your Mac"
echo "3. Open Xcode and clean the build folder (Product > Clean Build Folder)"
echo "4. Rebuild your project" 