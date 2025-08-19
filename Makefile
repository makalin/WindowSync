# WindowSync Makefile
# Provides convenient build targets for the WindowSync project

.PHONY: all build clean test install uninstall help

# Default target
all: build

# Build the project
build:
	@echo "🚀 Building WindowSync..."
	@xcodebuild \
		-project WindowSync.xcodeproj \
		-scheme WindowSync \
		-configuration Release \
		-derivedDataPath DerivedData \
		-destination 'platform=macOS' \
		build

# Build in debug mode
debug:
	@echo "🐛 Building WindowSync (Debug)..."
	@xcodebuild \
		-project WindowSync.xcodeproj \
		-scheme WindowSync \
		-configuration Debug \
		-derivedDataPath DerivedData \
		-destination 'platform=macOS' \
		build

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build/
	@rm -rf DerivedData/
	@rm -rf *.app
	@xcodebuild clean

# Run tests
test:
	@echo "🧪 Running tests..."
	@xcodebuild \
		-project WindowSync.xcodeproj \
		-scheme WindowSync \
		-destination 'platform=macOS' \
		test

# Install the app to Applications folder
install: build
	@echo "📱 Installing WindowSync..."
	@cp -R build/WindowSync.app /Applications/
	@echo "✅ WindowSync installed to /Applications/"

# Uninstall the app
uninstall:
	@echo "🗑️  Uninstalling WindowSync..."
	@rm -rf /Applications/WindowSync.app
	@echo "✅ WindowSync uninstalled"

# Create a DMG package
package: build
	@echo "📦 Creating DMG package..."
	@mkdir -p dist
	@hdiutil create -volname "WindowSync" -srcfolder build/WindowSync.app -ov -format UDZO dist/WindowSync.dmg
	@echo "✅ DMG created: dist/WindowSync.dmg"

# Run the app (requires build first)
run: build
	@echo "▶️  Running WindowSync..."
	@open build/WindowSync.app

# Show help
help:
	@echo "WindowSync Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build     - Build the project (Release)"
	@echo "  debug     - Build the project (Debug)"
	@echo "  clean     - Clean build artifacts"
	@echo "  test      - Run tests"
	@echo "  install   - Install to Applications folder"
	@echo "  uninstall - Remove from Applications folder"
	@echo "  package   - Create DMG package"
	@echo "  run       - Build and run the app"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Example: make build && make install"
