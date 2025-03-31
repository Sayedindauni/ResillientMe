#!/bin/bash

echo "Performing a thorough cleanup of ResilientMe project..."

# Remove all .o files in the project
echo "Removing all object files..."
find . -name "*.o" -delete

# Clean DerivedData
echo "Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ResilientMe*

# Remove user state
echo "Resetting Xcode UI state..."
rm -f Digitalrejection/ResilientMe.xcodeproj/project.xcworkspace/xcuserdata/*.xcuserdatad/UserInterfaceState.xcuserstate

# Clean build products
echo "Cleaning build products..."
rm -rf Digitalrejection/build/

# Special handling for AccessibilityExtensions.o
echo "Special check for AccessibilityExtensions.o..."
find ~/Desktop -name "AccessibilityExtensions.o" -delete 2>/dev/null

echo "Done! Please restart Xcode and rebuild your project." 