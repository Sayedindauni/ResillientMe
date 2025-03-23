#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

PROJECT_FILE="./Digitalrejection/ResilientMe.xcodeproj/project.pbxproj"
WORKSPACE_DIR="./Digitalrejection/ResilientMe.xcodeproj/project.xcworkspace"

echo "Fixing duplicate package references..."

# Backup the project.pbxproj file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Project file backed up to $PROJECT_FILE.backup"

# Remove the package references section and replace with a clean one
# This is a simple fix - we basically reset the package dependencies
sed -i '' '/packageReferences = (/,/);/c\
		packageReferences = (\
		);' "$PROJECT_FILE"

echo "✅ Package references cleaned in project file"

# Remove workspace package cache
rm -rf "$WORKSPACE_DIR/xcshareddata/swiftpm" 2>/dev/null
echo "✅ Workspace package cache removed"

# Run the fix_packages script to clean caches
./fix_packages.sh

echo ""
echo "Project file has been fixed to remove duplicate package references."
echo ""
echo "Next steps:"
echo "1. Open the project in Xcode"
echo "2. You'll need to re-add any Swift Package dependencies manually"
echo "   (File > Add Package Dependencies...)"
echo ""
echo "If you need to restore the original project file:"
echo "cp \"$PROJECT_FILE.backup\" \"$PROJECT_FILE\"" 