#!/bin/bash

# WindowSync Build Script
# This script builds the WindowSync project using Xcode

set -e

echo "🚀 Building WindowSync..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "WindowSync.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: WindowSync.xcodeproj not found. Please run this script from the project root."
    exit 1
fi

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf build/
rm -rf DerivedData/

# Build the project
echo "🔨 Building project..."
xcodebuild \
    -project WindowSync.xcodeproj \
    -scheme WindowSync \
    -configuration Release \
    -derivedDataPath DerivedData \
    -destination 'platform=macOS' \
    build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Find the built app
    APP_PATH=$(find DerivedData -name "WindowSync.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📱 App built at: $APP_PATH"
        
        # Copy to build directory
        mkdir -p build
        cp -R "$APP_PATH" build/
        echo "📁 App copied to build/WindowSync.app"
    else
        echo "⚠️  Warning: Could not find built app"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi

echo "🎉 Build complete!"
